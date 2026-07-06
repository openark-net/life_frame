import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraLensType;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_frame/services/camera_lens_service.dart';

CameraDescription _camera({
  required String name,
  required CameraLensDirection direction,
  CameraLensType lensType = CameraLensType.unknown,
}) {
  return CameraDescription(
    name: name,
    lensDirection: direction,
    sensorOrientation: 90,
    lensType: lensType,
  );
}

void main() {
  const service = CameraLensService();

  final backWide = _camera(
    name: 'video:0',
    direction: CameraLensDirection.back,
    lensType: CameraLensType.wide,
  );
  final backTelephoto = _camera(
    name: 'video:2',
    direction: CameraLensDirection.back,
    lensType: CameraLensType.telephoto,
  );
  final backUltraWide = _camera(
    name: 'video:5',
    direction: CameraLensDirection.back,
    lensType: CameraLensType.ultraWide,
  );
  final frontWide = _camera(
    name: 'video:1',
    direction: CameraLensDirection.front,
    lensType: CameraLensType.wide,
  );
  final frontUltraWide = _camera(
    name: 'video:8',
    direction: CameraLensDirection.front,
    lensType: CameraLensType.ultraWide,
  );

  group('default camera selection', () {
    test('picks the first back camera in list order', () {
      final cameras = [frontWide, backWide, backUltraWide];
      expect(service.defaultBack(cameras), backWide);
    });

    test('picks the first front camera in list order', () {
      final cameras = [backWide, frontWide, frontUltraWide];
      expect(service.defaultFront(cameras), frontWide);
    });

    test('falls back to the first camera when direction is missing', () {
      final cameras = [frontWide];
      expect(service.defaultBack(cameras), frontWide);
    });

    test('returns null for an empty list', () {
      expect(service.defaultBack(const []), isNull);
      expect(service.defaultFront(const []), isNull);
    });
  });

  group('iOS lens options', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('triple camera resolves ultra-wide, wide, telephoto in order', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, frontWide, backTelephoto, backUltraWide],
        activeBack: backWide,
        iosZoomFactors: {
          backUltraWide.name: 0.5,
          backWide.name: 1.0,
          backTelephoto.name: 3.0,
        },
      );

      expect(options.map((option) => option.label), ['0.5x', '1x', '3x']);
      expect(options.map((option) => option.camera), [
        backUltraWide,
        backWide,
        backTelephoto,
      ]);
    });

    test('every iOS option keeps zoomRatio 1.0', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, backTelephoto, backUltraWide],
        activeBack: backWide,
        iosZoomFactors: {backTelephoto.name: 5.0},
      );

      expect(options.every((option) => option.zoomRatio == 1.0), isTrue);
      expect(options.map((option) => option.label), ['0.5x', '1x', '5x']);
    });

    test('missing zoom factors fall back to 0.5x, 1x and Tele', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, backTelephoto, backUltraWide],
        activeBack: backWide,
      );

      expect(options.map((option) => option.label), ['0.5x', '1x', 'Tele']);
    });

    test('telephoto factor formats without trailing zeros', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, backTelephoto],
        activeBack: backWide,
        iosZoomFactors: {backTelephoto.name: 2.5},
      );

      expect(options.map((option) => option.label), ['1x', '2.5x']);
    });

    test('wide plus ultra-wide pair resolves two options', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, frontWide, backUltraWide],
        activeBack: backWide,
      );

      expect(options.map((option) => option.camera), [backUltraWide, backWide]);
    });

    test('single back camera collapses to one option', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, frontWide],
        activeBack: backWide,
      );

      expect(options, hasLength(1));
      expect(options.single.camera, backWide);
      expect(options.single.label, '1x');
    });

    test('unknown lens types collapse to the active camera only', () {
      final unknownA = _camera(
        name: 'video:0',
        direction: CameraLensDirection.back,
      );
      final unknownB = _camera(
        name: 'video:9',
        direction: CameraLensDirection.back,
      );

      final options = service.resolveBackOptions(
        cameras: [unknownA, unknownB],
        activeBack: unknownA,
      );

      expect(options, hasLength(1));
      expect(options.single.camera, unknownA);
    });

    test('collapses when the active camera is not among the options', () {
      final unknownActive = _camera(
        name: 'video:0',
        direction: CameraLensDirection.back,
      );

      final options = service.resolveBackOptions(
        cameras: [unknownActive, backUltraWide],
        activeBack: unknownActive,
      );

      expect(options, hasLength(1));
      expect(options.single.camera, unknownActive);
      expect(options.single.zoomRatio, 1.0);
    });

    test('front ultra-wide entries never appear as back options', () {
      final options = service.resolveBackOptions(
        cameras: [backWide, frontWide, backUltraWide, frontUltraWide],
        activeBack: backWide,
      );

      expect(
        options.every(
          (option) => option.camera.lensDirection == CameraLensDirection.back,
        ),
        isTrue,
      );
      expect(
        options.map((option) => option.camera),
        isNot(contains(frontUltraWide)),
      );
    });
  });

  group('Android lens options', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    final logicalBack = _camera(name: '0', direction: CameraLensDirection.back);

    test('min zoom 1.0 collapses to a single 1x option', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack, frontWide],
        activeBack: logicalBack,
        minZoomRatio: 1.0,
      );

      expect(options, hasLength(1));
      expect(options.single.label, '1x');
      expect(options.single.zoomRatio, 1.0);
    });

    test('sub-1.0 min zoom adds an ultra-wide preset with the exact ratio', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack, frontWide],
        activeBack: logicalBack,
        minZoomRatio: 0.5994849,
      );

      expect(options.map((option) => option.label), ['0.6x', '1x']);
      expect(options.first.zoomRatio, 0.5994849);
      expect(options.last.zoomRatio, 1.0);
    });

    test('all Android options share the active back camera', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack, frontWide],
        activeBack: logicalBack,
        minZoomRatio: 0.6,
      );

      expect(options.every((option) => option.camera == logicalBack), isTrue);
    });

    test('near-1.0 min zoom stays a single option at the threshold', () {
      final atThreshold = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 0.95,
      );
      final belowThreshold = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 0.94,
      );

      expect(atThreshold, hasLength(1));
      expect(belowThreshold.map((option) => option.label), ['0.9x', '1x']);
    });

    test('iOS zoom factors are ignored on Android', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 0.7,
        iosZoomFactors: {logicalBack.name: 3.0},
      );

      expect(options.map((option) => option.label), ['0.7x', '1x']);
    });

    test('rounds fractional min zoom ratios to one decimal', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 0.6721,
      );

      expect(options.map((option) => option.label), ['0.7x', '1x']);
    });
  });

  group('initial selection', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    final logicalBack = _camera(name: '0', direction: CameraLensDirection.back);

    test('starts Android sessions at 1x, not the ultra-wide preset', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 0.6,
      );

      final selected = service.initialSelection(options, logicalBack);

      expect(selected.zoomRatio, 1.0);
      expect(selected, isNot(same(options.first)));
    });

    test('starts iOS sessions on the wide camera', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final options = service.resolveBackOptions(
        cameras: [backWide, backTelephoto, backUltraWide],
        activeBack: backWide,
      );

      final selected = service.initialSelection(options, backWide);

      expect(selected.camera, backWide);
      expect(selected.zoomRatio, 1.0);
    });

    test('selects the sole option after a collapse', () {
      final options = service.resolveBackOptions(
        cameras: [logicalBack],
        activeBack: logicalBack,
        minZoomRatio: 1.0,
      );

      expect(service.initialSelection(options, logicalBack), options.single);
    });
  });
}
