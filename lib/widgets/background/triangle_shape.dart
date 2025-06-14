import 'package:flutter/material.dart';

class TriangleShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double cornerRadius;
  final double opacity;

  const TriangleShape({
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
        painter: _TrianglePainter(
          color: color,
          shadowOffset: shadowOffset,
          cornerRadius: cornerRadius,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double cornerRadius;
  final double opacity;

  _TrianglePainter({
    required this.color,
    required this.shadowOffset,
    required this.cornerRadius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height * 0.866; // equilateral triangle height

    // Create rounded triangle path
    path.moveTo(size.width / 2, cornerRadius);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width / 2 + cornerRadius,
      cornerRadius,
    );
    path.lineTo(size.width - cornerRadius, height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      height,
      size.width - cornerRadius,
      height,
    );
    path.lineTo(cornerRadius, height);
    path.quadraticBezierTo(0, height, 0, height - cornerRadius);
    path.close();

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