import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'services/storage_service.dart';
import 'controllers/photo_journal_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() async {
    final service = StorageService();
    await service.onInit();
    return service;
  });
  Get.put(PhotoJournalController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'Life Frame',
      theme: CupertinoThemeData(
        brightness: MediaQuery.platformBrightnessOf(context),
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: const MyHomePage(title: 'Life Frame'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
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
                            style: CupertinoTheme.of(
                              context,
                            ).textTheme.textStyle,
                          ),
                        ],
                      ),
                      if (controller.todayEntry != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Photo: ${controller.todayEntry!.photoPath.split('/').last}',
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.tabLabelTextStyle,
                        ),
                        Text(
                          'Location: ${controller.todayEntry!.latitude.toStringAsFixed(6)}, ${controller.todayEntry!.longitude.toStringAsFixed(6)}',
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.tabLabelTextStyle,
                        ),
                        Text(
                          'Time: ${controller.todayEntry!.timestamp.toString().split('.')[0]}',
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.tabLabelTextStyle,
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
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.navLargeTitleTextStyle,
                            ),
                            Text(
                              'Total Photos',
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.tabLabelTextStyle,
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
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.navLargeTitleTextStyle,
                            ),
                            Text(
                              'Day Streak',
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.tabLabelTextStyle,
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
                  onPressed: () async {
                    final success = await controller.savePhotoEntry(
                      photoPath:
                          '/mock/path/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      latitude: 37.7749 + (DateTime.now().millisecond / 10000),
                      longitude:
                          -122.4194 + (DateTime.now().millisecond / 10000),
                    );

                    if (success) {
                      Get.snackbar(
                        'Success',
                        'Demo photo entry saved!',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: CupertinoColors.systemGreen,
                        colorText: CupertinoColors.white,
                      );
                    }
                  },
                  child: const Text('Simulate Photo Capture'),
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
              ],
            );
          }),
        ),
      ),
    );
  }
}
