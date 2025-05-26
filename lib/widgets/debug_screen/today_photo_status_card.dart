import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

class TodayPhotoStatusCard extends StatelessWidget {
  const TodayPhotoStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.separator, width: 0.5),
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
    );
  }
}
