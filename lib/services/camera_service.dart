import 'package:image_picker/image_picker.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto({required bool isBackCamera}) async {
    try {
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
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);

  @override
  String toString() => 'CameraException: $message';
}
