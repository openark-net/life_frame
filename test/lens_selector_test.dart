import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_frame/models/camera_lens_option.dart';
import 'package:life_frame/widgets/capture/lens_selector.dart';

void main() {
  const camera = CameraDescription(
    name: '0',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  );

  final options = [
    const CameraLensOption(label: '0.6x', camera: camera, zoomRatio: 0.6),
    const CameraLensOption(label: '1x', camera: camera),
  ];

  Future<void> pumpSelector(
    WidgetTester tester, {
    required bool enabled,
    required ValueChanged<CameraLensOption> onSelect,
  }) {
    return tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: LensSelector(
            options: options,
            selected: options.last,
            enabled: enabled,
            onSelect: onSelect,
          ),
        ),
      ),
    );
  }

  testWidgets('renders one button per lens option', (tester) async {
    await pumpSelector(tester, enabled: true, onSelect: (_) {});

    expect(find.text('0.6x'), findsOneWidget);
    expect(find.text('1x'), findsOneWidget);
  });

  testWidgets('tapping an option invokes the callback with that option', (
    tester,
  ) async {
    CameraLensOption? tapped;
    await pumpSelector(
      tester,
      enabled: true,
      onSelect: (option) {
        tapped = option;
      },
    );

    await tester.tap(find.text('0.6x'));

    expect(tapped, same(options.first));
  });

  testWidgets('ignores taps while disabled', (tester) async {
    CameraLensOption? tapped;
    await pumpSelector(
      tester,
      enabled: false,
      onSelect: (option) {
        tapped = option;
      },
    );

    await tester.tap(find.text('0.6x'), warnIfMissed: false);

    expect(tapped, isNull);
  });
}
