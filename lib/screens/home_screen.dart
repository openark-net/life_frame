import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import 'simple_camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today: ${controller.currentDate}',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            controller.hasTodayPhoto
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            color: controller.hasTodayPhoto
                                ? CupertinoColors.systemGreen
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.hasTodayPhoto
                                ? 'Today\'s photo captured!'
                                : 'No photo taken today',
                            style: CupertinoTheme.of(context).textTheme.textStyle,
                          ),
                        ],
                      ),
                      if (controller.todayEntry != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Photo: ${controller.todayEntry!.photoPath.split('/').last}',
                          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                        ),
                        Text(
                          'Location: ${controller.todayEntry!.latitude.toStringAsFixed(6)}, ${controller.todayEntry!.longitude.toStringAsFixed(6)}',
                          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                        ),
                        Text(
                          'Time: ${controller.todayEntry!.timestamp.toString().split('.')[0]}',
                          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${controller.totalPhotosCount}',
                              style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                            ),
                            Text(
                              'Total Photos',
                              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${controller.getStreak()}',
                              style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                            ),
                            Text(
                              'Day Streak',
                              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Text(
                  'Actions:',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
                const SizedBox(height: 12),

                CupertinoButton.filled(
                  onPressed: controller.isLoading ? null : () async {
                    final result = await Navigator.of(context).push<Map<String, String>>(
                      CupertinoPageRoute(
                        builder: (context) => const SimpleCameraScreen(),
                      ),
                    );

                    if (result != null && 
                        result['backPhoto'] != null && 
                        result['frontPhoto'] != null) {
                      final success = await controller.savePhotosFromPaths(
                        backPhotoPath: result['backPhoto']!,
                        frontPhotoPath: result['frontPhoto']!,
                      );

                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Photos captured successfully!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: CupertinoColors.systemGreen,
                          colorText: CupertinoColors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Failed to save photos',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: CupertinoColors.systemRed,
                          colorText: CupertinoColors.white,
                        );
                      }
                    }
                  },
                  child: controller.isLoading
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Text('Capture Photos'),
                ),

                const SizedBox(height: 12),

                if (controller.hasTodayPhoto)
                  CupertinoButton(
                    onPressed: () async {
                      final success = await controller.deleteTodayEntry();
                      if (success) {
                        Get.snackbar(
                          'Deleted',
                          'Today\'s photo entry removed',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: CupertinoColors.systemRed,
                          colorText: CupertinoColors.white,
                        );
                      }
                    },
                    child: const Text('Delete Today\'s Entry'),
                  ),

                // Display captured photos section
                if (controller.todayBackPhoto.isNotEmpty || controller.todayFrontPhoto.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text(
                    'Today\'s Photos:',
                    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      if (controller.todayBackPhoto.isNotEmpty) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Back Camera',
                                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: CupertinoColors.separator,
                                    width: 0.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(controller.todayBackPhoto),
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
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (controller.todayFrontPhoto.isNotEmpty) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Front Camera',
                                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: CupertinoColors.separator,
                                    width: 0.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(controller.todayFrontPhoto),
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
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}