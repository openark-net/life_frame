import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  String _formatDateForDisplay(String date) {
    try {
      final dateTime = DateTime.parse(date);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

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
              final photoPath = entry.stitchedPhotoPath!;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _formatDateForDisplay(entry.date),
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    // Photo
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: File(photoPath).existsSync()
                            ? Image.file(
                                File(photoPath),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: CupertinoColors.systemGrey6,
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.exclamationmark_triangle,
                                        size: 40,
                                        color: CupertinoColors.systemGrey3,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: CupertinoColors.systemGrey6,
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    size: 40,
                                    color: CupertinoColors.systemGrey3,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
