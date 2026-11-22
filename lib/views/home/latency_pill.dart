import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class LatencyPill extends StatelessWidget {
  const LatencyPill({
    super.key,
    required this.delay,
    required this.pending,
    this.onTap,
  });

  final int? delay;
  final bool pending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = getDelayColor(delay) ?? colorScheme.onSurfaceVariant;
    final label = pending
        ? '…'
        : delay == null
        ? '—'
        : formatDelay(context.appLocalizations, delay);
    return Material(
      color: color.withValues(alpha: 0.14),
      shape: StadiumBorder(
        side: BorderSide(color: color.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
