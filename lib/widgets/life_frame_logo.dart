import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class LifeFrameLogo extends StatelessWidget {
  final double? fontSize;
  final double? logoSize;
  final MainAxisAlignment alignment;
  final VoidCallback? onDoubleTap;

  const LifeFrameLogo({
    super.key,
    this.fontSize = 38,
    this.logoSize = 48,
    this.alignment = MainAxisAlignment.center,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Life Frame',
          style: TextStyle(
            fontFamily: 'Comfortaa-Bold',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryYellow,
          ),
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          'assets/logo/logo.svg',
          width: logoSize,
          height: logoSize,
        ),
      ],
    );

    if (onDoubleTap != null) {
      return GestureDetector(onDoubleTap: onDoubleTap, child: logoWidget);
    }

    return logoWidget;
  }
}
