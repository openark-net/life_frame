import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/daily_entry.dart';
import '../utils/location_formatter.dart';
import '../controllers/photo_journal_controller.dart';
import '../screens/photo_detail_screen.dart';

class GalleryImage extends StatelessWidget {
  final DailyEntry entry;

  const GalleryImage({super.key, required this.entry});

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

  Widget _buildPhotoWidget(BuildContext context) {
    String? photoPath;

    // Prefer stitched photo if it exists
    if (entry.stitchedPhotoPath != null &&
        entry.stitchedPhotoPath!.isNotEmpty &&
        File(entry.stitchedPhotoPath!).existsSync()) {
      photoPath = entry.stitchedPhotoPath;
    } else if (entry.photoPath.isNotEmpty &&
        File(entry.photoPath).existsSync()) {
      photoPath = entry.photoPath;
    }

    if (photoPath != null) {
      return Image.file(
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
      );
    } else {
      return Container(
        color: CupertinoColors.systemGrey6,
        child: const Center(
          child: Icon(
            CupertinoIcons.photo,
            size: 40,
            color: CupertinoColors.systemGrey3,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final controller = Get.find<PhotoJournalController>();
        Get.to(
          () => PhotoDetailScreen(controller: controller, initialEntry: entry),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
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
            // Date and location header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateForDisplay(entry.date),
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              CupertinoTheme.of(context).brightness ==
                                  Brightness.dark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                  ),
                  FutureBuilder<String>(
                    future: getFormattedLocation(
                      entry.latitude,
                      entry.longitude,
                    ),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Loading...',
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontSize: 14,
                              color:
                                  CupertinoTheme.of(context).brightness ==
                                      Brightness.dark
                                  ? CupertinoColors.systemGrey2
                                  : CupertinoColors.systemGrey,
                            ),
                      );
                    },
                  ),
                ],
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
                child: _buildPhotoWidget(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
