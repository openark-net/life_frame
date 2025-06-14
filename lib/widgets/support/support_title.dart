import 'package:flutter/cupertino.dart';
import '../../openark_theme.dart';

class SupportDescription extends StatelessWidget {
  const SupportDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Support the developer',
          style: TextStyle(
            fontFamily: dmSerifFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: OpenArkColors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Life Frame is a completely free and open source app with no ads that doesn\'t connect '
          'to the internet. Your privacy and photos stay on your device.\n\n'
          'If you\'d like to make a donation to support the app store fees, you can do so below!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 16,
            color: OpenArkColors.foreground.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
