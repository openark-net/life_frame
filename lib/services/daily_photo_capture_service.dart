import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:life_frame/models/frame_photos.dart';
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
      final framePhotos = await _navigateToCameraScreen(context);
      if (framePhotos == null) {
        return false;
      }
      final position = await _getLocationInstantly();

      final photo = await _stitchingService.stitchPhotos(
        framePhotos: framePhotos,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (photo == null) {
        _showErrorSnackbar('Failed to process photos');
        return false;
      }

      // todo: confirm with user

      final photoPath = await ImageMetadata.saveImageWithMetadata(
        photo,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      final newEntry = await _controller.savePhotoEntry(
        photoPath: photoPath,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
      );

      if (newEntry != null) {
        _showSuccessSnackbar('Daily photo captured successfully!');
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

  Future<FramePhotos?> _navigateToCameraScreen(BuildContext context) async {
    return await Navigator.of(context).push<FramePhotos>(
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
