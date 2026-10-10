import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:path_provider/path_provider.dart';

class UpdateAsset {
  final String name;
  final String downloadUrl;
  final int size;

  const UpdateAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  factory UpdateAsset.fromJson(Map<String, dynamic> json) {
    return UpdateAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Filename fragment for this platform, e.g. `windows-amd64-setup.exe`.
/// Null on iOS (App Store distribution, no in-app update).
String? _platformAssetFragment() {
  if (system.isIOS) return null;
  final arch = Abi.current().toString().split('.').last;
  final archName = switch (arch) {
    'arm64' => 'arm64',
    'x64' => 'amd64',
    'arm' => 'armeabi-v7a',
    'ia64' => 'x86_64',
    _ => null,
  };
  if (archName == null) return null;
  if (system.isWindows) return 'windows-$archName-setup.exe';
  if (system.isMacOS) return 'macos-$archName.dmg';
  if (system.isLinux) return 'linux-$archName.AppImage';
  if (system.isAndroid) {
    final abi = switch (archName) {
      'arm64' => 'arm64-v8a',
      'armeabi-v7a' => 'armeabi-v7a',
      'amd64' => 'x86_64',
      _ => null,
    };
    if (abi == null) return null;
    return 'android-$abi.apk';
  }
  return null;
}

/// Pick the release asset for this platform/arch, null when none matches.
UpdateAsset? findUpdateAsset(List<dynamic> assets) {
  final fragment = _platformAssetFragment();
  if (fragment == null) return null;
  for (final item in assets) {
    if (item is! Map<String, dynamic>) continue;
    final name = item['name'] as String? ?? '';
    if (name.endsWith(fragment)) {
      return UpdateAsset.fromJson(item);
    }
  }
  return null;
}

Future<File> downloadUpdateAsset(
  UpdateAsset asset, {
  void Function(double progress)? onProgress,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${asset.name}');
  final dio = Dio();
  await dio.download(
    asset.downloadUrl,
    file.path,
    onReceiveProgress: (received, total) {
      if (total > 0) onProgress?.call(received / total);
    },
  );
  return file;
}

/// Hand [file] to the OS installer: run setup.exe, mount dmg,
/// trigger Android package installer.
Future<void> installUpdateFile(File file) async {
  if (system.isAndroid) {
    await app?.openFile(file.path);
    return;
  }
  if (system.isWindows) {
    await Process.start(file.path, []);
    return;
  }
  if (system.isMacOS) {
    await Process.run('open', [file.path]);
    return;
  }
  if (system.isLinux) {
    await Process.run('chmod', ['+x', file.path]);
    await Process.run('xdg-open', [file.path]);
  }
}
