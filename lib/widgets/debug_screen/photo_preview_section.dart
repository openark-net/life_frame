import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

class PhotoPreviewSection extends StatelessWidget {
  const PhotoPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(() {
      if (controller.todayBackPhoto.isEmpty &&
          controller.todayFrontPhoto.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Photos:',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (controller.todayBackPhoto.isNotEmpty) ...[
                Expanded(
                  child: _PhotoPreview(
                    title: 'Back Camera',
                    imagePath: controller.todayBackPhoto,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (controller.todayFrontPhoto.isNotEmpty) ...[
                Expanded(
                  child: _PhotoPreview(
                    title: 'Front Camera',
                    imagePath: controller.todayFrontPhoto,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }
}

class _PhotoPreview extends StatelessWidget {
  final String title;
  final String imagePath;

  const _PhotoPreview({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CupertinoTheme.of(
            context,
          ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.separator, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: CupertinoColors.systemGrey6,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.camera,
                      size: 40,
                      color: CupertinoColors.systemGrey3,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
