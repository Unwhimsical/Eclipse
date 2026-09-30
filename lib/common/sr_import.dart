import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    final proxies = parseLinkList(text);
    if (proxies.isEmpty) return null;
    final yamlText = buildClashConfigFromProxies(proxies: proxies);
    return _createProfileFromYaml(
      ref,
      yamlText,
      label ?? '导入节点 (${proxies.length})',
    );
  }

  /// Read the `[MITM]` enable flag from a parsed conf's mitm map.
  static bool parseMitmEnabled(Map<String, String> mitm) {
    return (mitm['enable'] ?? '').trim().toLowerCase() == 'true';
  }

  /// Split the `[MITM]` hostname list from a parsed conf's mitm map.
  static List<String> parseMitmHostnames(Map<String, String> mitm) {
    return (mitm['hostname'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Import a `.conf` file. Nodes become a new profile; rules and proxy
  /// groups are merged into global rules / the new profile. `[General]`
  /// DNS servers are applied to the generated profile.
  static Future<String?> importConf(
    WidgetRef ref, {
    required String content,
    String? fileName,
  }) async {
    final ConfData conf = parseConf(content);
    if (conf.isEmpty) return null;
    String? profileLabel;
    if (conf.proxies.isNotEmpty) {
      final yamlText = buildClashConfigFromProxies(
        proxies: conf.proxies,
        proxyGroups: conf.proxyGroups.isEmpty ? null : conf.proxyGroups,
        rules: conf.rules.isEmpty ? null : conf.rules,
        dnsServers: conf.dnsServers.isEmpty ? null : conf.dnsServers,
        directDnsServers: conf.directDnsServers.isEmpty
            ? null
            : conf.directDnsServers,
        tunExcludedRoutes: conf.tunExcludedRoutes.isEmpty
            ? null
            : conf.tunExcludedRoutes,
        tunIncludedRoutes: conf.tunIncludedRoutes.isEmpty
            ? null
            : conf.tunIncludedRoutes,
        ipv6Enabled: conf.general.containsKey('ipv6') ? conf.ipv6Enabled : null,
        preferIpv6: conf.general.containsKey('prefer-ipv6')
            ? conf.preferIpv6
            : null,
        alwaysRealIp: conf.general.containsKey('always-real-ip')
            ? conf.alwaysRealIp
            : null,
      );
      profileLabel = await _createProfileFromYaml(
        ref,
        yamlText,
        fileName?.replaceAll('.conf', '') ?? '导入配置 (${conf.proxies.length})',
        hosts: conf.hosts,
        urlRewrites: conf.urlRewrites,
        headerRewrites: conf.headerRewrites,
        mitmEnabled: parseMitmEnabled(conf.mitm),
        mitmHostnames: parseMitmHostnames(conf.mitm),
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
    return importConf(ref, content: content, fileName: fileNameFromUrl(url));
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
    final name = parseSgmodule(raw).name;
    if (name.isNotEmpty) {
      final existing = await moduleStore.findByName(name);
      if (existing != null) {
        return updateModule(ref, existing.id, raw);
      }
    }
    final info = await moduleStore.import(raw, fileName: fileName);
    if (info.ruleSetRules.isNotEmpty) {
      await _addGlobalRules(ref, info.ruleSetRules);
      final inline = await moduleStore.readInlineRules(info.id);
      if (inline.isNotEmpty) {
        await _addGlobalRules(ref, inline);
      }
    } else {
      final rules = parseSgmoduleWithArguments(raw, const {}).rules;
      if (rules.isNotEmpty) {
        await _addGlobalRules(ref, rules);
      }
    }
    return info;
  }

  static Future<ModuleInfo?> updateModule(
    WidgetRef ref,
    String id,
    String newRaw,
  ) async {
    final oldInfo = (await moduleStore.list()).where((e) => e.id == id);
    if (oldInfo.isEmpty) return null;
    final info = oldInfo.first;
    final oldRaw = await moduleStore.readRaw(id);
    if (oldInfo.first.ruleSetRules.isNotEmpty) {
      await _removeGlobalRules(ref, info.ruleSetRules);
      final oldInline = await moduleStore.readInlineRules(id);
      if (oldInline.isNotEmpty) {
        await _removeGlobalRules(ref, oldInline);
      }
    } else if (oldRaw != null) {
      await _removeGlobalRules(
        ref,
        parseSgmoduleWithArguments(oldRaw, info.argumentValues).rules,
      );
    }
    final updated = await moduleStore.updateContent(id, newRaw);
    if (updated == null) return null;
    if (updated.ruleSetRules.isNotEmpty) {
      await _addGlobalRules(ref, updated.ruleSetRules);
      final inline = await moduleStore.readInlineRules(id);
      if (inline.isNotEmpty) {
        await _addGlobalRules(ref, inline);
      }
    } else {
      final rules = parseSgmoduleWithArguments(
        newRaw,
        updated.argumentValues,
      ).rules;
      if (rules.isNotEmpty) {
        await _addGlobalRules(ref, rules);
      }
    }
    await _syncMitm(ref);
    return updated;
  }

  static Future<void> setModuleArgumentValues(
    WidgetRef ref,
    ModuleInfo info,
    Map<String, String> values,
  ) async {
    final modules = await moduleStore.list();
    final current = modules.where((e) => e.id == info.id).firstOrNull ?? info;
    final raw = await moduleStore.readRaw(current.id);
    if (raw == null) return;
    if (current.ruleSetRules.isNotEmpty) {
      await _removeGlobalRules(ref, current.ruleSetRules);
      final oldInline = await moduleStore.readInlineRules(current.id);
      if (oldInline.isNotEmpty) {
        await _removeGlobalRules(ref, oldInline);
      }
      await moduleStore.setArgumentValues(current.id, values);
      final substituted = parseSgmoduleWithArguments(raw, values).rules;
      final ruleSetRules = await moduleStore.rewriteRuleProviders(
        current.id,
        substituted,
      );
      await _addGlobalRules(ref, ruleSetRules);
      final inline = await moduleStore.readInlineRules(current.id);
      if (inline.isNotEmpty) {
        await _addGlobalRules(ref, inline);
      }
    } else {
      final diff = moduleRulesDiff(
        oldRaw: raw,
        oldValues: current.argumentValues,
        newRaw: raw,
        newValues: values,
      );
      await _removeGlobalRules(ref, diff.remove);
      await moduleStore.setArgumentValues(current.id, values);
      await _addGlobalRules(ref, diff.add);
    }
    await _syncMitm(ref);
  }

  @visibleForTesting
  static ({List<String> remove, List<String> add}) moduleRulesDiff({
    required String? oldRaw,
    required Map<String, String> oldValues,
    required String newRaw,
    required Map<String, String> newValues,
  }) {
    final remove = oldRaw == null
        ? const <String>[]
        : parseSgmoduleWithArguments(oldRaw, oldValues).rules;
    final add = parseSgmoduleWithArguments(newRaw, newValues).rules;
    return (remove: remove, add: add);
  }

  /// Re-sync the MITM proxy; safe to call when the core is not running.
  static Future<void> _syncMitm(WidgetRef ref) async {
    try {
      await ref.read(coreActionProvider.notifier).syncMitm();
    } catch (_) {}
  }

  /// Download a `.sgmodule` from a remote URL and import it.
  static Future<ModuleInfo?> importModuleFromUrl(
    WidgetRef ref, {
    required String url,
  }) async {
    final response = await request.getTextResponseForUrl(url);
    final raw = response.data ?? '';
    if (raw.isEmpty) return null;
    return importModule(ref, raw: raw, fileName: fileNameFromUrl(url));
  }

  static String fileNameFromUrl(String url) {
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
    final modules = await moduleStore.list();
    final current = modules.where((e) => e.id == info.id).firstOrNull ?? info;
    if (current.ruleSetRules.isNotEmpty) {
      if (enabled) {
        await _addGlobalRules(ref, current.ruleSetRules);
        final inline = await moduleStore.readInlineRules(current.id);
        if (inline.isNotEmpty) {
          await _addGlobalRules(ref, inline);
        }
      } else {
        await _removeGlobalRules(ref, current.ruleSetRules);
        final inline = await moduleStore.readInlineRules(current.id);
        if (inline.isNotEmpty) {
          await _removeGlobalRules(ref, inline);
        }
      }
      return;
    }
    final raw = await moduleStore.readRaw(current.id);
    if (raw == null) return;
    final Sgmodule parsed = parseSgmoduleWithArguments(
      raw,
      current.argumentValues,
    );
    if (parsed.rules.isEmpty) return;
    if (enabled) {
      await _addGlobalRules(ref, parsed.rules);
    } else {
      await _removeGlobalRules(ref, parsed.rules);
    }
  }

  static List<Map<String, dynamic>> parseLinkList(String text) {
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
    String label, {
    Map<String, String> hosts = const {},
    List<String> urlRewrites = const [],
    List<String> headerRewrites = const [],
    bool mitmEnabled = false,
    List<String> mitmHostnames = const [],
  }) async {
    final core = ref.read(coreHandlerProvider);
    final profile = await Profile.normal(label: label)
        .copyWith(
          hosts: hosts,
          urlRewrites: urlRewrites,
          headerRewrites: headerRewrites,
          mitmEnabled: mitmEnabled,
          mitmHostnames: mitmHostnames,
        )
        .saveFile(
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
