import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

import 'package:life_frame/controllers/daily_entry_controller.dart';
import 'package:life_frame/services/image_filesystem.dart';

class ImageRestorationService {
  final Talker _talker = Get.find<Talker>();
  final DailyEntryController _dailyEntryController =
      Get.find<DailyEntryController>();

  static const String _lifeFrameDirectoryName = 'LifeFrame';

  /// Restores images from Pictures/LifeFrame directory to the database
  /// Returns the number of images successfully restored
  Future<int> restoreImagesFromDirectory() async {
    try {
      _talker.info('Starting image restoration process');

      // Step 1: Get all images from Pictures/LifeFrame directory
      final imageFiles = await _getImagesFromLifeFrameDirectory();
      _talker.info(
        'Found ${imageFiles.length} image files in LifeFrame directory',
      );

      if (imageFiles.isEmpty) {
        _talker.info('No images found to restore');
        return 0;
      }

      int restoredCount = 0;

      // Step 2 & 3: Process each image file
      for (final file in imageFiles) {
        try {
          // Step 2: Load the image as a DailyEntry through ImageFileSystem
          final dailyEntry = await ImageFilesystem.loadDailyEntry(file);

          if (dailyEntry == null) {
            _talker.warning(
              'Could not load daily entry from file: ${file.path}',
            );
            continue;
          }

          // Step 3: Check if we already have an image with this timestamp
          final existingEntry = await _dailyEntryController.getImageByTimestamp(
            dailyEntry.timestamp,
          );

          if (existingEntry != null) {
            _talker.debug(
              'Entry already exists for timestamp: ${dailyEntry.timestamp.toIso8601String()}',
            );
            continue;
          }

          // Insert the daily entry if it doesn't exist
          final success = await _dailyEntryController.insertDailyEntry(
            dailyEntry,
          );
          if (success) {
            restoredCount++;
            _talker.info('Restored image: ${path.basename(file.path)}');
          } else {
            _talker.warning('Failed to insert daily entry for: ${file.path}');
          }
        } catch (e, st) {
          _talker.handle(e, st, 'Error processing file: ${file.path}');
        }
      }

      _talker.info(
        'Image restoration completed. Restored $restoredCount out of ${imageFiles.length} images',
      );
      return restoredCount;
    } catch (e, st) {
      _talker.handle(e, st, 'Error during image restoration process');
      return 0;
    }
  }

  /// Step 1: Get all image files from Pictures/LifeFrame directory
  Future<List<File>> _getImagesFromLifeFrameDirectory() async {
    try {
      Directory? storageDir;

      if (Platform.isAndroid) {
        // On Android, use external storage directory
        storageDir = await getExternalStorageDirectory();
        if (storageDir != null) {
          // Navigate to the Pictures directory in external storage
          // External storage path is typically /storage/emulated/0/Android/data/package/files
          // But Pictures is at /storage/emulated/0/Pictures
          final pathParts = storageDir.path.split('/');
          final storageRootIndex = pathParts.indexOf('Android');
          if (storageRootIndex > 0) {
            final storageRoot = pathParts
                .sublist(0, storageRootIndex)
                .join('/');
            storageDir = Directory(path.join(storageRoot, 'Pictures'));
          }
        }
      } else if (Platform.isIOS) {
        // On iOS, try to access the Pictures directory
        // Note: This might require additional permissions
        final documentsDir = await getApplicationDocumentsDirectory();
        storageDir = Directory(path.join(documentsDir.parent.path, 'Pictures'));
      }

      if (storageDir == null) {
        _talker.warning('Could not determine storage directory for platform');
        return [];
      }

      final lifeFrameDir = Directory(
        path.join(storageDir.path, _lifeFrameDirectoryName),
      );

      _talker.debug('Looking for images in: ${lifeFrameDir.path}');

      // Check if the LifeFrame directory exists
      if (!await lifeFrameDir.exists()) {
        _talker.info(
          'LifeFrame directory does not exist: ${lifeFrameDir.path}',
        );
        return [];
      }

      // Get all files in the directory
      final List<FileSystemEntity> entities = await lifeFrameDir
          .list()
          .toList();

      // Filter for image files (jpg, jpeg, png)
      final imageFiles = entities
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .toList();

      _talker.debug('Found ${imageFiles.length} image files');
      return imageFiles;
    } catch (e, st) {
      _talker.handle(e, st, 'Error accessing LifeFrame directory');
      return [];
    }
  }

  /// Helper method to check if a file is an image based on its extension
  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(extension);
  }

  /// Gets the path to the LifeFrame directory in Pictures
  Future<String> getLifeFrameDirectoryPath() async {
    try {
      Directory? storageDir;

      if (Platform.isAndroid) {
        storageDir = await getExternalStorageDirectory();
        if (storageDir != null) {
          final pathParts = storageDir.path.split('/');
          final storageRootIndex = pathParts.indexOf('Android');
          if (storageRootIndex > 0) {
            final storageRoot = pathParts
                .sublist(0, storageRootIndex)
                .join('/');
            storageDir = Directory(path.join(storageRoot, 'Pictures'));
          }
        }
      } else if (Platform.isIOS) {
        final documentsDir = await getApplicationDocumentsDirectory();
        storageDir = Directory(path.join(documentsDir.parent.path, 'Pictures'));
      }

      if (storageDir == null) {
        return 'Pictures/$_lifeFrameDirectoryName (location unknown)';
      }

      return path.join(storageDir.path, _lifeFrameDirectoryName);
    } catch (e) {
      return 'Pictures/$_lifeFrameDirectoryName (error accessing path)';
    }
  }
}
