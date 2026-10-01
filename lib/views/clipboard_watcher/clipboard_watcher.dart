import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardLinkWatcher extends ConsumerStatefulWidget {
  final Widget child;
  final Future<void> Function(String link)? onLinkDetected;

  const ClipboardLinkWatcher({
    super.key,
    required this.child,
    this.onLinkDetected,
  });

  @override
  ConsumerState<ClipboardLinkWatcher> createState() =>
      _ClipboardLinkWatcherState();
}

class _ClipboardLinkWatcherState extends ConsumerState<ClipboardLinkWatcher>
    with WidgetsBindingObserver {
  final _seen = <String>{};
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    if (_checking || !mounted) return;
    _checking = true;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text == null || text.isEmpty || _seen.contains(text)) return;
      final proxy = parseShareLink(text);
      if (proxy == null) return;
      _seen.add(text);
      if (!mounted) return;
      await _showImportDialog(text, proxy);
    } finally {
      _checking = false;
    }
  }

  Future<void> _showImportDialog(
    String link,
    Map<String, dynamic> proxy,
  ) async {
    final appLocalizations = context.appLocalizations;
    final name = proxy['name']?.toString() ?? '';
    final type = proxy['type']?.toString() ?? '';
    final confirmed = await dialogs.showMessage(
      context: context,
      title: appLocalizations.clipboardLinkTitle,
      message: TextSpan(
        text:
            '$name${type.isEmpty ? '' : ' ($type)'}\n\n'
            '${appLocalizations.clipboardLinkMessage}',
      ),
      confirmText: appLocalizations.clipboardLinkImport,
      cancelText: appLocalizations.cancel,
    );
    if (confirmed != true || !mounted) return;
    final handler = widget.onLinkDetected;
    if (handler != null) {
      await handler(link);
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    dialogs.showNotifier(
      appLocalizations.clipboardLinkCopied,
      level: MessageLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
