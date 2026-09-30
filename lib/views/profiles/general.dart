import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void updateGeneralSettings(
  WidgetRef ref,
  int profileId,
  GeneralSettings Function(GeneralSettings settings) update,
) {
  final profile = ref.read(profileProvider(profileId));
  if (profile == null) {
    return;
  }
  ref
      .read(profilesActionProvider.notifier)
      .putProfile(
        profile.copyWith(generalSettings: update(profile.generalSettings)),
      );
}

class _Ipv6DialogResult {
  final bool? value;

  const _Ipv6DialogResult(this.value);
}

class _Ipv6Dialog extends StatefulWidget {
  final bool? value;

  const _Ipv6Dialog({this.value});

  @override
  State<_Ipv6Dialog> createState() => _Ipv6DialogState();
}

class _Ipv6DialogState extends State<_Ipv6Dialog> {
  late bool? _groupValue;

  @override
  void initState() {
    super.initState();
    _groupValue = widget.value;
  }

  void _handleChanged(bool? value) {
    setState(() {
      _groupValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: 'IPv6',
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_Ipv6DialogResult(_groupValue));
          },
          child: Text(appLocalizations.submit),
        ),
      ],
      child: RadioGroup<bool?>(
        groupValue: _groupValue,
        onChanged: _handleChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListItem.radio(
              value: null,
              onTap: () => _handleChanged(null),
              title: Text(appLocalizations.ipv6FollowConfig),
            ),
            ListItem.radio(
              value: true,
              onTap: () => _handleChanged(true),
              title: Text(appLocalizations.ipv6On),
            ),
            ListItem.radio(
              value: false,
              onTap: () => _handleChanged(false),
              title: Text(appLocalizations.ipv6Off),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ipv6Item extends ConsumerWidget {
  final int profileId;

  const _Ipv6Item({required this.profileId});

  String _text(AppLocalizations appLocalizations, bool? value) {
    if (value == null) {
      return appLocalizations.ipv6FollowConfig;
    }
    return value ? appLocalizations.ipv6On : appLocalizations.ipv6Off;
  }

  Future<void> _handleShowDialog(
    BuildContext context,
    WidgetRef ref,
    bool? value,
  ) async {
    final result = await dialogs.showCommonDialog<_Ipv6DialogResult>(
      context: context,
      child: _Ipv6Dialog(value: value),
    );
    if (result == null) {
      return;
    }
    updateGeneralSettings(
      ref,
      profileId,
      (settings) => settings.copyWith(ipv6: result.value),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final value = ref.watch(
      profileProvider(
        profileId,
      ).select((profile) => profile?.generalSettings.ipv6),
    );
    return ListItem(
      leading: const Icon(Icons.lan_outlined),
      title: const Text('IPv6'),
      subtitle: Text(_text(appLocalizations, value)),
      onTap: () => _handleShowDialog(context, ref, value),
    );
  }
}

class _UnsupportedItem extends StatelessWidget {
  final String title;
  final bool? value;

  const _UnsupportedItem({required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final subtitle = value == null
        ? appLocalizations.coreUnsupported
        : '${value! ? appLocalizations.paramOn : appLocalizations.paramOff} '
              '(${appLocalizations.coreUnsupported})';
    return ListItem(
      leading: const Icon(Icons.block_outlined),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class GeneralSettingsView extends ConsumerStatefulWidget {
  final int profileId;

  const GeneralSettingsView({super.key, required this.profileId});

  @override
  ConsumerState<GeneralSettingsView> createState() =>
      _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends ConsumerState<GeneralSettingsView> {
  late SetupAction _setupAction;

  @override
  void initState() {
    super.initState();
    _setupAction = ref.read(setupActionProvider.notifier);
  }

  @override
  void dispose() {
    _setupAction.autoApplyProfile();
    super.dispose();
  }

  ConfigListInputItem _generalList({
    required ConfigLabel title,
    ConfigLabel? subtitle,
    required List<String> Function(GeneralSettings settings) select,
    required GeneralSettings Function(
      GeneralSettings settings,
      List<String> value,
    )
    update,
  }) {
    return ConfigListInputItem(
      title: title,
      subtitle: subtitle,
      selector: profileProvider(widget.profileId).select(
        (profile) =>
            select(profile?.generalSettings ?? const GeneralSettings()),
      ),
      onChanged: (ref, value) => updateGeneralSettings(
        ref,
        widget.profileId,
        (settings) => update(settings, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = widget.profileId;
    final include = ref.watch(
      profileProvider(
        profileId,
      ).select((profile) => profile?.generalSettings.include),
    );
    return CommonScaffold(
      title: appLocalizations.generalSettings,
      body: ListView(
        children: [
          _generalList(
            title: (l) => l.dnsServers,
            select: (settings) => settings.dnsServers,
            update: (settings, value) => settings.copyWith(dnsServers: value),
          ),
          _generalList(
            title: (l) => l.fallbackDnsServers,
            select: (settings) => settings.fallbackDnsServers,
            update: (settings, value) =>
                settings.copyWith(fallbackDnsServers: value),
          ),
          _generalList(
            title: (l) => l.directDnsServers,
            select: (settings) => settings.directDnsServers,
            update: (settings, value) =>
                settings.copyWith(directDnsServers: value),
          ),
          _generalList(
            title: (l) => l.skipProxy,
            subtitle: (l) => l.skipProxyDesc,
            select: (settings) => settings.skipProxy,
            update: (settings, value) => settings.copyWith(skipProxy: value),
          ),
          _generalList(
            title: (l) => l.tunExcludedRoutes,
            subtitle: (l) => l.tunExcludedRoutesDesc,
            select: (settings) => settings.tunExcludedRoutes,
            update: (settings, value) =>
                settings.copyWith(tunExcludedRoutes: value),
          ),
          _generalList(
            title: (l) => l.tunIncludedRoutes,
            subtitle: (l) => l.tunIncludedRoutesDesc,
            select: (settings) => settings.tunIncludedRoutes,
            update: (settings, value) =>
                settings.copyWith(tunIncludedRoutes: value),
          ),
          _Ipv6Item(profileId: profileId),
          if (include != null && include.isNotEmpty)
            ListItem(
              leading: const Icon(Icons.link_outlined),
              title: Text(appLocalizations.includeUrl),
              subtitle: Text(include),
            ),
          _UnsupportedItem(
            title: appLocalizations.preferIpv6,
            value: ref.watch(
              profileProvider(
                profileId,
              ).select((profile) => profile?.generalSettings.preferIpv6),
            ),
          ),
          _UnsupportedItem(
            title: appLocalizations.privateIpAnswer,
            value: ref.watch(
              profileProvider(
                profileId,
              ).select((profile) => profile?.generalSettings.privateIpAnswer),
            ),
          ),
          _UnsupportedItem(
            title: appLocalizations.alwaysRealIp,
            value: ref.watch(
              profileProvider(
                profileId,
              ).select((profile) => profile?.generalSettings.alwaysRealIp),
            ),
          ),
        ],
      ),
    );
  }
}
