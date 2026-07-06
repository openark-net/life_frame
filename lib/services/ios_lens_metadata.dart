import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

class IosLensMetadata {
  static const MethodChannel channel = MethodChannel(
    'life_frame/lens_metadata',
  );

  final Talker _talker = Get.find<Talker>();

  Future<Map<String, double>> backLensZoomFactors() async {
    try {
      final raw = await channel.invokeMethod<Map<dynamic, dynamic>>(
        'getBackLensZoomFactors',
      );
      if (raw == null) return const {};

      final factors = <String, double>{};
      raw.forEach((key, value) {
        if (key is String && value is num) {
          factors[key] = value.toDouble();
        }
      });
      return factors;
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to load iOS lens zoom factors');
      return const {};
    }
  }
}
