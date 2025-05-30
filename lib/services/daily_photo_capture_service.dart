import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:life_frame/models/frame_photos.dart';
import 'package:life_frame/services/image_filesystem.dart';
import 'package:life_frame/services/location.dart';
import '../controllers/photo_journal_controller.dart';
import '../screens/simple_camera_screen.dart';
import '../screens/photo_confirmation_screen.dart';
import '../services/photo_stitching_service.dart';

class DailyPhotoCaptureService {
  final PhotoJournalController _controller = Get.find<PhotoJournalController>();
  final PhotoStitchingService _stitchingService = PhotoStitchingService();
  final LocationService _locationService = Get.find<LocationService>();

  Future<bool> captureDailyPhoto(BuildContext context) async {
    try {
      final result = await _captureAndConfirmPhoto(context);
      if (!result.success || result.photo == null || result.position == null) {
        return false;
      }

      final photoPath = await ImageFilesystem.saveImageWithMetadata(
        result.photo!,
        latitude: result.position?.latitude,
        longitude: result.position?.longitude,
      );

      final newEntry = await _controller.savePhotoEntry(
        photoPath: photoPath,
        latitude: result.position?.latitude ?? 0.0,
        longitude: result.position?.longitude ?? 0.0,
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

  Future<_CaptureResult> _captureAndConfirmPhoto(BuildContext context) async {
    while (true) {
      final framePhotos = await _navigateToCameraScreen(context);
      if (framePhotos == null) {
        return _CaptureResult.cancelled();
      }

      final position = await _getLocationInstantly();

      final ui.Image? photo = await _stitchingService.stitchPhotos(
        framePhotos: framePhotos,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (photo == null) {
        _showErrorSnackbar('Failed to process photos');
        return _CaptureResult.failed();
      }

      final shouldKeep = await _navigateToConfirmationScreen(context, photo);
      if (shouldKeep == null) {
        return _CaptureResult.cancelled();
      }

      if (shouldKeep) {
        return _CaptureResult.success(photo, position);
      }

      // User wants to retake, continue the loop
    }
  }

  Future<bool?> _navigateToConfirmationScreen(
    BuildContext context,
    ui.Image photo,
  ) async {
    return await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => PhotoConfirmationScreen(photo: photo),
      ),
    );
  }

  Future<FramePhotos?> _navigateToCameraScreen(BuildContext context) async {
    return await Navigator.of(context).push<FramePhotos>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const SimpleCameraScreen(),
      ),
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

class _CaptureResult {
  final bool success;
  final ui.Image? photo;
  final Position? position;

  _CaptureResult._(this.success, this.photo, this.position);

  factory _CaptureResult.success(ui.Image photo, Position? position) =>
      _CaptureResult._(true, photo, position);

  factory _CaptureResult.cancelled() => _CaptureResult._(false, null, null);

  factory _CaptureResult.failed() => _CaptureResult._(false, null, null);
}
