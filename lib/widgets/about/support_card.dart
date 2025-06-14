import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../openark_theme.dart';

class SupportCard extends StatelessWidget {
  final Widget child;

  const SupportCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: OpenArkColors.background.withValues(
                alpha: 0.74,
              ), // Very transparent
              borderRadius: BorderRadius.circular(24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
