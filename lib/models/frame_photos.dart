import 'dart:ui' as ui;

class FramePhotos {
  final ui.Image front;
  final ui.Image back;

  const FramePhotos({required this.front, required this.back});

  void dispose() {
    front.dispose();
    back.dispose();
  }
}
