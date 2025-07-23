import 'package:flutter/cupertino.dart';
import '../../openark_theme.dart';

class SupportDescription extends StatelessWidget {
  final bool platformSupportsDonations;

  const SupportDescription({
    super.key,
    required this.platformSupportsDonations,
  });

  @override
  Widget build(BuildContext context) {
    final baseText =
        'Life Frame is a completely free and open source app with no ads that doesn\'t connect '
        'to the internet. Your privacy and photos stay on your device.';

    final fullText = platformSupportsDonations
        ? '$baseText\n\nIf you\'d like to make a donation to support the app store fees, you can do so below!'
        : baseText;

    return Column(
      children: [
        Text(
          fullText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 16,
            color: OpenArkColors.foreground.withOpacity(0.7),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
