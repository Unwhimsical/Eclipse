import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/module.dart';
import 'path.dart';
import 'script_cache.dart';
import 'shadowrocket.dart';
import 'yaml.dart';

const _modulesIndexKey = 'eclipse_modules_index';

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
    List<ModuleInfo>? indexed;
    try {
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw);
        if (decoded is List) {
          indexed = decoded
              .whereType<Map<String, Object?>>()
              .map(ModuleInfo.fromJson)
              .toList();
        }
      }
    } catch (_) {
      indexed = null;
    }
    if (indexed != null && indexed.isNotEmpty) return indexed;
    final recovered = await _recoverSafely();
    if (recovered.isEmpty) return [];
    await _saveIndex(recovered);
    return recovered;
  }

  Future<List<ModuleInfo>> _recoverSafely() async {
    try {
      return await _recoverFromFiles();
    } catch (_) {
      return [];
    }
  }

  Future<List<ModuleInfo>> _recoverFromFiles() async {
    if (!appPath.dataDir.isCompleted) return [];
    final dir = Directory(await _modulesDir());
    if (!await dir.exists()) return [];
    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && basename(entity.path).endsWith('.sgmodule')) {
        files.add(entity);
      }
    }
    if (files.isEmpty) return [];
    final stats = <File, DateTime>{};
    for (final file in files) {
      try {
        stats[file] = (await file.stat()).modified;
      } catch (_) {
        stats[file] = DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    files.sort((a, b) {
      final byTime = stats[a]!.compareTo(stats[b]!);
      return byTime != 0 ? byTime : a.path.compareTo(b.path);
    });
    final recovered = <ModuleInfo>[];
    for (final file in files) {
      try {
        final raw = await file.readAsString();
        final parsed = await parseSgmoduleWithArgumentsBackground(
          raw,
          const {},
        );
        final id = basenameWithoutExtension(file.path);
        recovered.add(
          ModuleInfo(
            id: id,
            name: parsed.name.isEmpty ? id : parsed.name,
            desc: parsed.desc,
            author: parsed.author,
            ruleCount: parsed.rules.length,
            hostCount: parsed.hosts.length,
            rewriteCount: parsed.urlRewrites.length,
            scriptCount: parsed.scripts.length,
            needsMitm: parsed.needsMitm,
            importDate: stats[file]!,
            ruleSetRules: await _scanRuleSetRules(id),
            rulesAppend: parsed.rulesAppend,
          ),
        );
      } catch (_) {
        continue;
      }
    }
    return recovered;
  }

  Future<List<String>> _scanRuleSetRules(String id) async {
    final dir = Directory(await _modulesDir());
    if (!await dir.exists()) return [];
    final rules = <String>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final base = basename(entity.path);
      if (!base.startsWith('${id}_') || !base.endsWith('.yaml')) continue;
      final policy = base.substring(id.length + 1, base.length - 5);
      if (policy.isEmpty || policy == 'INLINE') continue;
      rules.add('RULE-SET,${id}_$policy,$policy');
    }
    rules.sort();
    return rules;
  }

  Future<void> _saveIndex(List<ModuleInfo> modules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _modulesIndexKey,
      json.encode(modules.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveOrder(List<ModuleInfo> modules) => _saveIndex(modules);

  Future<String?> readRaw(String id) async {
    final file = File(await moduleFilePath(id));
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// Import a `.sgmodule` text. Returns the created [ModuleInfo].
  /// Modules with more than [ruleProviderThreshold] rules use file-based
  /// `rule-providers`; [ModuleInfo.ruleSetRules] holds the `RULE-SET` rules
  /// the caller should add to global rules instead of every rule.
  /// Parses in a background isolate to keep large imports off the UI thread.
  Future<ModuleInfo> import(String raw, {String? fileName}) async {
    final parsed = await parseSgmoduleWithArgumentsBackground(raw, const {});
    return importParsed(parsed, raw, fileName: fileName);
  }

  Future<ModuleInfo> importParsed(
    Sgmodule parsed,
    String raw, {
    String? fileName,
    String? sourceUrl,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final name = parsed.name.isEmpty
        ? (fileName?.replaceAll('.sgmodule', '') ?? 'Module $id')
        : parsed.name;
    final modules = await list();
    final filePath = await moduleFilePath(id);
    await File(filePath).writeAsString(raw);
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
      rulesAppend: parsed.rulesAppend,
      sourceUrl: sourceUrl,
    );
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

  Future<ModuleInfo?> findByName(String name) async {
    final modules = await list();
    final index = modules.indexWhere((e) => e.name == name);
    return index < 0 ? null : modules[index];
  }

  Future<void> setArgumentValues(String id, Map<String, String> values) async {
    final modules = await list();
    final index = modules.indexWhere((e) => e.id == id);
    if (index < 0) return;
    modules[index] = modules[index].copyWith(
      argumentValues: Map<String, String>.from(values),
    );
    await _saveIndex(modules);
  }

  /// User values are kept for keys the new file still declares; values for
  /// removed keys are dropped. Global rules are left to the caller.
  Future<ModuleInfo?> updateContent(
    String id,
    String newRaw, {
    String? sourceUrl,
  }) async {
    final modules = await list();
    final index = modules.indexWhere((e) => e.id == id);
    if (index < 0) return null;
    final old = modules[index];
    final merged = <String, String>{};
    for (final arg in scanModuleArguments(newRaw)) {
      final value = old.argumentValues[arg.key];
      if (value != null) merged[arg.key] = value;
    }
    await File(await moduleFilePath(id)).writeAsString(newRaw);
    await _clearRuleProviders(id);
    await ScriptCache().clear();
    final parsed = await parseSgmoduleWithArgumentsBackground(newRaw, merged);
    List<String> ruleSetRules = const [];
    if (parsed.rules.length > ruleProviderThreshold) {
      ruleSetRules = await _writeRuleProviders(id, parsed.rules);
    }
    final info = old.copyWith(
      name: parsed.name.isEmpty ? old.name : parsed.name,
      desc: parsed.desc,
      author: parsed.author,
      sourceUrl: sourceUrl,
      ruleCount: parsed.rules.length,
      hostCount: parsed.hosts.length,
      rewriteCount: parsed.urlRewrites.length,
      scriptCount: parsed.scripts.length,
      needsMitm: parsed.needsMitm,
      ruleSetRules: ruleSetRules,
      rulesAppend: parsed.rulesAppend,
      argumentValues: merged,
    );
    modules[index] = info;
    await _saveIndex(modules);
    return info;
  }

  Future<List<String>> rewriteRuleProviders(
    String id,
    List<String> substitutedRules,
  ) async {
    await _clearRuleProviders(id);
    final ruleSetRules = substitutedRules.length > ruleProviderThreshold
        ? await _writeRuleProviders(id, substitutedRules)
        : const <String>[];
    final modules = await list();
    final index = modules.indexWhere((e) => e.id == id);
    if (index >= 0) {
      modules[index] = modules[index].copyWith(ruleSetRules: ruleSetRules);
      await _saveIndex(modules);
    }
    return ruleSetRules;
  }

  Future<void> _clearRuleProviders(String id) async {
    final dir = await _modulesDir();
    final direct = ['${id}_INLINE'];
    await for (final entity in Directory(dir).list()) {
      if (entity is File) {
        final base = basename(entity.path);
        if (base.startsWith('${id}_') &&
            (base.endsWith('.yaml') || direct.contains(base))) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> delete(String id) async {
    final modules = (await list()).where((e) => e.id != id).toList();
    await _saveIndex(modules);
    await ScriptCache().clear();
    final dir = await _modulesDir();
    final moduleFile = File(join(dir, '$id.sgmodule'));
    if (await moduleFile.exists()) {
      await moduleFile.delete();
    }
    await _clearRuleProviders(id);
  }

  Future<List<ModuleInfo>> enabledModules() async {
    return (await list()).where((e) => e.enabled).toList();
  }
}

final moduleStore = ModuleStore();
