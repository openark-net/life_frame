import 'package:flutter/material.dart';
import 'dart:math' as math;

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

    // Calculate equilateral triangle vertices
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Vertices of an equilateral triangle (top, bottom-right, bottom-left)
    final vertices = [
      Offset(centerX, centerY - radius * 2 / 3), // Top vertex
      Offset(
        centerX + radius * math.sqrt(3) / 2,
        centerY + radius * 1 / 3,
      ), // Bottom right
      Offset(
        centerX - radius * math.sqrt(3) / 2,
        centerY + radius * 1 / 3,
      ), // Bottom left
    ];

    // Calculate the maximum allowed corner radius
    // It should not exceed half of the shortest edge
    final edgeLength = (vertices[0] - vertices[1]).distance;
    final maxRadius =
        edgeLength * 0.2; // Use 20% of edge length for nice proportions
    final effectiveRadius = math.min(cornerRadius, maxRadius);

    // Create the rounded triangle path
    final path = _createRoundedTrianglePath(vertices, effectiveRadius);

    // Draw shadow
    if (shadowOffset > 0) {
      paint.color = Colors.black.withOpacity(opacity * 0.3);
      canvas.save();
      canvas.translate(shadowOffset, shadowOffset);
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Draw main shape
    paint.color = color.withOpacity(opacity);
    canvas.drawPath(path, paint);
  }

  Path _createRoundedTrianglePath(List<Offset> vertices, double radius) {
    final path = Path();

    if (radius <= 0) {
      // No rounding, just create a simple triangle
      path.moveTo(vertices[0].dx, vertices[0].dy);
      path.lineTo(vertices[1].dx, vertices[1].dy);
      path.lineTo(vertices[2].dx, vertices[2].dy);
      path.close();
      return path;
    }

    // For each vertex, we need to find the two points where the rounded corner starts/ends
    for (int i = 0; i < vertices.length; i++) {
      final current = vertices[i];
      final previous = vertices[(i - 1 + vertices.length) % vertices.length];
      final next = vertices[(i + 1) % vertices.length];

      // Calculate unit vectors from current vertex to adjacent vertices
      final toPrev = (previous - current).distance > 0
          ? (previous - current) / (previous - current).distance
          : Offset.zero;
      final toNext = (next - current).distance > 0
          ? (next - current) / (next - current).distance
          : Offset.zero;

      // Calculate the points where the curve starts and ends
      final curveStart = current + toPrev * radius;
      final curveEnd = current + toNext * radius;

      if (i == 0) {
        // Move to the first curve start point
        path.moveTo(curveStart.dx, curveStart.dy);
      } else {
        // Line to the curve start point
        path.lineTo(curveStart.dx, curveStart.dy);
      }

      // Add the rounded corner using a quadratic bezier curve
      path.quadraticBezierTo(current.dx, current.dy, curveEnd.dx, curveEnd.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowOffset != shadowOffset ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.opacity != opacity;
  }
}
