import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_detail_controller.dart';
import '../../models/daily_entry.dart';
import 'photo_preview.dart';
import 'animated_photo.dart';

class PhotoStack extends StatelessWidget {
  final PhotoDetailController controller;
  final DailyEntry entry;
  final int index;
  final bool isCurrentPage;

  const PhotoStack({
    super.key,
    required this.controller,
    required this.entry,
    required this.index,
    required this.isCurrentPage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCurrentPage) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (controller.hasNextPhoto && index == controller.currentIndex.value)
          Obx(
            () => PhotoPreview(
              controller: controller,
              photoPath: controller.nextEntry!.stitchedPhotoPath!,
              rotation: controller.nextPhotoRotation.value,
            ),
          ),
        Obx(
          () => AnimatedPhoto(
            controller: controller,
            photoPath: entry.stitchedPhotoPath!,
            rotation: controller.currentPhotoRotation.value,
          ),
        ),
      ],
    );
  }
}
