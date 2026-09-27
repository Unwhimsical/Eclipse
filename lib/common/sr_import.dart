import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/clash_config.dart';
import '../models/module.dart';
import '../models/profile.dart';
import '../providers/providers.dart';
import 'module_store.dart';
import 'request.dart';
import 'shadowrocket.dart';

/// Import flows for Shadowrocket formats, built on the existing profile and
/// global-rule pipeline. Plain static helpers so no provider codegen is needed.
class ShadowrocketImport {
  /// Import share links (one per line, or a base64 subscription body).
  /// Creates a new profile from the parsed nodes. Returns the profile label
  /// on success, null when nothing could be parsed.
  static Future<String?> importShareLinks(
    WidgetRef ref, {
    required String text,
    String? label,
  }) async {
    final proxies = _parseLinkList(text);
    if (proxies.isEmpty) return null;
    final yamlText = buildClashConfigFromProxies(proxies: proxies);
    return _createProfileFromYaml(
      ref,
      yamlText,
      label ?? '导入节点 (${proxies.length})',
    );
  }

  /// Import a `.conf` file. Nodes become a new profile; rules and proxy
  /// groups are merged into global rules / the new profile. `[General]`
  /// DNS servers are applied to the generated profile.
  static Future<String?> importConf(
    WidgetRef ref, {
    required String content,
    String? fileName,
  }) async {
    final conf = parseConf(content);
    if (conf.isEmpty) return null;
    String? profileLabel;
    if (conf.proxies.isNotEmpty) {
      final yamlText = buildClashConfigFromProxies(
        proxies: conf.proxies,
        proxyGroups: conf.proxyGroups.isEmpty ? null : conf.proxyGroups,
        rules: conf.rules.isEmpty ? null : conf.rules,
        dnsServers: conf.dnsServers.isEmpty ? null : conf.dnsServers,
      );
      profileLabel = await _createProfileFromYaml(
        ref,
        yamlText,
        fileName?.replaceAll('.conf', '') ?? '导入配置 (${conf.proxies.length})',
      );
    }
    if (conf.rules.isNotEmpty) {
      await _addGlobalRules(ref, conf.rules);
    }
    return profileLabel ?? '规则已导入 (${conf.rules.length})';
  }

  /// Download a `.conf` from a remote URL and import it.
  static Future<String?> importConfFromUrl(
    WidgetRef ref, {
    required String url,
  }) async {
    final response = await request.getTextResponseForUrl(url);
    final content = response.data ?? '';
    if (content.isEmpty) return null;
    return importConf(ref, content: content, fileName: _fileNameFromUrl(url));
  }

  /// Import `[Rule]` lines into global rules.
  static Future<int> importRules(WidgetRef ref, List<String> lines) async {
    return _addGlobalRules(ref, lines);
  }

  /// Import a `.sgmodule` file into the module store and apply its static
  /// `[Rule]` / `[Host]` entries as global rules. Large modules use
  /// file-based `rule-providers` with `RULE-SET` rules instead.
  static Future<ModuleInfo?> importModule(
    WidgetRef ref, {
    required String raw,
    String? fileName,
  }) async {
    final info = await moduleStore.import(raw, fileName: fileName);
    if (info.ruleSetRules.isNotEmpty) {
      await _addGlobalRules(ref, info.ruleSetRules);
      final inline = await moduleStore.readInlineRules(info.id);
      if (inline.isNotEmpty) {
        await _addGlobalRules(ref, inline);
      }
    } else {
      final parsed = parseSgmodule(raw);
      if (parsed.rules.isNotEmpty) {
        await _addGlobalRules(ref, parsed.rules);
      }
    }
    return info;
  }

  /// Download a `.sgmodule` from a remote URL and import it.
  static Future<ModuleInfo?> importModuleFromUrl(
    WidgetRef ref, {
    required String url,
  }) async {
    final response = await request.getTextResponseForUrl(url);
    final raw = response.data ?? '';
    if (raw.isEmpty) return null;
    return importModule(ref, raw: raw, fileName: _fileNameFromUrl(url));
  }

  static String _fileNameFromUrl(String url) {
    final name = url.split('/').last.split('?').first;
    return name.isEmpty ? url : name;
  }

  /// Toggle a module. Disabling removes its rules; enabling re-applies them.
  /// Note: rules are matched by exact text, so user edits are preserved.
  static Future<void> setModuleEnabled(
    WidgetRef ref,
    ModuleInfo info,
    bool enabled,
  ) async {
    await moduleStore.toggle(info.id, enabled);
    if (info.ruleSetRules.isNotEmpty) {
      if (enabled) {
        await _addGlobalRules(ref, info.ruleSetRules);
        final inline = await moduleStore.readInlineRules(info.id);
        if (inline.isNotEmpty) {
          await _addGlobalRules(ref, inline);
        }
      } else {
        await _removeGlobalRules(ref, info.ruleSetRules);
        final inline = await moduleStore.readInlineRules(info.id);
        if (inline.isNotEmpty) {
          await _removeGlobalRules(ref, inline);
        }
      }
      return;
    }
    final raw = await moduleStore.readRaw(info.id);
    if (raw == null) return;
    final parsed = parseSgmodule(raw);
    if (parsed.rules.isEmpty) return;
    if (enabled) {
      await _addGlobalRules(ref, parsed.rules);
    } else {
      await _removeGlobalRules(ref, parsed.rules);
    }
  }

  static List<Map<String, dynamic>> _parseLinkList(String text) {
    final proxies = <Map<String, dynamic>>[];
    final lines = const LineSplitter()
        .convert(text)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (final line in lines) {
      final proxy = parseShareLink(line);
      if (proxy != null) proxies.add(proxy);
    }
    if (proxies.isEmpty) {
      // Maybe the whole body is a base64 subscription.
      try {
        final decoded = utf8.decode(
          base64.decode(text.trim().replaceAll(RegExp(r'\s'), '')),
        );
        for (final line in const LineSplitter().convert(decoded)) {
          final proxy = parseShareLink(line.trim());
          if (proxy != null) proxies.add(proxy);
        }
      } catch (_) {}
    }
    return proxies;
  }

  static Future<String?> _createProfileFromYaml(
    WidgetRef ref,
    String yamlText,
    String label,
  ) async {
    final core = ref.read(coreHandlerProvider);
    final profile = await Profile.normal(label: label).saveFile(
      Uint8List.fromList(utf8.encode(yamlText)),
      validate: (path) => core.validateConfig(path),
    );
    ref.read(profilesActionProvider.notifier).putProfile(profile);
    return label;
  }

  static Future<int> _addGlobalRules(WidgetRef ref, List<String> lines) async {
    final notifier = ref.read(globalRulesProvider.notifier);
    final existing =
        ref.read(globalRulesProvider).value?.map((e) => e.rawValue).toSet() ??
        {};
    var count = 0;
    for (final line in lines) {
      try {
        final rule = Rule.parse(line);
        final key = rule.rawValue;
        if (existing.contains(key)) continue;
        existing.add(key);
        notifier.put(rule);
        count++;
      } catch (_) {
        // Skip lines that do not map to Clash rules.
      }
    }
    return count;
  }

  static Future<void> _removeGlobalRules(
    WidgetRef ref,
    List<String> lines,
  ) async {
    final notifier = ref.read(globalRulesProvider.notifier);
    final targets = lines.toSet();
    final rules = ref.read(globalRulesProvider).value ?? [];
    final ids = rules
        .where((rule) => targets.contains(rule.rawValue))
        .map((rule) => rule.id)
        .toList();
    if (ids.isNotEmpty) {
      notifier.delAll(ids);
    }
  }
}
