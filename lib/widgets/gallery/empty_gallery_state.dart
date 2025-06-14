// lib/widgets/gallery/empty_gallery_state.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

class EmptyGalleryState extends StatelessWidget {
  const EmptyGalleryState({super.key});

  Future<void> _onRefresh() async {
    final controller = Get.find<PhotoJournalController>();
    await controller.refreshEntries();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _onRefresh),
        const SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.photo_on_rectangle,
                  size: 80,
                  color: CupertinoColors.systemGrey3,
                ),
                SizedBox(height: 16),
                Text(
                  'No photos yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start your daily photo journey!',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
