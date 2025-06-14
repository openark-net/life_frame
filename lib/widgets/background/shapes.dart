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

  const ZigZagShape({
    super.key,
    this.width = 100,
    this.height = 20,
    this.color = const Color(0xFF00CED1),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.lineWidth = 8,
    this.segments = 3,
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

  _ZigZagPainter({
    required this.color,
    required this.shadowOffset,
    required this.lineWidth,
    required this.segments,
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
    paint.color = Colors.black;
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircleShape extends StatelessWidget {
  final double size;
  final Color color;
  final double shadowOffset;

  const CircleShape({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF00CED1),
    this.shadowOffset = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CirclePainter(color: color, shadowOffset: shadowOffset),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;

  _CirclePainter({required this.color, required this.shadowOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw shadow
    paint.color = Colors.black;
    canvas.drawCircle(
      center.translate(shadowOffset, shadowOffset),
      radius,
      paint,
    );

    // Draw main shape
    paint.color = color;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double cornerRadius;

  const TriangleShape({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF00FF00),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.cornerRadius = 8,
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
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double cornerRadius;

  _TrianglePainter({
    required this.color,
    required this.shadowOffset,
    required this.cornerRadius,
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
    paint.color = Colors.black;
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StraightLineShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double shadowOffset;

  const StraightLineShape({
    super.key,
    this.width = 80,
    this.height = 16,
    this.color = const Color(0xFFFFA500),
    this.rotation = 0,
    this.shadowOffset = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, height),
        painter: _StraightLinePainter(color: color, shadowOffset: shadowOffset),
      ),
    );
  }
}

class _StraightLinePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;

  _StraightLinePainter({required this.color, required this.shadowOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    // Draw shadow
    paint.color = Colors.black;
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawRRect(rect, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color;
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquareShape extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double cornerRadius;

  const SquareShape({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF00FF00),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.cornerRadius = 8,
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
        ),
      ),
    );
  }
}

class _SquarePainter extends CustomPainter {
  final Color color;
  final double shadowOffset;
  final double cornerRadius;

  _SquarePainter({
    required this.color,
    required this.shadowOffset,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(cornerRadius),
    );

    // Draw shadow
    paint.color = Colors.black;
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawRRect(rect, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color;
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SquigglyLineShape extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double rotation;
  final double shadowOffset;
  final double lineWidth;
  final int waves;

  const SquigglyLineShape({
    super.key,
    this.width = 100,
    this.height = 20,
    this.color = const Color(0xFFFF1493),
    this.rotation = 0,
    this.shadowOffset = 4,
    this.lineWidth = 8,
    this.waves = 3,
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

  _SquigglyLinePainter({
    required this.color,
    required this.shadowOffset,
    required this.lineWidth,
    required this.waves,
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
    paint.color = Colors.black;
    canvas.save();
    canvas.translate(shadowOffset, shadowOffset);
    canvas.drawPath(path, paint);
    canvas.restore();

    // Draw main shape
    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
