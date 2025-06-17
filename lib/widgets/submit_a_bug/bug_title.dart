import 'package:flutter/cupertino.dart';

class BugTitle extends StatelessWidget {
  const BugTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Submit a bug',
      style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
          ?.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
