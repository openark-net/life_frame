import 'package:flutter/cupertino.dart';

class BugIcon extends StatelessWidget {
  const BugIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        CupertinoIcons.ant,
        color: CupertinoColors.white,
        size: 40,
      ),
    );
  }
}
