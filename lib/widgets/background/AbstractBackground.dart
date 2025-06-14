import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:life_frame/widgets/background/shapes.dart';
import '../../theme.dart';

class AbstractBackground extends StatelessWidget {
  final double density;
  final bool animated;
  final int seed;

  const AbstractBackground({
    super.key,
    this.density = 1.0,
    this.animated = false,
    this.seed = 42,
  });

  @override
  Widget build(BuildContext context) {
    return animated
        ? _AnimatedBackground(density: density, seed: seed)
        : _StaticBackground(density: density, seed: seed);
  }
}

class _StaticBackground extends StatelessWidget {
  final double density;
  final int seed;

  const _StaticBackground({required this.density, required this.seed});

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
    final baseCount = (15 * density).round();

    final colors = [
      AppColors.yellow,
      AppColors.green,
      AppColors.hotPink,
      AppColors.blue,
      AppColors.red,
      AppColors.purple,
      AppColors.secondary,
    ];

    for (int i = 0; i < baseCount; i++) {
      final x = random.nextDouble() * width * 1.2 - width * 0.1;
      final y = random.nextDouble() * height * 1.2 - height * 0.1;
      final color = colors[random.nextInt(colors.length)];
      final rotation = random.nextDouble() * math.pi * 2;
      final scale = 0.5 + random.nextDouble() * 1.5;
      final opacity = 1.0;

      final shapeType = random.nextInt(6);

      Widget shape;
      switch (shapeType) {
        case 0:
          shape = CircleShape(
            size: 40 * scale,
            color: color,
            shadowOffset: 2 * scale,
          );
          break;
        case 1:
          shape = TriangleShape(
            size: 45 * scale,
            color: color,
            rotation: rotation,
            shadowOffset: 2 * scale,
            cornerRadius: 6 * scale,
          );
          break;
        case 2:
          shape = SquareShape(
            size: 40 * scale,
            color: color,
            rotation: rotation,
            shadowOffset: 2 * scale,
            cornerRadius: 6 * scale,
          );
          break;
        case 3:
          shape = ZigZagShape(
            width: 80 * scale,
            height: 15 * scale,
            color: color,
            rotation: rotation,
            shadowOffset: 2 * scale,
            lineWidth: 6 * scale,
            segments: 2 + random.nextInt(4),
          );
          break;
        case 4:
          shape = SquigglyLineShape(
            width: 70 * scale,
            height: 15 * scale,
            color: color,
            rotation: rotation,
            shadowOffset: 2 * scale,
            lineWidth: 6 * scale,
            waves: 2 + random.nextInt(4),
          );
          break;
        case 5:
          shape = StraightLineShape(
            width: 60 * scale,
            height: 12 * scale,
            color: color,
            rotation: rotation,
            shadowOffset: 2 * scale,
          );
          break;
        default:
          continue;
      }

      shapes.add(Positioned(left: x, top: y, child: shape));
    }

    return shapes;
  }
}

class _AnimatedBackground extends StatefulWidget {
  final double density;
  final int seed;

  const _AnimatedBackground({required this.density, required this.seed});

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
    final baseCount = (10 * widget.density).round();

    final colors = [
      AppColors.yellow,
      AppColors.green,
      AppColors.hotPink,
      AppColors.blue,
      AppColors.red,
      AppColors.purple,
      AppColors.secondary,
    ];

    for (int i = 0; i < baseCount; i++) {
      final color = colors[random.nextInt(colors.length)];
      final scale = 0.4 + random.nextDouble() * 1.2;
      final opacity = 0.2 + random.nextDouble() * 0.3;
      final shapeType = random.nextInt(6);

      Widget shape;
      switch (shapeType) {
        case 0:
          shape = CircleShape(
            size: 35 * scale,
            color: color,
            shadowOffset: 2 * scale,
          );
          break;
        case 1:
          shape = TriangleShape(
            size: 40 * scale,
            color: color,
            rotation: 0,
            shadowOffset: 2 * scale,
            cornerRadius: 5 * scale,
          );
          break;
        case 2:
          shape = SquareShape(
            size: 35 * scale,
            color: color,
            rotation: 0,
            shadowOffset: 2 * scale,
            cornerRadius: 5 * scale,
          );
          break;
        case 3:
          shape = ZigZagShape(
            width: 70 * scale,
            height: 12 * scale,
            color: color,
            rotation: 0,
            shadowOffset: 2 * scale,
            lineWidth: 5 * scale,
            segments: 2 + random.nextInt(3),
          );
          break;
        case 4:
          shape = SquigglyLineShape(
            width: 60 * scale,
            height: 12 * scale,
            color: color,
            rotation: 0,
            shadowOffset: 2 * scale,
            lineWidth: 5 * scale,
            waves: 2 + random.nextInt(3),
          );
          break;
        case 5:
          shape = StraightLineShape(
            width: 50 * scale,
            height: 10 * scale,
            color: color,
            rotation: 0,
            shadowOffset: 2 * scale,
          );
          break;
        default:
          continue;
      }

      _animatedShapes.add(
        _AnimatedShape(
          shape: shape,
          startX: random.nextDouble() * width * 1.2 - width * 0.1,
          startY: random.nextDouble() * height * 1.2 - height * 0.1,
          endX: random.nextDouble() * width * 1.2 - width * 0.1,
          endY: random.nextDouble() * height * 1.2 - height * 0.1,
          rotation: random.nextDouble() * math.pi * 2,
          rotationSpeed: 0.2 + random.nextDouble() * 0.8,
        ),
      );
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
