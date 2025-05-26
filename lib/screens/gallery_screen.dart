import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../widgets/gallery_image.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Gallery')),
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final entries = controller.allEntries
              .where(
                (entry) =>
                    entry.stitchedPhotoPath != null &&
                    entry.stitchedPhotoPath!.isNotEmpty,
              )
              .toList();

          if (entries.isEmpty) {
            return const Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return GalleryImage(entry: entry);
            },
          );
        }),
      ),
    );
  }
}
