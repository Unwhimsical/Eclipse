import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wifi_share_server.dart';

class WifiUploadView extends ConsumerStatefulWidget {
  const WifiUploadView({super.key});

  @override
  ConsumerState<WifiUploadView> createState() => _WifiUploadViewState();
}

class _WifiUploadViewState extends ConsumerState<WifiUploadView> {
  final _server = WifiShareServer();
  bool _loading = true;
  bool _starting = false;
  String? _lanIp;
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _server.filesChanged.listen((_) => _refreshFiles());
    _init();
  }

  Future<void> _init() async {
    final lanIp = await getLocalIpAddress();
    if (!mounted) return;
    setState(() {
      _lanIp = lanIp;
      _loading = false;
    });
    await _refreshFiles();
  }

  Future<void> _refreshFiles() async {
    final files = await _server.listFiles();
    if (!mounted) return;
    setState(() => _files = files.whereType<File>().toList());
  }

  Future<void> _handleToggle(bool value) async {
    setState(() => _starting = true);
    try {
      if (value) {
        await _server.start();
      } else {
        await _server.stop();
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _handleImport() async {
    final file = await picker.pickerFile();
    if (file?.path == null) return;
    final name = p.basename(file!.path!);
    if (!isShareableName(name)) {
      if (!mounted) return;
      dialogs.showNotifier(
        context.appLocalizations.wifiUploadBadType,
        level: MessageLevel.warning,
      );
      return;
    }
    final target = File(p.join(await _server.shareDir, name));
    await File(file.path!).copy(target.path);
    await _refreshFiles();
  }

  Future<void> _handleDelete(File file) async {
    await file.delete();
    await _refreshFiles();
  }

  Future<void> _handleCopy(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    dialogs.showNotifier(
      context.appLocalizations.proxySharingCopied,
      level: MessageLevel.success,
    );
  }

  @override
  void dispose() {
    _server.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final running = _server.running;
    final address = running ? 'http://${_lanIp ?? ''}:${_server.port}' : '';
    return CommonScaffold(
      title: appLocalizations.wifiUpload,
      isLoading: _loading,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          generateSectionV2(
            items: [
              ListItem.toggle(
                title: Text(appLocalizations.wifiUploadSwitch),
                subtitle: Text(appLocalizations.wifiUploadDesc),
                value: running,
                onChanged: _starting ? null : _handleToggle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (running)
            generateSectionV2(
              items: [
                ListItem(
                  leading: const Icon(Icons.link_outlined),
                  title: Text(appLocalizations.wifiUploadAddress),
                  subtitle: Text(
                    address,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: appLocalizations.wifiUploadCopy,
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () => _handleCopy(address),
                  ),
                ),
                ListItem(
                  leading: const Icon(Icons.info_outline),
                  title: Text(appLocalizations.wifiUploadHowTo),
                ),
              ],
            )
          else
            generateSectionV2(
              items: [
                ListItem(
                  leading: const Icon(Icons.info_outline),
                  title: Text(appLocalizations.wifiUploadOffTip),
                ),
              ],
            ),
          const SizedBox(height: 16),
          generateSectionV2(
            title: appLocalizations.wifiUploadFiles,
            items: [
              if (_files.isEmpty)
                ListItem(
                  leading: const Icon(Icons.inbox_outlined),
                  title: Text(appLocalizations.wifiUploadEmpty),
                )
              else
                for (final file in _files)
                  ListItem(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(p.basename(file.path)),
                    trailing: IconButton(
                      tooltip: appLocalizations.wifiUploadDelete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _handleDelete(file),
                    ),
                  ),
              ListItem(
                leading: const Icon(Icons.add_outlined),
                title: Text(appLocalizations.wifiUploadImport),
                onTap: _handleImport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
