import 'dart:math';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Traffic trend area chart (§2): download in the §1 accent, upload in a
/// muted tone, translucent fills, no grid clutter.
class TrafficChart extends StatelessWidget {
  const TrafficChart({super.key, required this.samples, this.height = 180});

  final List<Traffic> samples;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DesktopThemeTokens>();
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TrafficChartPainter(
          samples: samples,
          downColor: tokens?.accent ?? theme.colorScheme.primary,
          upColor: tokens?.text3 ?? theme.colorScheme.onSurfaceVariant,
          gridColor: theme.dividerColor.withValues(alpha: 0.35),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _TrafficChartPainter extends CustomPainter {
  _TrafficChartPainter({
    required this.samples,
    required this.downColor,
    required this.upColor,
    required this.gridColor,
  });

  final List<Traffic> samples;
  final Color downColor;
  final Color upColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (samples.length < 2) return;
    num maxValue = 1;
    for (final s in samples) {
      maxValue = max(maxValue, max(s.up, s.down));
    }
    _drawSeries(
      canvas,
      size,
      samples.map((s) => s.down.toDouble()).toList(),
      maxValue.toDouble(),
      downColor,
    );
    _drawSeries(
      canvas,
      size,
      samples.map((s) => s.up.toDouble()).toList(),
      maxValue.toDouble(),
      upColor,
    );
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double> values,
    double maxValue,
    Color color,
  ) {
    final points = values.length;
    double xAt(int i) => size.width * i / (points - 1);
    double yAt(int i) =>
        size.height - (values[i] / maxValue) * (size.height - 8) - 4;
    final linePath = Path()..moveTo(xAt(0), yAt(0));
    for (var i = 1; i < points; i++) {
      linePath.lineTo(xAt(i), yAt(i));
    }
    final fillPath = Path.from(linePath)
      ..lineTo(xAt(points - 1), size.height)
      ..lineTo(xAt(0), size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrafficChartPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.downColor != downColor ||
        oldDelegate.upColor != upColor;
  }
}
