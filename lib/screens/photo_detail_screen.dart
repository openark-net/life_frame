import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../controllers/photo_detail_controller.dart';
import '../models/daily_entry.dart';
import '../widgets/photo_detail/photo_header.dart';
import '../widgets/photo_detail/photo_page_view.dart';

class PhotoDetailScreen extends StatelessWidget {
  final PhotoJournalController controller;
  final DailyEntry initialEntry;

  const PhotoDetailScreen({
    super.key,
    required this.controller,
    required this.initialEntry,
  });

  @override
  Widget build(BuildContext context) {
    final photoDetailController = Get.put(
      PhotoDetailController(
        photoJournalController: controller,
        initialEntry: initialEntry,
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Obx(() {
        if (photoDetailController.isLoading.value) {
          return const Center(
            child: CupertinoActivityIndicator(color: CupertinoColors.white),
          );
        }

        if (photoDetailController.entries.isEmpty) {
          return _buildEmptyState();
        }

        return Stack(
          children: [
            _buildBackground(),
            PhotoPageView(controller: photoDetailController),
            const PhotoHeader(),
          ],
        );
      }),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            CupertinoColors.black.withValues(alpha: 0.8),
            CupertinoColors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const PhotoHeader(),
        const Expanded(
          child: Center(
            child: Text(
              'No photos to display',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        ),
      ],
    );
  }
}
