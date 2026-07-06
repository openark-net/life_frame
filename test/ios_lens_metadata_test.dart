import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:life_frame/services/ios_lens_metadata.dart';
import 'package:talker/talker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUpAll(() {
    Get.put(Talker(settings: TalkerSettings(useConsoleLogs: false)));
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(IosLensMetadata.channel, null);
  });

  test('returns zoom factors keyed by camera name', () async {
    messenger.setMockMethodCallHandler(IosLensMetadata.channel, (call) async {
      expect(call.method, 'getBackLensZoomFactors');
      return <String, Object>{'video:5': 0.5, 'video:0': 1.0, 'video:2': 3};
    });

    final factors = await IosLensMetadata().backLensZoomFactors();

    expect(factors, {'video:5': 0.5, 'video:0': 1.0, 'video:2': 3.0});
  });

  test('returns empty map when the channel throws', () async {
    messenger.setMockMethodCallHandler(IosLensMetadata.channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });

    final factors = await IosLensMetadata().backLensZoomFactors();

    expect(factors, isEmpty);
  });

  test('returns empty map when the channel is not implemented', () async {
    final factors = await IosLensMetadata().backLensZoomFactors();

    expect(factors, isEmpty);
  });

  test('skips entries with unexpected types', () async {
    messenger.setMockMethodCallHandler(IosLensMetadata.channel, (call) async {
      return <Object?, Object?>{'video:0': 1.0, 42: 2.0, 'video:2': 'junk'};
    });

    final factors = await IosLensMetadata().backLensZoomFactors();

    expect(factors, {'video:0': 1.0});
  });
}
