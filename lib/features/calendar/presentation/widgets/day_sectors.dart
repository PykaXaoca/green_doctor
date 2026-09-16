import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Цвета для типов событий календаря.
class CalendarEventColors {
  CalendarEventColors._();

  static const Color watering = Color(0xFF1E88E5); // Blue 600
  static const Color fertilizing = Color(0xFF43A047); // Green 600
  static const Color misting = Color(0xFF00897B); // Teal 600
  static const Color repotting = Color(0xFF6D4C41); // Brown 600
  static const Color treatment = AppTheme.treatmentRed;

  static Color forType(String type) {
    switch (type) {
      case 'watering':
        return watering;
      case 'fertilizing':
        return fertilizing;
      case 'misting':
        return misting;
      case 'repotting':
        return repotting;
      case 'treatment':
        return treatment;
      default:
        return Colors.grey;
    }
  }
}

/// Круговой маркер с секторами.
///
/// Каждый сектор соответствует типу события, размер сектора
/// пропорционален количеству событий этого типа в дне.
///
/// Если у дня событий нет — ничего не рисуется.
class DaySectorsMarker extends StatelessWidget {
  const DaySectorsMarker({
    super.key,
    required this.counts,
    this.size = 22,
    this.gapColor,
  });

  /// Соответствие «тип события → количество».
  final Map<String, int> counts;

  /// Размер маркера (квадрат).
  final double size;

  /// Цвет фона, если хочется разделить сектора.
  /// Если null — сектора идут подряд без зазора.
  final Color? gapColor;

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DaySectorsPainter(counts: counts, gapColor: gapColor),
      ),
    );
  }
}

class _DaySectorsPainter extends CustomPainter {
  _DaySectorsPainter({required this.counts, this.gapColor});

  final Map<String, int> counts;
  final Color? gapColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold<int>(0, (sum, v) => sum + v);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Зазор между секторами (в радианах). Делаем деликатный, чтобы
    // сектора не сливались визуально.
    const double gap = 0.06;

    var startAngle = -math.pi / 2; // начинаем сверху
    final paint = Paint()..style = PaintingStyle.fill;

    // Сортируем по убыванию количества — крупные сектора впереди.
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in entries) {
      final sweep = (entry.value / total) * 2 * math.pi;
      if (sweep <= 0) continue;

      // Оставляем маленький зазор, но не больше 1/3 сектора.
      final gapHere = math.min(gap, sweep / 3);
      final drawSweep = sweep - gapHere;

      paint.color = CalendarEventColors.forType(entry.key);
      canvas.drawArc(rect, startAngle + gapHere / 2, drawSweep, true, paint);
      startAngle += sweep;
    }

    // Тонкий контур, чтобы маркер читался на светлом фоне.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _DaySectorsPainter oldDelegate) {
    if (oldDelegate.counts.length != counts.length) return true;
    for (final entry in counts.entries) {
      if (oldDelegate.counts[entry.key] != entry.value) return true;
    }
    return oldDelegate.gapColor != gapColor;
  }
}
