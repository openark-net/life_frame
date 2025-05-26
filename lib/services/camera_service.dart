import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Captures a photo using the specified camera
  Future<String?> capturePhoto({required bool isBackCamera}) async {
    try {
      // For iOS, try without size constraints first
      final bool isIOS = Platform.isIOS;

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isBackCamera
            ? CameraDevice.rear
            : CameraDevice.front,
        imageQuality: 100,
      );

      return photo?.path;
    } catch (e) {
      throw CameraException('Error taking picture: $e');
    }
  }

  /// Alternative capture method for iOS with different settings
  Future<String?> capturePhotoIOS({required bool isBackCamera}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isBackCamera
            ? CameraDevice.rear
            : CameraDevice.front,
        // Use higher quality for iOS
        imageQuality: 100,
        // No size constraints
        maxWidth: null,
        maxHeight: null,
        requestFullMetadata: true,
      );

      return photo?.path;
    } catch (e) {
      throw CameraException('Error taking picture: $e');
    }
  }
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);

  @override
  String toString() => 'CameraException: $message';
}
