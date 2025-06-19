import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';

Future<ui.Image> convertXFileToImage(XFile xFile) async {
  final Uint8List bytes = await xFile.readAsBytes();
  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    allowUpscaling: false, // Prevent any upscaling
  );
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
