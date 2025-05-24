import 'package:flutter/cupertino.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Text(
          'Map',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}