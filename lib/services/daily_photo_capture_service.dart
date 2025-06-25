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
        locationName: result.locationName,
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

      // Step 1: Capture photos
      final framePhotos = await _capturePhotos(context);
      if (framePhotos == null) {
        _talker.info('User cancelled camera screen');
        return _CaptureResult.cancelled();
      }

      // Step 2: Get initial location
      final locationResult = await _getInitialLocation(context);
      var position = locationResult.position;
      var locationName = locationResult.locationName;

      // Step 3: Enter confirmation loop with current photos
      final confirmResult = await _confirmationLoop(
        context: context,
        framePhotos: framePhotos,
        position: position,
        locationName: locationName,
      );

      if (confirmResult.shouldRetake) {
        _talker.info('User chose to retake photo, continuing outer loop');
        continue;
      }

      if (confirmResult.cancelled) {
        _talker.info('User cancelled during confirmation');
        return _CaptureResult.cancelled();
      }

      // User kept the photo
      _talker.info('Photo capture successful', {
        'attempts': attemptCount,
        'finalLocationName': confirmResult.locationName,
      });

      return _CaptureResult.success(
        confirmResult.photo!,
        confirmResult.position,
        confirmResult.locationName,
      );
    }
  }

  Future<FramePhotos?> _capturePhotos(BuildContext context) async {
    _talker.info('Navigating to camera screen');

    final result = await Navigator.of(context).push<FramePhotos>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => const CameraScreen(),
      ),
    );

    _talker.info('Returned from camera screen', {'hasResult': result != null});

    return result;
  }

  Future<_LocationResult> _getInitialLocation(BuildContext context) async {
    _talker.info('Getting initial location');

    final position = await _locationService.getCurrentLocationWithFallback();

    _talker.info('Received GPS position', {
      'hasPosition': position != null,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'accuracy': position?.accuracy,
    });

    var locationName = await getFormattedLocation(position);

    if (locationName == null) {
      _talker.info(
        'Location formatting failed, showing location selection modal',
      );
      locationName = await _showLocationSelectionModal(context);
      if (locationName == null) {
        _talker.info('User cancelled location selection, using default');
        locationName = 'Unknown Location';
      } else {
        _talker.info('User provided location name', {
          'locationName': locationName,
        });
      }
    }

    return _LocationResult(position: position, locationName: locationName);
  }

  Future<String?> _updateLocation(BuildContext context) async {
    _talker.info('User requested location update');
    return await _showLocationSelectionModal(context);
  }

  Future<ui.Image?> _stitchWithLocation({
    required FramePhotos framePhotos,
    required String locationName,
  }) async {
    _talker.info('Stitching photos with location', {
      'locationName': locationName,
    });

    final photo = await _stitchingService.stitchPhotos(
      framePhotos: framePhotos,
      locationName: locationName,
    );

    if (photo == null) {
      _talker.error('Photo stitching failed');
      _showErrorSnackbar('Failed to process photos');
    }

    return photo;
  }

  Future<_ConfirmationResult> _confirmationLoop({
    required BuildContext context,
    required FramePhotos framePhotos,
    required Position? position,
    required String? locationName,
  }) async {
    _talker.info('Entering confirmation loop');

    var currentLocationName = locationName ?? 'Unknown Location';
    ui.Image? currentPhoto;

    while (true) {
      // Stitch or re-stitch with current location
      currentPhoto = await _stitchWithLocation(
        framePhotos: framePhotos,
        locationName: currentLocationName,
      );

      if (currentPhoto == null) {
        return _ConfirmationResult(
          photo: null,
          position: position,
          locationName: currentLocationName,
          cancelled: false,
          shouldRetake: true,
        );
      }

      // Show confirmation screen
      final confirmResult = await _navigateToConfirmationScreen(
        context,
        currentPhoto,
      );

      switch (confirmResult) {
        case PhotoConfirmationResult.keep:
          _talker.info('User confirmed photo');
          return _ConfirmationResult(
            photo: currentPhoto,
            position: position,
            locationName: currentLocationName,
            cancelled: false,
            shouldRetake: false,
          );

        case PhotoConfirmationResult.cancel:
          _talker.info('User cancelled confirmation');
          return _ConfirmationResult(
            photo: null,
            position: position,
            locationName: currentLocationName,
            cancelled: true,
            shouldRetake: false,
          );

        case PhotoConfirmationResult.retake:
          _talker.info('User wants to retake photo');
          return _ConfirmationResult(
            photo: null,
            position: position,
            locationName: currentLocationName,
            cancelled: false,
            shouldRetake: true,
          );

        case PhotoConfirmationResult.updateLocation:
          _talker.info('User wants to update location');
          final newLocationName = await _updateLocation(context);

          if (newLocationName != null) {
            currentLocationName = newLocationName;
            _talker.info('Location updated', {
              'newLocationName': newLocationName,
            });
          } else {
            _talker.info(
              'User cancelled location update, keeping current location',
            );
          }
          // Continue loop to re-stitch with new location
          break;
      }
    }
  }

  Future<PhotoConfirmationResult> _navigateToConfirmationScreen(
    BuildContext context,
    ui.Image photo,
  ) async {
    _talker.info('Navigating to confirmation screen');

    final result = await Navigator.of(context).push<PhotoConfirmationResult>(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => PhotoConfirmationScreen(photo: photo),
      ),
    );

    return result ?? PhotoConfirmationResult.cancel;
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

class _LocationResult {
  final Position? position;
  final String? locationName;

  _LocationResult({required this.position, required this.locationName});
}

class _ConfirmationResult {
  final ui.Image? photo;
  final Position? position;
  final String? locationName;
  final bool cancelled;
  final bool shouldRetake;

  _ConfirmationResult({
    required this.photo,
    required this.position,
    required this.locationName,
    required this.cancelled,
    required this.shouldRetake,
  });
}
