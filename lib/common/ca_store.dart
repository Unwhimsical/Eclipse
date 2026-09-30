import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'path.dart';

const _caMetaKey = 'eclipse_ca_meta';

/// CA certificate metadata.
class CaMeta {
  final DateTime createdAt;
  final DateTime expiresAt;
  final String sha256;

  const CaMeta({
    required this.createdAt,
    required this.expiresAt,
    required this.sha256,
  });

  Map<String, Object?> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'sha256': sha256,
  };

  factory CaMeta.fromJson(Map<String, Object?> json) => CaMeta(
    createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
    expiresAt:
        DateTime.tryParse('${json['expiresAt']}') ??
        DateTime.now().add(const Duration(days: 3650)),
    sha256: '${json['sha256'] ?? ''}',
  );
}

/// Manages the MITM CA: generation (via Go core), storage and metadata.
class CaStore {
  static CaStore? _instance;

  CaStore._internal();

  factory CaStore() {
    _instance ??= CaStore._internal();
    return _instance!;
  }

  Future<String> _caDir() async {
    final dir = Directory(join(await appPath.homeDirPath, 'ca'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> get certPath async => join(await _caDir(), 'ca.crt');
  Future<String> get keyPath async => join(await _caDir(), 'ca.key');

  Future<bool> get exists async => File(await certPath).exists();

  Future<String?> readCert() async {
    final file = File(await certPath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<CaMeta?> readMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_caMetaKey);
    if (raw == null) return null;
    try {
      return CaMeta.fromJson(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  /// Save a generated CA (cert/key PEM) and record metadata.
  Future<void> save({required String cert, required String key}) async {
    await File(await certPath).writeAsString(cert);
    await File(await keyPath).writeAsString(key);
    final fingerprint = sha256.convert(utf8.encode(cert)).toString();
    final now = DateTime.now();
    final meta = CaMeta(
      createdAt: now,
      expiresAt: now.add(const Duration(days: 3650)),
      sha256: fingerprint,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_caMetaKey, json.encode(meta.toJson()));
  }

  Future<void> delete() async {
    final cert = File(await certPath);
    final key = File(await keyPath);
    if (await cert.exists()) await cert.delete();
    if (await key.exists()) await key.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_caMetaKey);
  }
}

final caStore = CaStore();
