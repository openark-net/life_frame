import 'package:flutter/cupertino.dart';
import '../../widgets/debug_screen/action_buttons.dart';

class PhotoDebugScreen extends StatefulWidget {
  const PhotoDebugScreen({super.key});

  @override
  State<PhotoDebugScreen> createState() => _PhotoDebugScreenState();
}

class _PhotoDebugScreenState extends State<PhotoDebugScreen> {
  String? stitchedPhotoPath;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActionButtons(
              onStitchedPhotoChanged: (path) {
                setState(() {
                  stitchedPhotoPath = path;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
