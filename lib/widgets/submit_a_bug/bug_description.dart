import 'package:flutter/cupertino.dart';
import '../common/inline_codeblock.dart';

class BugDescription extends StatelessWidget {
  const BugDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;

    return Column(
      children: [
        Text(
          'Found a bug? I\'d love to fix it!',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Use "Share logs" to email me your app logs at:',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const InlineCodeblock(text: 'isaac@openark.net'),
        const SizedBox(height: 12),
        Text(
          'Or if you have a GitHub account, create an issue using "Github Issues" below.',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for helping improve Life Frame!',
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
