import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/ca_store.dart';
import 'package:fl_clash/common/module_store.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:flutter/foundation.dart';

/// Manages the MITM proxy lifecycle: collects hosts/rewrites/scripts from
/// enabled modules, downloads remote scripts, and starts/stops the Go MITM
/// proxy.
class MitmManager {
  static const listenAddr = '127.0.0.1:9092';
  static const proxyName = 'PigCat-MITM';

  final CoreController _controller;
  final ModuleStore _moduleStore;
  final Dio _dio;

  MitmManager(this._controller) : _moduleStore = ModuleStore(), _dio = Dio();

  /// Build MITM config from all enabled modules and start the proxy.
  /// Returns true if the proxy was started (at least one module needs MITM).
  Future<bool> syncAndStart({
    List<String> profileUrlRewrites = const [],
    List<String> profileHeaderRewrites = const [],
    List<String> profileMitmHostnames = const [],
  }) async {
    final modules = await _moduleStore.list();
    final enabled = modules.where((m) => m.enabled).toList();
    // Start MITM if modules OR profile have rewrites/scripts/hostnames.
    if (enabled.isEmpty &&
        profileUrlRewrites.isEmpty &&
        profileHeaderRewrites.isEmpty &&
        profileMitmHostnames.isEmpty) {
      await stop();
      return false;
    }

    final hosts = <String>{};
    final rewrites = <Map<String, String>>[];
    final scripts = <Map<String, dynamic>>[];
    final headerRewriteLines = <String>[...profileHeaderRewrites];

    // DNS hostnames are case-insensitive; normalize so differently-cased
    // spellings of the same host do not become separate entries.
    void addHosts(Iterable<String> values) {
      for (final value in values) {
        final host = value.trim().toLowerCase();
        if (host.isNotEmpty) hosts.add(host);
      }
    }

    // Profile rewrites come first (they're part of the config).
    for (final line in profileUrlRewrites) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      rewrites.add({
        'pattern': parts[0],
        'target': parts[1],
        'status': parts.length >= 3 ? parts[2] : '302',
      });
    }

    // Profile MITM hostnames join the same host set as module hostnames.
    addHosts(profileMitmHostnames);

    for (final module in enabled) {
      try {
        final path = await _moduleStore.moduleFilePath(module.id);
        final file = File(path);
        if (!await file.exists()) continue;
        final content = await file.readAsString();
        final Sgmodule sg = parseSgmodule(content);

        // MITM hostnames.
        addHosts(sg.mitmHostnames);

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

        headerRewriteLines.addAll(sg.headerRewrites);

        // Scripts: parse and download content.
        for (final line in sg.scripts) {
          final parsed = parseScriptLine(line);
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
            'binaryBody': parsed['binaryBody'],
            'timeout': parsed['timeout'],
            'maxSize': parsed['maxSize'],
            'argument': parsed['argument'],
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
    final headerRewrites = parseHeaderRewriteRules(headerRewriteLines);
    if (hosts.isEmpty &&
        rewrites.isEmpty &&
        scripts.isEmpty &&
        headerRewrites.isEmpty) {
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
      'headerRewrites': headerRewrites,
      'scripts': scripts,
      // Upstream: forward through Mihomo's HTTP proxy if available.
      // Empty means direct.
      'upstream': '',
    };

    try {
      // A running proxy ignores mitmStart, so update its config in place.
      final updated = await _controller.mitmUpdateConfig(config);
      if (updated['running'] != true) {
        await _controller.mitmStart(config);
      }
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
  static Map<String, dynamic>? parseScriptLine(String line) {
    final eq = line.indexOf('=');
    if (eq < 0) return null;
    final name = line.substring(0, eq).trim();
    final rest = line.substring(eq + 1).trim();
    String type = '';
    String pattern = '';
    bool requiresBody = false;
    bool binaryBody = false;
    int timeout = 20;
    int maxSize = 10 * 1024 * 1024;
    String argument = '';
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
          requiresBody =
              v == '1' || v.toLowerCase() == 'true' || v.toLowerCase() == 'yes';
        case 'binary-body-mode':
          binaryBody = v == '1' || v.toLowerCase() == 'true';
        case 'timeout':
          timeout = int.tryParse(v) ?? 20;
        case 'max-size':
          maxSize = int.tryParse(v) ?? (10 * 1024 * 1024);
        case 'argument':
          argument = v;
        case 'script-path':
          scriptPath = v;
      }
    }
    return {
      'name': name,
      'type': type,
      'pattern': pattern,
      'requiresBody': requiresBody,
      'binaryBody': binaryBody,
      'timeout': timeout,
      'maxSize': maxSize,
      'argument': argument,
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

@visibleForTesting
List<Map<String, dynamic>> parseHeaderRewriteRules(Iterable<String> lines) {
  final rules = <Map<String, dynamic>>[];
  for (final line in lines) {
    final parsed = parseHeaderRewriteLine(line);
    if (parsed == null) continue;
    rules.add({
      'pattern': parsed.pattern,
      'action': parsed.action,
      'args': parsed.args,
    });
  }
  return rules;
}
