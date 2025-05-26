import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../models/daily_entry.dart';
import '../../controllers/photo_journal_controller.dart';
import '../../screens/photo_detail_screen.dart';

class PhotoTack extends StatelessWidget {
  final DailyEntry entry;
  final double size;

  const PhotoTack({
    super.key,
    required this.entry,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTapped(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: CupertinoColors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.3),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildPhotoPreview(),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    final photoPath = entry.stitchedPhotoPath ?? entry.photoPath;
    
    if (photoPath.isEmpty) {
      return _buildPlaceholder();
    }

    final file = File(photoPath);
    
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingIndicator();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: CupertinoColors.systemGrey4,
      child: Icon(
        CupertinoIcons.photo,
        color: CupertinoColors.systemGrey2,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: size,
      height: size,
      color: CupertinoColors.systemGrey5,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: size * 0.2,
        ),
      ),
    );
  }

  void _onTapped() {
    try {
      final controller = Get.find<PhotoJournalController>();
      
      Navigator.of(Get.context!).push(
        CupertinoPageRoute(
          builder: (context) => PhotoDetailScreen(
            controller: controller,
            initialEntry: entry,
          ),
        ),
      );
    } catch (e) {
      print('PhotoTack: Error opening photo detail: $e');
    }
  }
}