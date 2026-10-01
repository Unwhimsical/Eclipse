import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/hct/hct.dart';

class AppearanceView extends ConsumerWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    final items = [
      (
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_outlined,
        label: appLocalizations.auto,
      ),
      (
        mode: ThemeMode.light,
        icon: Icons.light_mode_outlined,
        label: appLocalizations.light,
      ),
      (
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_outlined,
        label: appLocalizations.dark,
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.appearance,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EclipseSection(
            title: appLocalizations.themeMode,
            subtitle: appLocalizations.appearanceDesc,
            children: [
              for (final item in items)
                EclipseTile(
                  icon: item.icon,
                  title: item.label,
                  onTap: () {
                    ref
                        .read(themeSettingProvider.notifier)
                        .update(
                          (state) => state.copyWith(themeMode: item.mode),
                        );
                  },
                  trailing: Radio<ThemeMode>(
                    value: item.mode,
                    groupValue: themeMode,
                    onChanged: (mode) {
                      if (mode == null) return;
                      ref
                          .read(themeSettingProvider.notifier)
                          .update((state) => state.copyWith(themeMode: mode));
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return BaseScaffold(
      title: appLocalizations.theme,
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          _PrimaryColorItem(),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          _PureBlackItem(),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          _TextScaleFactorItem(),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _PrimaryColorItem extends ConsumerStatefulWidget {
  const _PrimaryColorItem();

  @override
  ConsumerState<_PrimaryColorItem> createState() => _PrimaryColorItemState();
}

class _PrimaryColorItemState extends ConsumerState<_PrimaryColorItem> {
  int? _removablePrimaryColor;

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: defaultPrimaryColors,
        primaryColor: defaultPrimaryColor,
        schemeVariant: DynamicSchemeVariant.content,
      );
    });
  }

  Future<void> _handleDel() async {
    final appLocalizations = context.appLocalizations;
    if (_removablePrimaryColor == null) {
      return;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.colorSchemes),
      ),
    );
    if (res != true) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      final newPrimaryColors = List<int>.from(state.primaryColors)
        ..remove(_removablePrimaryColor);
      int? newPrimaryColor = state.primaryColor;
      if (state.primaryColor == _removablePrimaryColor) {
        if (newPrimaryColors.contains(defaultPrimaryColor)) {
          newPrimaryColor = defaultPrimaryColor;
        } else {
          newPrimaryColor = null;
        }
      }
      return state.copyWith(
        primaryColors: newPrimaryColors,
        primaryColor: newPrimaryColor,
      );
    });
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  Future<void> _handleAdd() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showCommonDialog<int>(
      child: const _PaletteDialog(),
    );
    if (res == null) {
      return;
    }
    final isExists = ref.read(
      themeSettingProvider.select((state) => state.primaryColors.contains(res)),
    );
    if (isExists && mounted) {
      context.showNotifier(
        appLocalizations.existsTip(appLocalizations.colorSchemes),
        level: MessageLevel.warning,
      );
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(
        primaryColors: List.from(state.primaryColors)..add(res),
      );
    });
  }

  Future<void> _handleChangeSchemeVariant() async {
    final schemeVariant = ref.read(
      themeSettingProvider.select((state) => state.schemeVariant),
    );
    final value = await dialogs.showCommonDialog<DynamicSchemeVariant>(
      child: OptionsDialog<DynamicSchemeVariant>(
        title: context.appLocalizations.colorSchemes,
        options: DynamicSchemeVariant.values,
        textBuilder: (item) => item.label,
        value: schemeVariant,
      ),
    );
    if (value == null) {
      return;
    }
    ref.read(themeSettingProvider.notifier).update((state) {
      return state.copyWith(schemeVariant: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final themeColors = ref.watch(
      themeSettingProvider.select(
        (state) => ThemeColorsSelectorState(
          primaryColor: state.primaryColor,
          primaryColors: state.primaryColors,
          schemeVariant: state.schemeVariant,
          isDefault:
              state.primaryColor == defaultPrimaryColor &&
              intListEquality.equals(
                state.primaryColors,
                defaultPrimaryColors,
              ) &&
              state.schemeVariant == DynamicSchemeVariant.content,
        ),
      ),
    );
    final primaryColor = themeColors.primaryColor;
    final primaryColors = [null, ...themeColors.primaryColors];
    final schemeVariant = themeColors.schemeVariant;
    final isEquals = themeColors.isDefault;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CommonPopScope(
          onPop: (context) {
            if (_removablePrimaryColor != null) {
              setState(() {
                _removablePrimaryColor = null;
              });
              return false;
            }
            return true;
          },
          child: EclipseSection(
            title: appLocalizations.themeColor,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: genActions([
                if (_removablePrimaryColor == null)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _handleChangeSchemeVariant,
                    child: Text(schemeVariant.label),
                  ),
                if (_removablePrimaryColor != null)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _clearRemovable,
                    child: Text(appLocalizations.cancel),
                  ),
                if (_removablePrimaryColor == null && !isEquals)
                  IconButton.filledTonal(
                    tooltip: context.appLocalizations.reset,
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    visualDensity: VisualDensity.compact,
                    onPressed: _handleReset,
                    icon: const Icon(Icons.replay),
                  ),
              ], space: 8),
            ),
            divided: false,
            children: [
              _PrimaryColorGrid(
                colors: primaryColors,
                selectedColor: primaryColor,
                removableColor: _removablePrimaryColor,
                onSelect: _handleSelectColor,
                onRequestRemove: _markRemovable,
                onDelete: _handleDel,
                onAdd: _handleAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearRemovable() {
    setState(() {
      _removablePrimaryColor = null;
    });
  }

  void _markRemovable(int? color) {
    setState(() {
      _removablePrimaryColor = color;
    });
  }

  void _handleSelectColor(int? color) {
    _clearRemovable();
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(primaryColor: color));
  }
}

class _PrimaryColorGrid extends StatelessWidget {
  const _PrimaryColorGrid({
    required this.colors,
    required this.selectedColor,
    required this.removableColor,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
    required this.onAdd,
  });

  final List<int?> colors;
  final int? selectedColor;
  final int? removableColor;
  final void Function(int? color) onSelect;
  final void Function(int? color) onRequestRemove;
  final VoidCallback onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns = max((constraints.maxWidth / 96).ceil(), 3);
        final itemWidth = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final color in colors)
              _PrimaryColorTile(
                color: color,
                width: itemWidth,
                isSelected: color == selectedColor,
                isRemovable: removableColor != null && removableColor == color,
                onSelect: () => onSelect(color),
                onRequestRemove: () => onRequestRemove(color),
                onDelete: onDelete,
              ),
            if (removableColor == null)
              _AddPrimaryColorTile(width: itemWidth, onPressed: onAdd),
          ],
        );
      },
    );
  }
}

