import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../widgets/gallery/empty_gallery_state.dart';
import '../widgets/gallery/gallery_list.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Gallery')),
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading && controller.paginatedEntries.isEmpty) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (controller.paginatedEntries.isEmpty && !controller.isLoading) {
            return const EmptyGalleryState();
          }

          return const GalleryList();
        }),
      ),
    );
  }
}
