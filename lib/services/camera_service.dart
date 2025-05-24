// File: ./lib/services/camera_service.dart
import 'package:image_picker/image_picker.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Captures a photo using the specified camera
  Future<String?> capturePhoto({
    required bool isBackCamera,
    int imageQuality = 85,
    double? maxWidth = 1920,
    double? maxHeight = 1920,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isBackCamera
            ? CameraDevice.rear
            : CameraDevice.front,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return photo?.path;
    } catch (e) {
      throw CameraException('Error taking picture: $e');
    }
  }

  /// Picks an image from gallery
  Future<String?> pickFromGallery({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return photo?.path;
    } catch (e) {
      throw CameraException('Error picking image: $e');
    }
  }
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);

  @override
  String toString() => 'CameraException: $message';
}