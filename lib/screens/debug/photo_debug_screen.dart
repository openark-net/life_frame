import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

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
    final controller = Get.find<PhotoJournalController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

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
