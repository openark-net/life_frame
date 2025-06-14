import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../../openark_theme.dart';

class RainbowBackground extends StatelessWidget {
  final Widget child;

  const RainbowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiagonalWavyRainbowPainter(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: child,
      ),
    );
  }
}

class DiagonalWavyRainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      OpenArkColors.primary,
      OpenArkColors.secondary,
      OpenArkColors.blueAlt,
      OpenArkColors.tertiary,
      OpenArkColors.greenAlt,
      OpenArkColors.warning,
      OpenArkColors.error,
    ];

    final paint = Paint()..style = PaintingStyle.fill;

    // Create diagonal wavy stripes
    const double stripeWidth = 60.0;
    const double waveAmplitude = 30.0;
    const double waveFrequency = 0.02;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(0.15);

      final path = Path();
      
      // Calculate diagonal stripe position
      final double offset = i * stripeWidth - size.width * 0.5;
      
      // Start from top-left and create diagonal wavy stripe
      for (double y = -size.height * 0.5; y < size.height * 1.5; y += 2) {
        final double wave1 = math.sin(y * waveFrequency) * waveAmplitude;
        final double wave2 = math.sin((y + stripeWidth) * waveFrequency) * waveAmplitude;
        
        final double x1 = offset + y * 0.7 + wave1;
        final double x2 = offset + stripeWidth + y * 0.7 + wave2;
        
        if (y == -size.height * 0.5) {
          path.moveTo(x1, y);
          path.lineTo(x2, y);
        } else {
          path.lineTo(x1, y);
        }
      }
      
      // Complete the stripe
      final double endY = size.height * 1.5;
      final double endWave1 = math.sin(endY * waveFrequency) * waveAmplitude;
      final double endWave2 = math.sin((endY + stripeWidth) * waveFrequency) * waveAmplitude;
      
      path.lineTo(offset + stripeWidth + endY * 0.7 + endWave2, endY);
      
      // Create the other side of the stripe
      for (double y = size.height * 1.5; y >= -size.height * 0.5; y -= 2) {
        final double wave = math.sin((y + stripeWidth) * waveFrequency) * waveAmplitude;
        final double x = offset + stripeWidth + y * 0.7 + wave;
        path.lineTo(x, y);
      }
      
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}