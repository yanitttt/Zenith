import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutGauge extends StatelessWidget {
  final double percent; // 0..1
  final double size;
  final double strokeWidth;
  final Color backgroundRing;
  final List<Color> gradientColors;

  const DonutGauge({
    super.key,
    required this.percent,
    this.size = 110,
    this.strokeWidth = 14,
    this.backgroundRing = const Color(0xFF4A4A4A),
    this.gradientColors = const [Color(0xFFEAD9A5), Color(0xFFC8B06A)],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(
        percent: percent.clamp(0, 1),
        bgRing: backgroundRing,
        colors: gradientColors,
        stroke: strokeWidth,
      ),
      size: Size.square(size),
      child: Center(
        child: Container(
          width: size * 0.42,
          height: size * 0.42,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "${(percent * 100).round()} %",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double percent;
  final double stroke;
  final Color bgRing;
  final List<Color> colors;

  _DonutPainter({
    required this.percent,
    required this.stroke,
    required this.bgRing,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = bgRing;

    canvas.drawArc(rect.deflate(stroke / 2), -math.pi / 2, math.pi * 2, false, base);

    final sweep = (math.pi * 2) * percent;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + sweep,
      colors: colors,
    ).createShader(rect);

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient;

    canvas.drawArc(rect.deflate(stroke / 2), -math.pi / 2, sweep, false, prog);

    final gloss = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white12;
    canvas.drawArc(rect.deflate(stroke), -math.pi / 2, math.pi * 2, false, gloss);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.percent != percent || old.stroke != stroke;
}
