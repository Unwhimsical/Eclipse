part of '../action.dart';

@Riverpod(keepAlive: true)
class ProfilesAction extends _$ProfilesAction {
  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  void build() {}

  void updateCurrentSelectedMap(String groupName, String proxyName) {
    final currentProfile = ref.read(currentProfileProvider);
    if (currentProfile != null &&
        currentProfile.selectedMap[groupName] != proxyName) {
      final selectedMap = Map<String, String>.from(currentProfile.selectedMap)
        ..[groupName] = proxyName;
      ref
          .read(profilesProvider.notifier)
          .put(currentProfile.copyWith(selectedMap: selectedMap));
    }
  }

  Future<void> deleteProfile(int id) async {
    await ref.read(profilesProvider.notifier).del(id);
    await clearEffect(id);
    final currentProfileId = ref.read(currentProfileIdProvider);
    if (currentProfileId == id) {
      final profiles = ref.read(profilesProvider);
      if (profiles.isNotEmpty) {
        final updateId = profiles.first.id;
        ref.read(currentProfileIdProvider.notifier).value = updateId;
      } else {
        ref.read(currentProfileIdProvider.notifier).value = null;
        unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
      }
    }
  }

  Future<String> validateConfigWithData(String data) async {
    return _core.validateConfigWithData(data);
  }

