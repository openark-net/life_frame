import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../openark_theme.dart';

class OpenArkLogo extends StatelessWidget {
  const OpenArkLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/logo/openark_marble.svg',
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          'OpenArk',
          style: TextStyle(
            fontFamily: dmSerifFont,
            fontSize: 54,
            fontWeight: FontWeight.normal,
            color: OpenArkColors.secondary,
          ),
        ),
      ],
    );
  }
}
