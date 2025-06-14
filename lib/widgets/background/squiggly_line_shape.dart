import 'package:flutter/material.dart';

class SquigglyLineShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double lineWidth;
  final int waves;
  final double opacity;

  const SquigglyLineShape({
    super.key,
    this.width = 100,
    this.height = 20,
    this.color = const Color(0xFFFF1493),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.lineWidth = 8,
    this.waves = 3,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, height),
        painter: _SquigglyLinePainter(
          color: color,
          shadowOffset: shadowOffset,
          lineWidth: lineWidth,
          waves: waves,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _SquigglyLinePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double lineWidth;
  final int waves;
  final double opacity;

  _SquigglyLinePainter({
    required this.color,
    required this.shadowOffset,
    required this.lineWidth,
    required this.waves,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveLength = size.width / waves;
    final amplitude = size.height / 2;

    path.moveTo(0, amplitude);

    for (int i = 0; i < waves; i++) {
      final x1 = i * waveLength + waveLength / 2;
      final x2 = (i + 1) * waveLength;

      path.quadraticBezierTo(x1, i.isEven ? 0 : size.height, x2, amplitude);
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