class _PrimaryColorTile extends StatelessWidget {
  const _PrimaryColorTile({
    required this.color,
    required this.width,
    required this.isSelected,
    required this.isRemovable,
    required this.onSelect,
    required this.onRequestRemove,
    required this.onDelete,
  });

  final int? color;
  final double width;
  final bool isSelected;
  final bool isRemovable;
  final VoidCallback onSelect;
  final VoidCallback onRequestRemove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      width: width,
      height: width,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          EffectGestureDetector(
            onLongPress: onRequestRemove,
            child: ColorSchemeBox(
              isSelected: isSelected,
              primaryColor: color != null ? Color(color!) : null,
              onPressed: onSelect,
            ),
          ),
          if (isRemovable)
            Container(
              color: Colors.white.opacity0,
              padding: const EdgeInsets.all(8),
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: onDelete,
                padding: const EdgeInsets.all(12),
                iconSize: 30,
                icon: Icon(color: context.colorScheme.primary, Icons.delete),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPrimaryColorTile extends StatelessWidget {
  const _AddPrimaryColorTile({required this.width, required this.onPressed});

  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      padding: const EdgeInsets.all(4),
      child: IconButton.filledTonal(
        tooltip: context.appLocalizations.add,
        onPressed: onPressed,
        iconSize: 32,
        icon: Icon(color: context.colorScheme.primary, Icons.add),
      ),
    );
  }
}

class _PureBlackItem extends ConsumerWidget {
  const _PureBlackItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final pureBlack = ref.watch(
      themeSettingProvider.select((state) => state.pureBlack),
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: EclipseSection(
          children: [
            EclipseSwitchTile(
              icon: Icons.contrast_outlined,
              title: appLocalizations.pureBlackMode,
              value: pureBlack,
              onChanged: (value) {
                ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith(pureBlack: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerWidget {
  const _TextScaleFactorItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final String process = '${(textScale.scale * 100).round()}%';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: EclipseSection(
          title: appLocalizations.textScale,
          divided: false,
          children: [
            EclipseSwitchTile(
              icon: Icons.text_fields_outlined,
              title: appLocalizations.textScale,
              value: textScale.enable,
              onChanged: (value) {
                ref
                    .read(themeSettingProvider.notifier)
                    .update((state) => state.copyWith.textScale(enable: value));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                spacing: 32,
                children: [
                  Expanded(
                    child: DisabledMask(
                      status: !textScale.enable,
                      child: ActivateBox(
                        active: textScale.enable,
                        child: SliderTheme(
                          data: SliderDefaultsM3(context),
                          child: Slider(
                            padding: EdgeInsets.zero,
                            min: minTextScale,
                            max: maxTextScale,
                            value: textScale.scale,
                            onChanged: (value) {
                              ref
                                  .read(themeSettingProvider.notifier)
                                  .update(
                                    (state) =>
                                        state.copyWith.textScale(scale: value),
                                  );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(process, style: context.textTheme.titleMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteDialog extends StatefulWidget {
  const _PaletteDialog();

  @override
  State<_PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<_PaletteDialog> {
  final _controller = ValueNotifier<Color>(Color(Hct.from(0, 0, 60).toInt()));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.palette,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.value.toARGB32());
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 300, child: Palette(controller: _controller)),
        ],
      ),
    );
  }
}
