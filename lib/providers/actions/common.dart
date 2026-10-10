part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  CoreController get _core => ref.read(coreHandlerProvider);
  bool _isUpdatingTraffic = false;

  @override
  void build() {}

  void toggleRunning() {
    final running = !ref.read(isStartProvider);
    unawaited(
      globalState.safeRun(
        () => ref
            .read(setupActionProvider.notifier)
            .setRunning(
              running,
              initialize: running && !ref.read(initProvider),
            ),
      ),
    );
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  Future<void> updateTraffic() async {
    if (_isUpdatingTraffic) {
      return;
    }
    _isUpdatingTraffic = true;
    try {
      final onlyStatisticsProxy = ref.read(
        appSettingProvider.select((state) => state.onlyStatisticsProxy),
      );
      final [traffic, totalTraffic] = await Future.wait([
        _readTraffic(() => _core.getTraffic(onlyStatisticsProxy)),
        _readTraffic(() => _core.getTotalTraffic(onlyStatisticsProxy)),
      ]);
      if (traffic != null) {
        ref.read(trafficsProvider.notifier).addTraffic(traffic);
      }
      if (totalTraffic != null) {
        ref.read(totalTrafficProvider.notifier).value = totalTraffic;
      }
    } finally {
      _isUpdatingTraffic = false;
    }
  }

  Future<Traffic?> _readTraffic(Future<Traffic> Function() request) async {
    try {
      return await request();
    } catch (error) {
      commonPrint.log(
        'updateTraffic error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  Future<bool> autoCheckUpdate() async {
    if (!ref.read(appSettingProvider).autoCheckUpdate) return false;
    final res = await request.checkForUpdate();
    await checkUpdateResultHandle(data: res);
    return res != null;
  }

  TextSpan _releaseSpan(BuildContext context, String tagName, String? body) {
    final textTheme = context.textTheme;
    final version = parseReleaseChangelog(body);
    return TextSpan(
      text: '$tagName \n',
      style: textTheme.headlineSmall,
      children: version == null
          ? [
              TextSpan(text: '\n', style: textTheme.bodyMedium),
              for (final submit in parseReleaseBody(body))
                TextSpan(text: '- $submit \n', style: textTheme.bodyMedium),
            ]
          : _changelogSpans(context, version),
    );
  }

  List<TextSpan> _changelogSpans(
    BuildContext context,
    ChangelogVersion version,
  ) {
    final textTheme = context.textTheme;
    return [
      for (final group in version.visibleGroups) ...[
        TextSpan(
          text:
              '\n${changelogGroupTitle(currentAppLocalizations, group.type)}\n',
          style: textTheme.labelLarge?.copyWith(
            color: group.type == ChangelogType.breaking
                ? context.colorScheme.error
                : context.colorScheme.primary,
          ),
        ),
        for (final entry in group.entries)
          TextSpan(text: '• ${entry.text}\n', style: textTheme.bodyMedium),
      ],
    ];
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final assets = data['assets'] as List<dynamic>? ?? const [];
      final updateAsset = findUpdateAsset(assets);
      final res = await dialogs.showCommonDialog<String>(
        child: Builder(
          builder: (context) {
            final appLocalizations = context.appLocalizations;
            return CommonDialog(
              title: appLocalizations.discoverNewVersion,
              child: Text.rich(
                _releaseSpan(
                  context,
                  data['tag_name'] as String,
                  data['body'] as String?,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  child: Text(
                    isUser
                        ? appLocalizations.cancel
                        : appLocalizations.noLongerRemind,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('browser'),
                  child: Text(appLocalizations.goDownload),
                ),
                if (updateAsset != null)
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop('download'),
                    child: Text(appLocalizations.download),
                  ),
              ],
            );
          },
        ),
      );
      if (res == 'browser') {
        unawaited(
          launchUrl(
            Uri.parse('https://github.com/$repository/releases/latest'),
          ),
        );
      } else if (res == 'download' && updateAsset != null) {
        unawaited(_downloadAndInstall(updateAsset));
      } else if (!isUser && res == 'cancel') {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: false));
      }
    } else if (isUser) {
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.checkUpdate,
          message: TextSpan(text: currentAppLocalizations.checkUpdateError),
        ),
      );
    }
  }

  /// Download the update asset with progress UI, then hand it to the OS
  /// installer. Failures fall back to opening the releases page.
  Future<void> _downloadAndInstall(UpdateAsset asset) async {
    final context = globalState.navigatorKey.currentContext;
    if (context == null) return;
    final progress = ValueNotifier<double>(0);
    try {
      unawaited(
        dialogs.showCommonDialog(
          dismissible: false,
          child: CommonDialog(
            title: currentAppLocalizations.download,
            child: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (_, value, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: value),
                  const SizedBox(height: 12),
                  Text('${(value * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ),
      );
      final file = await downloadUpdateAsset(
        asset,
        onProgress: (v) => progress.value = v,
      );
      if (context.mounted) Navigator.of(context).pop();
      await installUpdateFile(file);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      commonPrint.log('update download failed: $e', logLevel: LogLevel.warning);
      unawaited(
        launchUrl(Uri.parse('https://github.com/$repository/releases/latest')),
      );
    } finally {
      progress.dispose();
    }
  }
}
