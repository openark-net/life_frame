import 'dart:math' as math;
import 'package:flutter/material.dart';

class ZigZagShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double lineWidth;
  final int segments;
  final double opacity;

  const ZigZagShape({
    super.key,
    this.width = 100,
    this.height = 20,
    this.color = const Color(0xFF00CED1),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.lineWidth = 8,
    this.segments = 5,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, height),
        painter: _ZigZagPainter(
          color: color,
          shadowOffset: shadowOffset,
          lineWidth: lineWidth,
          segments: segments,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _ZigZagPainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double lineWidth;
  final int segments;
  final double opacity;

  _ZigZagPainter({
    required this.color,
    required this.shadowOffset,
    required this.lineWidth,
    required this.segments,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final segmentWidth = size.width / segments;
    final amplitude = size.height / 2;

    path.moveTo(0, amplitude);
    for (int i = 0; i < segments; i++) {
      final x1 = i * segmentWidth + segmentWidth / 2;
      final y1 = i.isEven ? 0 : size.height;
      final x2 = (i + 1) * segmentWidth;
      final y2 = amplitude;

      path.lineTo(x1, y1.toDouble());
      if (i < segments - 1) {
        path.lineTo(x2, y2);
      }
    }

    // Draw shadow
    paint.color = Colors.black.withOpacity(opacity * 0.3);
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color.withOpacity(opacity);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
