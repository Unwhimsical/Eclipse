import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxySortButton extends ConsumerWidget {
  const ProxySortButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final sortType = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.sortType),
    );
    return PopupMenuButton<ProxiesSortType>(
      tooltip: appLocalizations.sort,
      initialValue: sortType,
      onSelected: (value) {
        ref
            .read(proxiesStyleSettingProvider.notifier)
            .update((state) => state.copyWith(sortType: value));
      },
      itemBuilder: (context) => [
        for (final item in ProxiesSortType.values)
          PopupMenuItem(
            value: item,
            child: Text(_label(appLocalizations, item)),
          ),
      ],
      icon: const Icon(Icons.sort_rounded),
    );
  }

  String _label(AppLocalizations appLocalizations, ProxiesSortType type) {
    return switch (type) {
      ProxiesSortType.none => appLocalizations.defaultText,
      ProxiesSortType.delay => appLocalizations.delay,
      ProxiesSortType.name => appLocalizations.name,
    };
  }
}
