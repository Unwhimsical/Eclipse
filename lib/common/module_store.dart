import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/module.dart';
import 'path.dart';
import 'shadowrocket.dart';
import 'yaml.dart';

const _modulesIndexKey = 'pigcat_modules_index';

/// Above this many rules, a module uses file-based `rule-providers` instead
/// of inlining every rule into global rules.
const ruleProviderThreshold = 2000;

/// File + SharedPreferences backed store for imported `.sgmodule` files.
/// No database migration needed.
class ModuleStore {
  static ModuleStore? _instance;

  ModuleStore._internal();

  factory ModuleStore() {
    _instance ??= ModuleStore._internal();
    return _instance!;
  }

  Future<String> _modulesDir() async {
    final dir = Directory(join(await appPath.homeDirPath, 'modules'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> moduleFilePath(String id) async {
    return join(await _modulesDir(), '$id.sgmodule');
  }

  /// Path for a module's rule-provider file: `<id>_<policy>.yaml`.
  Future<String> ruleProviderPath(String id, String policy) async {
    return join(await _modulesDir(), '${id}_$policy.yaml');
  }

  /// Write domain rules grouped by policy into `rule-providers` YAML files.
  /// Returns the `RULE-SET` rule strings to add to global rules.
  Future<List<String>> _writeRuleProviders(
    String id,
    List<String> rules,
  ) async {
    final byPolicy = <String, Set<String>>{};
    final leftover = <String>[];
    for (final rule in rules) {
      final parts = rule.split(',');
      if (parts.length < 3) {
        leftover.add(rule);
        continue;
      }
      final type = parts[0].trim().toUpperCase();
      final value = parts[1].trim();
      final policy = parts[2].trim().toUpperCase();
      final domain = switch (type) {
        'DOMAIN' => value,
        'DOMAIN-SUFFIX' => '+.$value',
        _ => null,
      };
      if (domain == null || domain.isEmpty) {
        leftover.add(rule);
        continue;
      }
      byPolicy.putIfAbsent(policy, () => <String>{}).add(domain);
    }
    final ruleSetRules = <String>[];
    for (final entry in byPolicy.entries) {
      final policy = entry.key;
      final domains = entry.value.toList()..sort();
      final path = await ruleProviderPath(id, policy);
      await File(path).writeAsString(yaml.encode({'payload': domains}));
      ruleSetRules.add('RULE-SET,${id}_$policy,$policy');
    }
    // Non-domain rules that couldn't go into providers are returned for
    // inline import by the caller.
    if (leftover.isNotEmpty) {
      // Stored alongside so setModuleEnabled can re-apply them.
      final path = await ruleProviderPath(id, 'INLINE');
      await File(path).writeAsString(leftover.join('\n'));
    }
    return ruleSetRules;
  }

  /// Read back non-domain rules stored for a large module.
  Future<List<String>> readInlineRules(String id) async {
    final file = File(await ruleProviderPath(id, 'INLINE'));
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return const LineSplitter()
        .convert(content)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<List<ModuleInfo>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_modulesIndexKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw);
      if (list is! List) return [];
      return list
          .whereType<Map<String, Object?>>()
          .map(ModuleInfo.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveIndex(List<ModuleInfo> modules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _modulesIndexKey,
      json.encode(modules.map((e) => e.toJson()).toList()),
    );
  }

  Future<String?> readRaw(String id) async {
    final file = File(await moduleFilePath(id));
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// Import a `.sgmodule` text. Returns the created [ModuleInfo].
  /// Modules with more than [ruleProviderThreshold] rules use file-based
  /// `rule-providers`; [ModuleInfo.ruleSetRules] holds the `RULE-SET` rules
  /// the caller should add to global rules instead of every rule.
  Future<ModuleInfo> import(String raw, {String? fileName}) async {
    final Sgmodule parsed = parseSgmodule(raw);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final name = parsed.name.isEmpty
        ? (fileName?.replaceAll('.sgmodule', '') ?? 'Module $id')
        : parsed.name;
    await File(await moduleFilePath(id)).writeAsString(raw);
    List<String> ruleSetRules = const [];
    if (parsed.rules.length > ruleProviderThreshold) {
      ruleSetRules = await _writeRuleProviders(id, parsed.rules);
    }
    final info = ModuleInfo(
      id: id,
      name: name,
      desc: parsed.desc,
      author: parsed.author,
      ruleCount: parsed.rules.length,
      hostCount: parsed.hosts.length,
      rewriteCount: parsed.urlRewrites.length,
      scriptCount: parsed.scripts.length,
      needsMitm: parsed.needsMitm,
      importDate: DateTime.now(),
      ruleSetRules: ruleSetRules,
    );
    final modules = await list();
    modules.add(info);
    await _saveIndex(modules);
    return info;
  }

  Future<void> toggle(String id, bool enabled) async {
    final modules = await list();
    final index = modules.indexWhere((e) => e.id == id);
    if (index < 0) return;
    modules[index] = modules[index].copyWith(enabled: enabled);
    await _saveIndex(modules);
  }

  Future<void> delete(String id) async {
    final modules = (await list()).where((e) => e.id != id).toList();
    await _saveIndex(modules);
    final dir = await _modulesDir();
    for (final name in [
      '$id.sgmodule',
      '${id}_PROXY.yaml',
      '${id}_DIRECT.yaml',
      '${id}_REJECT.yaml',
      '${id}_INLINE',
    ]) {
      final file = File(join(dir, name));
      if (await file.exists()) {
        await file.delete();
      }
    }
    // Clean up any other provider files for this module.
    await for (final entity in Directory(dir).list()) {
      if (entity is File) {
        final base = basename(entity.path);
        if (base.startsWith('${id}_') && base.endsWith('.yaml')) {
          await entity.delete();
        }
      }
    }
  }

  Future<List<ModuleInfo>> enabledModules() async {
    return (await list()).where((e) => e.enabled).toList();
  }
}

final moduleStore = ModuleStore();
