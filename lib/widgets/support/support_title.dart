import 'package:flutter/cupertino.dart';
import '../../theme.dart';

class SupportDescription extends StatelessWidget {
  const SupportDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Support the developer',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Life Frame is a completely free app with no ads that doesn\'t connect to the internet. Your privacy and photos stay on your device.\n\nIf you\'d like to support the developer, you can do so below!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            color: AppColors.secondaryText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
