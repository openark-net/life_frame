import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:life_frame/services/image_metadata.dart';
import 'package:life_frame/services/location.dart';
import '../controllers/photo_journal_controller.dart';
import '../screens/simple_camera_screen.dart';
import '../services/photo_stitching_service.dart';

class DailyPhotoCaptureService {
  final PhotoJournalController _controller = Get.find<PhotoJournalController>();
  final PhotoStitchingService _stitchingService = PhotoStitchingService();
  final LocationService _locationService = Get.find<LocationService>();

  Future<bool> captureDailyPhoto(BuildContext context) async {
    try {
      final result = await _navigateToCameraScreen(context);
      if (result == null ||
          result['backPhoto'] == null ||
          result['frontPhoto'] == null) {
        return false;
      }

      final position = await _getLocationInstantly();

      final stitchedPhotoPath = await _stitchingService.stitchPhotos(
        backPhotoPath: result['backPhoto']!,
        frontPhotoPath: result['frontPhoto']!,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (stitchedPhotoPath == null) {
        _showErrorSnackbar('Failed to process photos');
        return false;
      }

      final newEntry = await _controller.savePhotoEntry(
        photoPath: stitchedPhotoPath,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        stitchedPhotoPath: stitchedPhotoPath,
      );

      if (newEntry != null) {
        _showSuccessSnackbar('Daily photo captured successfully!');
        ImageMetadata.applyMetadata(newEntry);
        return true;
      } else {
        _showErrorSnackbar('Failed to save photo entry');
        return false;
      }
    } catch (e) {
      print('DailyPhotoCaptureService: Error capturing daily photo: $e');
      _showErrorSnackbar('An error occurred while capturing your photo');
      return false;
    }
  }

  Future<Map<String, String>?> _navigateToCameraScreen(
    BuildContext context,
  ) async {
    return await Navigator.of(context).push<Map<String, String>>(
      CupertinoPageRoute(builder: (context) => const SimpleCameraScreen()),
    );
  }

  Future<Position?> _getLocationInstantly() async {
    final cachedPosition = _locationService.cachedPosition;

    if (_locationService.hasValidCachedLocation) {
      return cachedPosition;
    }

    return await _locationService.getCurrentLocationWithFallback();
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemGreen,
      colorText: CupertinoColors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: CupertinoColors.systemRed,
      colorText: CupertinoColors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
