import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraLensType;
import 'package:flutter/foundation.dart';

import '../models/camera_lens_option.dart';

class CameraLensService {
  static const double _ultraWideRatioThreshold = 0.95;

  const CameraLensService();

  CameraDescription? defaultBack(List<CameraDescription> cameras) =>
      _firstWithDirection(cameras, CameraLensDirection.back);

  CameraDescription? defaultFront(List<CameraDescription> cameras) =>
      _firstWithDirection(cameras, CameraLensDirection.front);

  List<CameraLensOption> resolveBackOptions({
    required List<CameraDescription> cameras,
    required CameraDescription activeBack,
    double minZoomRatio = 1.0,
    Map<String, double> iosZoomFactors = const {},
  }) {
    final options = defaultTargetPlatform == TargetPlatform.iOS
        ? _physicalLensOptions(cameras, iosZoomFactors)
        : _zoomRatioOptions(activeBack, minZoomRatio);

    final hasNativeDefault = options.any(
      (option) => option.camera == activeBack && option.zoomRatio == 1.0,
    );
    if (options.length < 2 || !hasNativeDefault) {
      return [CameraLensOption(label: _formatRatio(1.0), camera: activeBack)];
    }
    return options;
  }

  CameraLensOption initialSelection(
    List<CameraLensOption> options,
    CameraDescription activeBack,
  ) {
    return options.firstWhere(
      (option) => option.camera == activeBack && option.zoomRatio == 1.0,
      orElse: () => options.first,
    );
  }

  String _formatRatio(double ratio) {
    final rounded = (ratio * 10).roundToDouble() / 10;
    final text = rounded == rounded.truncateToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
    return '${text}x';
  }

  CameraDescription? _firstWithDirection(
    List<CameraDescription> cameras,
    CameraLensDirection direction,
  ) {
    if (cameras.isEmpty) return null;
    return cameras.firstWhere(
      (camera) => camera.lensDirection == direction,
      orElse: () => cameras.first,
    );
  }

  List<CameraLensOption> _physicalLensOptions(
    List<CameraDescription> cameras,
    Map<String, double> zoomFactors,
  ) {
    final backs = cameras
        .where((camera) => camera.lensDirection == CameraLensDirection.back)
        .toList();

    final ultraWide = _firstOfType(backs, CameraLensType.ultraWide);
    final wide = _firstOfType(backs, CameraLensType.wide);
    final telephoto = _firstOfType(backs, CameraLensType.telephoto);

    return [
      if (ultraWide != null)
        CameraLensOption(
          label: _labelFor(ultraWide, zoomFactors, fallback: '0.5x'),
          camera: ultraWide,
        ),
      if (wide != null)
        CameraLensOption(
          label: _labelFor(wide, zoomFactors, fallback: '1x'),
          camera: wide,
        ),
      if (telephoto != null)
        CameraLensOption(
          label: _labelFor(telephoto, zoomFactors, fallback: 'Tele'),
          camera: telephoto,
        ),
    ];
  }

  CameraDescription? _firstOfType(
    List<CameraDescription> backs,
    CameraLensType lensType,
  ) {
    for (final camera in backs) {
      if (camera.lensType == lensType) return camera;
    }
    return null;
  }

  String _labelFor(
    CameraDescription camera,
    Map<String, double> zoomFactors, {
    required String fallback,
  }) {
    final factor = zoomFactors[camera.name];
    if (factor == null || factor <= 0) return fallback;
    return _formatRatio(factor);
  }

  List<CameraLensOption> _zoomRatioOptions(
    CameraDescription activeBack,
    double minZoomRatio,
  ) {
    return [
      if (minZoomRatio > 0 && minZoomRatio < _ultraWideRatioThreshold)
        CameraLensOption(
          label: _formatRatio(minZoomRatio),
          camera: activeBack,
          zoomRatio: minZoomRatio,
        ),
      CameraLensOption(label: _formatRatio(1.0), camera: activeBack),
    ];
  }
}
