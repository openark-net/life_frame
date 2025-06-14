import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OpenArkLogo extends StatelessWidget {
  const OpenArkLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/logo/openark_stacked.svg', height: 120);
  }
}
