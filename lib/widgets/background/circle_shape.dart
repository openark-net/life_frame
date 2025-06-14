import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircleShape extends StatelessWidget {
  final double size;
  final Color color;
  final double shadowOffset;
  final double opacity;

  const CircleShape({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF00CED1),
    this.shadowOffset = 4,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CirclePainter(
        color: color,
        shadowOffset: shadowOffset,
        opacity: opacity,
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double opacity;

  _CirclePainter({
    required this.color,
    required this.shadowOffset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw shadow
    paint.color = Colors.black.withOpacity(opacity * 0.3);
    canvas.drawCircle(
      center.translate(shadowOffset, shadowOffset),
      radius,
      paint,
    );

    // Draw main shape
    paint.color = color.withOpacity(opacity);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
