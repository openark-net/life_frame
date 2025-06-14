import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:life_frame/widgets/background/shapes.dart';
import 'package:life_frame/widgets/background/background_utils.dart';
import '../../theme.dart';

class AbstractBackground extends StatelessWidget {
  final double density;
  final bool animated;
  final int seed;
  final bool radialDistribution;

  const AbstractBackground({
    super.key,
    this.density = 1.0,
    this.animated = false,
    this.seed = 42,
    this.radialDistribution = false,
  });

  @override
  Widget build(BuildContext context) {
    return animated
        ? _AnimatedBackground(
            density: density,
            seed: seed,
            radialDistribution: radialDistribution,
          )
        : _StaticBackground(
            density: density,
            seed: seed,
            radialDistribution: radialDistribution,
          );
  }
}

class _StaticBackground extends StatelessWidget {
  final double density;
  final int seed;
  final bool radialDistribution;

  const _StaticBackground({
    required this.density,
    required this.seed,
    required this.radialDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return SizedBox.expand(
      child: ClipRect(
        child: Stack(children: _generateShapes(screenWidth, screenHeight)),
      ),
    );
  }

  List<Widget> _generateShapes(double width, double height) {
    final random = math.Random(seed);
    final shapes = <Widget>[];

    final cellSize = 100.0;
    final cols = (width / cellSize).ceil();
    final rows = (height / cellSize).ceil();

    final centerX = width / 2;
    final centerY = height / 2;
    final maxDistance = math.sqrt(centerX * centerX + centerY * centerY);

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cellX = col * cellSize;
        final cellY = row * cellSize;

        final cellCenterX = cellX + cellSize / 2;
        final cellCenterY = cellY + cellSize / 2;

        double currentDensity = density;

        if (radialDistribution) {
          final distanceFromCenter = math.sqrt(
            math.pow(cellCenterX - centerX, 2) +
                math.pow(cellCenterY - centerY, 2),
          );
          final normalizedDistance = distanceFromCenter / maxDistance;
          currentDensity = density * normalizedDistance * 2.0;
        }

        if (random.nextDouble() > currentDensity) continue;

        final x = cellX + random.nextDouble() * cellSize * 0.8 + cellSize * 0.1;
        final y = cellY + random.nextDouble() * cellSize * 0.8 + cellSize * 0.1;

        final scale = 0.5 + random.nextDouble() * 1.5;
        final shape = BackgroundUtils.buildRandomShape(random, scale);

        shapes.add(Positioned(left: x, top: y, child: shape));
      }
    }

    return shapes;
  }
}

class _AnimatedBackground extends StatefulWidget {
  final double density;
  final int seed;
  final bool radialDistribution;

  const _AnimatedBackground({
    required this.density,
    required this.seed,
    required this.radialDistribution,
  });

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_AnimatedShape> _animatedShapes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeShapes(constraints.maxWidth, constraints.maxHeight);

        return SizedBox.expand(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: _animatedShapes.map((animatedShape) {
                    final progress = _controller.value;
                    final x =
                        animatedShape.startX +
                        (animatedShape.endX - animatedShape.startX) * progress;
                    final y =
                        animatedShape.startY +
                        (animatedShape.endY - animatedShape.startY) * progress;
                    final rotation =
                        animatedShape.rotation +
                        progress * math.pi * 2 * animatedShape.rotationSpeed;

                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.rotate(
                        angle: rotation,
                        child: animatedShape.shape,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _initializeShapes(double width, double height) {
    if (_animatedShapes.isNotEmpty) return;

    final random = math.Random(widget.seed);
    _animatedShapes = [];

    final cellSize = 150.0;
    final cols = (width / cellSize).ceil();
    final rows = (height / cellSize).ceil();

    final centerX = width / 2;
    final centerY = height / 2;
    final maxDistance = math.sqrt(centerX * centerX + centerY * centerY);

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cellX = col * cellSize;
        final cellY = row * cellSize;

        final cellCenterX = cellX + cellSize / 2;
        final cellCenterY = cellY + cellSize / 2;

        double currentDensity = widget.density * 0.6;

        if (widget.radialDistribution) {
          final distanceFromCenter = math.sqrt(
            math.pow(cellCenterX - centerX, 2) +
                math.pow(cellCenterY - centerY, 2),
          );
          final normalizedDistance = distanceFromCenter / maxDistance;
          currentDensity = widget.density * 0.6 * normalizedDistance * 2.0;
        }

        if (random.nextDouble() > currentDensity) continue;

        final startX =
            cellX + random.nextDouble() * cellSize * 0.8 + cellSize * 0.1;
        final startY =
            cellY + random.nextDouble() * cellSize * 0.8 + cellSize * 0.1;

        final scale = 0.4 + random.nextDouble() * 1.2;
        final shape = BackgroundUtils.buildRandomShape(random, scale);

        _animatedShapes.add(
          _AnimatedShape(
            shape: shape,
            startX: startX,
            startY: startY,
            endX: startX + (random.nextDouble() - 0.5) * cellSize * 0.5,
            endY: startY + (random.nextDouble() - 0.5) * cellSize * 0.5,
            rotation: random.nextDouble() * math.pi * 2,
            rotationSpeed: 0.2 + random.nextDouble() * 0.8,
          ),
        );
      }
    }
  }
}

class _AnimatedShape {
  final Widget shape;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double rotation;
  final double rotationSpeed;

  _AnimatedShape({
    required this.shape,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.rotationSpeed,
  });
}
