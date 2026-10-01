import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class EclipseSection extends StatelessWidget {
  const EclipseSection({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.divided = true,
    this.padding = const EdgeInsets.all(16),
    required this.children,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final bool divided;
  final EdgeInsets padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && divided) {
        separated.add(
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurfaceVariant.opacity12,
          ),
        );
      }
      separated.add(children[i]);
    }
    return CommonCard(
      radius: AppCorner.md,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ...separated,
        ],
      ),
    );
  }
}

class EclipseTile extends StatelessWidget {
  const EclipseTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 12),
              decoration: ShapeDecoration(
                shape: AppShape.sm,
                color: (iconColor ?? colorScheme.primary).opacity12,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.bodyLarge),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.opacity60,
            ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: AppRadius.sm, onTap: onTap, child: content);
  }
}

class EclipseSwitchTile extends StatelessWidget {
  const EclipseSwitchTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return EclipseTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class EclipseSegmentOption<T> {
  const EclipseSegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

class EclipseSegmented<T> extends StatelessWidget {
  const EclipseSegmented({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
  });

  final List<EclipseSegmentOption<T>> options;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        shape: AppShape.md,
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: options.map((option) {
          final selected = option.value == groupValue;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: ShapeDecoration(
                  shape: AppShape.sm,
                  color: selected ? colorScheme.primary : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EclipsePrimaryButton extends StatelessWidget {
  const EclipsePrimaryButton({
    super.key,
    this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: AppShape.md,
        ),
      ),
    );
  }
}

class EclipseStatusDot extends StatelessWidget {
  const EclipseStatusDot({super.key, required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.opacity50, blurRadius: size, spreadRadius: 1),
        ],
      ),
    );
  }
}

class EclipseOpenTile extends StatelessWidget {
  const EclipseOpenTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.maxWidth,
    this.blur = true,
    this.forceFull = true,
    required this.page,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double? maxWidth;
  final bool blur;
  final bool forceFull;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<dynamic>(
      closedBuilder: (context, action) {
        Future<void> openAction() async {
          final isMobile = context.isMobileView;
          if (!isMobile || kDebugMode) {
            await showExtend(
              context,
              props: ExtendProps(
                blur: blur,
                maxWidth: maxWidth,
                forceFull: forceFull,
              ),
              builder: (_) => page,
            );
            return;
          }
          action();
        }

        return EclipseTile(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          showChevron: true,
          onTap: openAction,
        );
      },
      openBuilder: (_, _) => page,
    );
  }
}

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return BaseScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: ShapeDecoration(
                  shape: AppShape.lg,
                  color: colorScheme.primary.opacity12,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 44,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                appLocalizations.comingSoon,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appLocalizations.comingSoonDesc,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
