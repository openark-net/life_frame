import 'package:flutter/material.dart';

class SquareShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double cornerRadius;
  final double opacity;

  const SquareShape({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF00FF00),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.cornerRadius = 8,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(size, size),
        painter: _SquarePainter(
          color: color,
          shadowOffset: shadowOffset,
          cornerRadius: cornerRadius,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _SquarePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double cornerRadius;
  final double opacity;

  _SquarePainter({
    required this.color,
    required this.shadowOffset,
    required this.cornerRadius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(cornerRadius),
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
