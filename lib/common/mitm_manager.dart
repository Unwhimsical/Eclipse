import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/ca_store.dart';
import 'package:fl_clash/common/module_store.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/core/controller.dart';

/// Manages the MITM proxy lifecycle: collects hosts/rewrites/scripts from
/// enabled modules, downloads remote scripts, and starts/stops the Go MITM
/// proxy.
class MitmManager {
  static const listenAddr = '127.0.0.1:9092';
  static const proxyName = 'PigCat-MITM';

  final CoreController _controller;
  final ModuleStore _moduleStore;
  final Dio _dio;

  MitmManager(this._controller)
      : _moduleStore = ModuleStore(),
        _dio = Dio();

  /// Build MITM config from all enabled modules and start the proxy.
  /// Returns true if the proxy was started (at least one module needs MITM).
  Future<bool> syncAndStart() async {
    final modules = await _moduleStore.list();
    final enabled = modules.where((m) => m.enabled).toList();
    if (enabled.isEmpty) {
      await stop();
      return false;
    }

    final hosts = <String>{};
    final rewrites = <Map<String, String>>[];
    final scripts = <Map<String, dynamic>>[];

    for (final module in enabled) {
      try {
        final path = await _moduleStore.moduleFilePath(module.id);
        final file = File(path);
        if (!await file.exists()) continue;
        final content = await file.readAsString();
        final sg = parseSgmodule(content);

        // MITM hostnames.
        hosts.addAll(sg.mitmHostnames);

        // URL rewrites: parse "pattern target status".
        for (final line in sg.urlRewrites) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length < 2) continue;
          rewrites.add({
            'pattern': parts[0],
            'target': parts[1],
            'status': parts.length >= 3 ? parts[2] : '302',
          });
        }

        // Scripts: parse and download content.
        for (final line in sg.scripts) {
          final parsed = _parseScriptLine(line);
          if (parsed == null) continue;
          // Download remote script content.
          final scriptPath = parsed['scriptPath'] as String?;
          String content = '';
          if (scriptPath != null && scriptPath.isNotEmpty) {
            content = await _downloadScript(scriptPath);
          }
          scripts.add({
            'name': parsed['name'],
            'type': parsed['type'],
            'pattern': parsed['pattern'],
            'requiresBody': parsed['requiresBody'],
            'scriptPath': scriptPath,
            'content': content,
          });
        }
      } catch (_) {
        // Skip modules that fail to parse.
        continue;
      }
    }

    // No MITM features needed.
    if (hosts.isEmpty && rewrites.isEmpty && scripts.isEmpty) {
      await stop();
      return false;
    }

    // Load CA.
    final caStore = CaStore();
    if (!await caStore.exists) {
      // CA not ready; cannot intercept TLS.
      return false;
    }
    final certPem = await File(await caStore.certPath).readAsString();
    final keyPem = await File(await caStore.keyPath).readAsString();
    if (certPem.isEmpty || keyPem.isEmpty) {
      return false;
    }

    final config = {
      'listen': listenAddr,
      'caCert': certPem,
      'caKey': keyPem,
      'hosts': hosts.toList(),
      'rewrites': rewrites,
      'scripts': scripts,
      // Upstream: forward through Mihomo's HTTP proxy if available.
      // Empty means direct.
      'upstream': '',
    };

    try {
      await _controller.mitmStart(config);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stop the MITM proxy.
  Future<void> stop() async {
    try {
      await _controller.mitmStop();
    } catch (_) {}
  }

  /// Parse a [Script] line into a map.
  Map<String, dynamic>? _parseScriptLine(String line) {
    final eq = line.indexOf('=');
    if (eq < 0) return null;
    final name = line.substring(0, eq).trim();
    final rest = line.substring(eq + 1).trim();
    String type = '';
    String pattern = '';
    bool requiresBody = false;
    String? scriptPath;
    for (final part in rest.split(',')) {
      final kv = part.trim().split('=');
      if (kv.length != 2) continue;
      final k = kv[0].trim().toLowerCase();
      final v = kv[1].trim();
      switch (k) {
        case 'type':
          type = v;
        case 'pattern':
          pattern = v;
        case 'requires-body':
          requiresBody = v == '1' || v.toLowerCase() == 'true';
        case 'script-path':
          scriptPath = v;
      }
    }
    return {
      'name': name,
      'type': type,
      'pattern': pattern,
      'requiresBody': requiresBody,
      'scriptPath': scriptPath,
    };
  }

  /// Download a remote script. Returns empty string on failure.
  Future<String> _downloadScript(String url) async {
    try {
      final resp = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      return resp.data ?? '';
    } catch (_) {
      return '';
    }
  }
}
