import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:life_frame/widgets/background/shapes.dart';
import '../../theme.dart';

class BackgroundUtils {
  static const List<Color> _backgroundColors = [
    AppColors.yellow,
    AppColors.green,
    AppColors.hotPink,
    AppColors.blue,
    AppColors.red,
    AppColors.purple,
    AppColors.secondary,
  ];

  static Color getRandomColor(math.Random random) {
    return _backgroundColors[random.nextInt(_backgroundColors.length)];
  }

  static Widget buildRandomShape(math.Random random, double scale) {
    final color = getRandomColor(random);
    final rotation = random.nextDouble() * math.pi * 2;
    final shapeType = random.nextInt(6);

    switch (shapeType) {
      case 0:
        return CircleShape(
          size: (30 + random.nextDouble() * 40) * scale,
          color: color,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          opacity: 1.0,
        );
      case 1:
        return TriangleShape(
          size: (35 + random.nextDouble() * 45) * scale,
          color: color,
          rotation: rotation,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          cornerRadius: (4 + random.nextDouble() * 8) * scale,
          opacity: 1.0,
        );
      case 2:
        return SquareShape(
          size: (30 + random.nextDouble() * 40) * scale,
          color: color,
          rotation: rotation,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          cornerRadius: (4 + random.nextDouble() * 8) * scale,
          opacity: 1.0,
        );
      case 3:
        return ZigZagShape(
          width: (60 + random.nextDouble() * 60) * scale,
          height: (10 + random.nextDouble() * 20) * scale,
          color: color,
          rotation: rotation,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          lineWidth: (4 + random.nextDouble() * 8) * scale,
          segments: 4 + random.nextInt(4),
          opacity: 1.0,
        );
      case 4:
        return SquigglyLineShape(
          width: (60 + random.nextDouble() * 60) * scale,
          height: (10 + random.nextDouble() * 20) * scale,
          color: color,
          rotation: rotation,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          lineWidth: (4 + random.nextDouble() * 8) * scale,
          waves: 2 + random.nextInt(4),
          opacity: 1.0,
        );
      case 5:
        return StraightLineShape(
          width: (40 + random.nextDouble() * 60) * scale,
          height: (8 + random.nextDouble() * 16) * scale,
          color: color,
          rotation: rotation,
          shadowOffset: (2 + random.nextDouble() * 3) * scale,
          opacity: 1.0,
        );
      default:
        return CircleShape(
          size: 30 * scale,
          color: color,
          shadowOffset: 2 * scale,
        );
    }
  }
}