  Future<void> autoUpdateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (!profile.autoUpdate) continue;
      final isNotNeedUpdate = profile.lastUpdateDate
          ?.add(profile.autoUpdateDuration)
          .isBeforeNow;
      if (isNotNeedUpdate == false || profile.type == ProfileType.file) {
        continue;
      }
      try {
        await updateProfile(profile);
      } catch (e) {
        commonPrint.log(compactError(e), logLevel: LogLevel.warning);
      }
    }
  }

  void putProfile(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (ref.read(currentProfileIdProvider) != null) return;
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  Future<void> updateProfiles() async {
    for (final profile in ref.read(profilesProvider)) {
      if (profile.type == ProfileType.file) continue;
      await updateProfile(profile);
    }
  }

  Future<void> updateProfile(
    Profile profile, {
    bool showLoading = false,
  }) async {
    final operation = showLoading
        ? ref.read(updatingKeysProvider.notifier).start(profile.updatingKey)
        : null;
    try {
      ref.read(profilesProvider.notifier).put(profile);
      final newProfile = await profile.update(
        validate: (path) => _core.validateConfig(path),
      );
      ref.read(profilesProvider.notifier).put(newProfile);
      if (profile.id == ref.read(currentProfileIdProvider)) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    } finally {
      if (operation != null) {
        ref
            .read(updatingKeysProvider.notifier)
            .stop(profile.updatingKey, operation);
      }
    }
  }

  Future<void> addProfileFormFile({WidgetRef? widgetRef}) async {
    final platformFile = await globalState.safeRun(picker.pickerFile);
    if (platformFile == null) return;
    final bytes = await platformFile.readBytes();
    globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ref.read(currentPageLabelProvider.notifier).toProfiles();
    final handled = await globalState.loadingRun<bool>(
      tag: LoadingTag.profiles,
      () => _importPickedFile(platformFile.name, bytes, widgetRef),
      title: currentAppLocalizations.addProfile,
    );
    if (handled == true) return;
    final profile = await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () async {
        return Profile.normal(
          label: platformFile.name,
        ).saveFile(bytes, validate: (path) => _core.validateConfig(path));
      },
      title: currentAppLocalizations.addProfile,
    );
    if (profile != null) {
      putProfile(profile);
    }
  }

  /// Routes a picked `.conf`/`.sgmodule` to the Shadowrocket importers.
  /// Needs the caller's [WidgetRef]; without it falls back to Clash YAML.
  Future<bool> _importPickedFile(
    String fileName,
    Uint8List bytes,
    WidgetRef? widgetRef,
  ) async {
    if (widgetRef == null) return false;
    final text = _tryDecodeText(bytes);
    if (text == null) return false;
    final lowerName = fileName.toLowerCase();
    final appLocalizations = currentAppLocalizations;
    if (lowerName.endsWith('.sgmodule') || isSgmoduleText(text)) {
      final info = await globalState.safeRun(
        () => ShadowrocketImport.importModule(
          widgetRef,
          raw: text,
          fileName: fileName,
        ),
      );
      dialogs.showNotifier(
        info?.name ?? appLocalizations.clipboardImportFailed,
        level: info == null ? MessageLevel.warning : MessageLevel.success,
      );
      return true;
    }
    if (lowerName.endsWith('.conf') || isShadowrocketConfText(text)) {
      final label = await globalState.safeRun(
        () => ShadowrocketImport.importConf(
          widgetRef,
          content: text,
          fileName: fileName,
        ),
      );
      dialogs.showNotifier(
        label ?? appLocalizations.clipboardImportFailed,
        level: label == null ? MessageLevel.warning : MessageLevel.success,
      );
      return true;
    }
    return false;
  }

  String? _tryDecodeText(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProfileFormURL(String url, {WidgetRef? widgetRef}) async {
    if (globalState.navigatorKey.currentState?.canPop() ?? false) {
      globalState.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    ref.read(currentPageLabelProvider.notifier).value = PageLabel.config;
    await globalState.loadingRun(
      tag: LoadingTag.profiles,
      () => _importFromUrl(url, widgetRef),
      title: currentAppLocalizations.addProfile,
    );
  }

  /// Downloads [url] once, then routes Shadowrocket formats to importers.
  Future<void> _importFromUrl(String url, WidgetRef? widgetRef) async {
    final response = await request.getFileResponseForUrl(url);
    final bytes = response.data ?? Uint8List.fromList([]);
    final text = _tryDecodeText(bytes);
    final appLocalizations = currentAppLocalizations;
    final lowerUrl = url.toLowerCase();
    if (widgetRef != null &&
        text != null &&
        (lowerUrl.endsWith('.sgmodule') || isSgmoduleText(text))) {
      final info = await ShadowrocketImport.importModule(
        widgetRef,
        raw: text,
        fileName: ShadowrocketImport.fileNameFromUrl(url),
      );
      dialogs.showNotifier(
        info?.name ?? appLocalizations.clipboardImportFailed,
        level: info == null ? MessageLevel.warning : MessageLevel.success,
      );
      return;
    }
    if (widgetRef != null &&
        text != null &&
        (lowerUrl.endsWith('.conf') || isShadowrocketConfText(text))) {
      final label = await ShadowrocketImport.importConf(
        widgetRef,
        content: text,
        fileName: ShadowrocketImport.fileNameFromUrl(url),
      );
      dialogs.showNotifier(
        label ?? appLocalizations.clipboardImportFailed,
        level: label == null ? MessageLevel.warning : MessageLevel.success,
      );
      return;
    }
    final profile = await Profile.normal(
      url: url,
    ).applyResponse(response, validate: (path) => _core.validateConfig(path));
    putProfile(profile);
  }

  void setProfileAndAutoApply(Profile profile) {
    ref.read(profilesProvider.notifier).put(profile);
    if (profile.id == ref.read(currentProfileIdProvider)) {
      ref.read(setupActionProvider.notifier).applyProfileDebounce();
    }
  }

  Future<void> addProfileFormQrCode() async {
    final url = await globalState.safeRun(picker.pickerConfigQRCode);
    if (url == null) return;
    unawaited(addProfileFormURL(url));
  }

  void reorder(List<Profile> profiles) {
    ref.read(profilesProvider.notifier).reorder(profiles);
  }

  Future<void> clearEffect(int profileId) async {
    final profilePath = await appPath.getProfilePath(profileId.toString());
    final profileFile = File(profilePath);
    final isExists = await profileFile.exists();
    if (isExists) {
      await profileFile.safeDelete(recursive: true);
    }
    try {
      final error = await _core.clearEffect(profileId);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    } catch (error) {
      commonPrint.log(
        'clearEffect($profileId) failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }
}
