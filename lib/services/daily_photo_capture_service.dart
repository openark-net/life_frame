import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/photo_journal_controller.dart';
import '../screens/simple_camera_screen.dart';
import '../services/photo_stitching_service.dart';

class DailyPhotoCaptureService {
  final PhotoJournalController _controller = Get.find<PhotoJournalController>();
  final PhotoStitchingService _stitchingService = PhotoStitchingService();

  Future<bool> captureDailyPhoto(BuildContext context) async {
    try {
      // Step 1: Navigate to camera screen and capture photos
      final result = await _navigateToCameraScreen(context);
      if (result == null || result['backPhoto'] == null || result['frontPhoto'] == null) {
        return false;
      }

      // Step 2: Get current location
      final position = await _getCurrentLocation();
      
      // Step 3: Automatically stitch photos together
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

      // Step 4: Save the photo entry with location
      final success = await _controller.savePhotoEntry(
        photoPath: stitchedPhotoPath,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        stitchedPhotoPath: stitchedPhotoPath,
      );

      if (success) {
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

  Future<Map<String, String>?> _navigateToCameraScreen(BuildContext context) async {
    return await Navigator.of(context).push<Map<String, String>>(
      CupertinoPageRoute(
        builder: (context) => const SimpleCameraScreen(),
      ),
    );
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permissions are denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
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