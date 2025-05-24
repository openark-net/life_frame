import 'package:flutter/cupertino.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Text(
          'Gallery',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}