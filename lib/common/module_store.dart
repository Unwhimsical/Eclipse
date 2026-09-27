import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/module.dart';
import 'path.dart';
import 'shadowrocket.dart';

const _modulesIndexKey = 'pigcat_modules_index';

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
  Future<ModuleInfo> import(String raw, {String? fileName}) async {
    final parsed = parseSgmodule(raw);
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final name = parsed.name.isEmpty
        ? (fileName?.replaceAll('.sgmodule', '') ?? 'Module $id')
        : parsed.name;
    await File(await moduleFilePath(id)).writeAsString(raw);
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
    final file = File(await moduleFilePath(id));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<ModuleInfo>> enabledModules() async {
    return (await list()).where((e) => e.enabled).toList();
  }
}

final moduleStore = ModuleStore();
