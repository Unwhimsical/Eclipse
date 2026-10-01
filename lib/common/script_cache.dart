import 'dart:io';

import 'package:path/path.dart';

import 'path.dart';
import 'string.dart';

/// On-disk cache for downloaded `[Script]` bodies, keyed by URL md5.
/// Entries expire after [ttl]; [getStale] still serves them for fail-open.
/// Capped at [maxEntries] files (oldest evicted); [clear] on module update.
class ScriptCache {
  static const ttl = Duration(hours: 24);
  static const maxEntries = 200;

  Future<Directory> _dir() async {
    final dir = Directory(
      join(await appPath.homeDirPath, 'modules', 'script_cache'),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileName(String url) => '${url.toMd5()}.js';

  Future<String?> get(String url) async {
    final file = File(join((await _dir()).path, _fileName(url)));
    if (!await file.exists()) return null;
    final stat = await file.stat();
    if (DateTime.now().difference(stat.modified) > ttl) return null;
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  /// Last known body regardless of age; null when nothing was ever cached.
  Future<String?> getStale(String url) async {
    final file = File(join((await _dir()).path, _fileName(url)));
    if (!await file.exists()) return null;
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  Future<void> put(String url, String content) async {
    if (content.isEmpty) return;
    final dir = await _dir();
    await File(join(dir.path, _fileName(url))).writeAsString(content);
    await _evictIfNeeded(dir);
  }

  Future<void> _evictIfNeeded(Directory dir) async {
    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.js')) files.add(entity);
    }
    if (files.length <= maxEntries) return;
    final stats = <File, DateTime>{};
    for (final file in files) {
      try {
        stats[file] = (await file.stat()).modified;
      } catch (_) {
        stats[file] = DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    files.sort((a, b) => stats[a]!.compareTo(stats[b]!));
    for (var i = 0; i < files.length - maxEntries; i++) {
      try {
        await files[i].delete();
      } catch (_) {}
    }
  }

  Future<void> clear() async {
    final dir = Directory(
      join(await appPath.homeDirPath, 'modules', 'script_cache'),
    );
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is File) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }
}
