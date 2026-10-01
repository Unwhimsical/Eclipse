import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddProfileView extends ConsumerWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    unawaited(
      ref
          .read(profilesActionProvider.notifier)
          .addProfileFormFile(widgetRef: ref),
    );
  }

  Future<void> _toScan(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (system.isDesktop) {
      unawaited(profilesAction.addProfileFormQrCode());
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(profilesAction.addProfileFormURL(url, widgetRef: ref));
      });
    }
  }

  Future<void> _toAdd(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final url = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        value: '',
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url != null) {
      unawaited(profilesAction.addProfileFormURL(url, widgetRef: ref));
    }
  }

  Future<void> _handlePasteImport(WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      dialogs.showNotifier(
        appLocalizations.clipboardImportFailed,
        level: MessageLevel.warning,
      );
      return;
    }
    if (isSgmoduleText(text)) {
      final info = await globalState.safeRun(
        () => ShadowrocketImport.importModule(ref, raw: text),
      );
      dialogs.showNotifier(
        info?.name ?? appLocalizations.clipboardImportFailed,
        level: info == null ? MessageLevel.warning : MessageLevel.success,
      );
      return;
    }
    if (isShadowrocketConfText(text)) {
      final label = await globalState.safeRun(
        () => ShadowrocketImport.importConf(ref, content: text),
      );
      dialogs.showNotifier(
        label ?? appLocalizations.clipboardImportFailed,
        level: label == null ? MessageLevel.warning : MessageLevel.success,
      );
      return;
    }
    final label = await ShadowrocketImport.importShareLinks(ref, text: text);
    dialogs.showNotifier(
      label ?? appLocalizations.clipboardImportFailed,
      level: label == null ? MessageLevel.warning : MessageLevel.success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EclipseSection(
          children: [
            EclipseTile(
              icon: Icons.qr_code_rounded,
              title: appLocalizations.qrcode,
              subtitle: appLocalizations.qrcodeDesc,
              showChevron: true,
              onTap: () => _toScan(ref),
            ),
            EclipseTile(
              icon: Icons.content_paste_rounded,
              title: appLocalizations.pasteImport,
              subtitle: appLocalizations.pasteImportDesc,
              showChevron: true,
              onTap: () => _handlePasteImport(ref),
            ),
            EclipseTile(
              icon: Icons.upload_file_outlined,
              title: appLocalizations.file,
              subtitle: appLocalizations.fileDesc,
              showChevron: true,
              onTap: () => _handleAddProfileFormFile(ref),
            ),
            EclipseTile(
              icon: Icons.cloud_download_outlined,
              title: appLocalizations.url,
              subtitle: appLocalizations.urlDesc,
              showChevron: true,
              onTap: () => _toAdd(ref),
            ),
          ],
        ),
      ],
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final _urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: _urlController,
              decoration: InputDecoration(labelText: appLocalizations.url),
            ),
          ],
        ),
      ),
    );
  }
}
