import 'package:camera/camera.dart';

class CameraLensOption {
  final String label;
  final CameraDescription camera;
  final double zoomRatio;

  const CameraLensOption({
    required this.label,
    required this.camera,
    this.zoomRatio = 1.0,
  });
}
