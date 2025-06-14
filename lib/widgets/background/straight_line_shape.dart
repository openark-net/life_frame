import 'package:flutter/material.dart';

class StraightLineShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double opacity;

  const StraightLineShape({
    super.key,
    this.width = 80,
    this.height = 16,
    this.color = const Color(0xFFFFA500),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, height),
        painter: _StraightLinePainter(
          color: color,
          shadowOffset: shadowOffset,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _StraightLinePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double opacity;

  _StraightLinePainter({
    required this.color,
    required this.shadowOffset,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    // Draw shadow
    paint.color = Colors.black.withOpacity(opacity * 0.3);
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawRRect(rect, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color.withOpacity(opacity);
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}