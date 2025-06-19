import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/daily_entry_controller.dart';

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
    final controller = Get.find<DailyEntryController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
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
          );
        }),
      ),
    );
  }
}
