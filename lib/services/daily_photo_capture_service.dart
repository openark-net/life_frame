import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:life_frame/models/frame_photos.dart';
import 'package:life_frame/services/image_filesystem.dart';
import 'package:life_frame/services/location.dart';
import '../controllers/daily_entry_controller.dart';
import '../models/daily_entry.dart';
import '../screens/capture/camera_screen.dart';
import '../screens/capture/photo_confirmation_screen.dart';
import '../services/photo_stitching_service.dart';
import '../widgets/capture/location_selection_modal.dart';
import 'package:talker/talker.dart';

import '../utils/location_formatter.dart';

class DailyPhotoCaptureService {
  final DailyEntryController _controller = Get.find<DailyEntryController>();
  final PhotoStitchingService _stitchingService = PhotoStitchingService();
  final LocationService _locationService = Get.find<LocationService>();
  final Talker _talker = Get.find<Talker>();

  Future<bool> captureDailyPhoto(BuildContext context) async {
    _talker.info('Starting daily photo capture');

    try {
      final result = await _captureAndConfirmPhoto(context);

      if (!result.success) {
        _talker.warning('Photo capture was not successful');
        return false;
      }

      if (result.photo == null) {
        _talker.error('Photo capture result is null');
        return false;
      }

      if (result.position == null) {
        _talker.warning('Position is null for photo capture');
      }

      _talker.info('Saving image with metadata', {
        'hasPosition': result.position != null,
        'latitude': result.position?.latitude,
        'longitude': result.position?.longitude,
      });

      final photoPath = await ImageFilesystem.saveImageWithMetadata(
        result.photo!,
        latitude: result.position?.latitude,
        longitude: result.position?.longitude,
      );

      _talker.info('Image saved to filesystem', {'photoPath': photoPath});

      final locationName = result.locationName ?? 'Unknown Location';

      final entry = DailyEntry(
        timestamp: DateTime.now(),
        photoPath: photoPath,
        latitude: result.position?.latitude ?? 0.0,
        longitude: result.position?.longitude ?? 0.0,
        locationName: locationName,
      );

      final success = await _controller.insertDailyEntry(entry);

      if (success) {
        _talker.info(
          'Daily photo captured and saved successfully',
          entry.toMap(),
        );
        _showSuccessSnackbar('Daily photo captured successfully!');
        return true;
      } else {
        _talker.error('Failed to save photo entry to controller');
        _showErrorSnackbar('Failed to save photo entry');
        return false;
      }
    } catch (e, stackTrace) {
      _talker.error('Error capturing daily photo', e, stackTrace);
      _showErrorSnackbar('An error occurred while capturing your photo');
      return false;
    }
  }

  Future<_CaptureResult> _captureAndConfirmPhoto(BuildContext context) async {
    _talker.info('Starting capture and confirm photo flow');

    int attemptCount = 0;
    while (true) {
      attemptCount++;
      _talker.info('Photo capture attempt', {'attemptNumber': attemptCount});

      final framePhotos = await _navigateToCameraScreen(context);
      if (framePhotos == null) {
        _talker.info('User cancelled camera screen');
        return _CaptureResult.cancelled();
      }

      final position = await _getLocationInstantly();
      var locationName = await getFormattedLocation(position);

      if (locationName == null) {
        _talker.info('Location name is null, opening location selection modal');
        locationName = await _showLocationSelectionModal(context);
        if (locationName == null) {
          _talker.info('User cancelled location selection');
        } else {
          _talker.info('User provided location name', {
            'locationName': locationName,
          });
        }
      }

      final ui.Image? photo = await _stitchingService.stitchPhotos(
        framePhotos: framePhotos,
        locationName: locationName ?? '',
      );

      if (photo == null) {
        _talker.error('Photo stitching failed, returning null');
        _showErrorSnackbar('Failed to process photos');
        return _CaptureResult.failed();
      }

      _talker.info('Photo stitching successful, navigating to confirmation');

      final shouldKeep = await _navigateToConfirmationScreen(context, photo);
      if (shouldKeep == null) {
        _talker.info('User cancelled confirmation screen');
        return _CaptureResult.cancelled();
      }

      if (shouldKeep) {
        _talker.info('User confirmed photo, capture successful', {
          'attempts': attemptCount,
        });
        return _CaptureResult.success(photo, position, locationName);
      }

      _talker.info('User chose to retake photo, continuing loop');
    }
  }

  Future<PhotoConfirmationResult> _navigateToConfirmationScreen(
    BuildContext context,
    ui.Image photo,
  ) async {
    final result = await Navigator.of(context).push<PhotoConfirmationResult>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => PhotoConfirmationScreen(photo: photo),
      ),
    );
    return result ?? PhotoConfirmationResult.cancel;
  }

  Future<FramePhotos?> _navigateToCameraScreen(BuildContext context) async {
    _talker.info('Navigating to camera screen');

    final result = await Navigator.of(context).push<FramePhotos>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const CameraScreen(),
      ),
    );

    _talker.info('Returned from camera screen', {
      'hasResult': result != null,
      'hasFrontPhoto': result?.front != null,
      'hasBackPhoto': result?.back != null,
    });

    return result;
  }

  Future<Position?> _getLocationInstantly() async {
    final position = await _locationService.getCurrentLocationWithFallback();

    _talker.info('Received location', {
      'hasPosition': position != null,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'accuracy': position?.accuracy,
    });

    return position;
  }

  Future<String?> _showLocationSelectionModal(BuildContext context) async {
    _talker.info('Showing location selection modal');

    final result = await Navigator.of(context).push<String>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const LocationSelectionModal(),
      ),
    );

    return result;
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
  final String? locationName;

  _CaptureResult._(this.success, this.photo, this.position, this.locationName);

  factory _CaptureResult.success(
    ui.Image photo,
    Position? position,
    String? locationName,
  ) => _CaptureResult._(true, photo, position, locationName);

  factory _CaptureResult.cancelled() =>
      _CaptureResult._(false, null, null, null);

  factory _CaptureResult.failed() => _CaptureResult._(false, null, null, null);
}
