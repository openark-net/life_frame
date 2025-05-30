import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import '../models/frame_photos.dart';
import '../utils/location_formatter.dart';

class PhotoStitchingService {
  static const double frontPhotoScaleFactor = 0.35;
  static const double padding = 16.0;
  static const double textPadding = 8.0;
  static const double frontPhotoRadius = 50.0; // Increased from 12.0
  static const double fontSize = 80.0;

  Future<ui.Image?> stitchPhotos({
    required FramePhotos framePhotos,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final locationText = await _getLocationText(latitude, longitude);
      final dateText = _formatCurrentDate();

      final stitchedImage = await _createStitchedImage(
        backImage: framePhotos.back,
        frontImage: framePhotos.front,
        dateText: dateText,
        locationText: locationText,
      );

      return stitchedImage;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getLocationText(double? latitude, double? longitude) async {
    return (latitude == null || longitude == null)
        ? ""
        : await getFormattedLocation(latitude, longitude);
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<ui.Image> _createStitchedImage({
    required ui.Image backImage,
    required ui.Image frontImage,
    required String dateText,
    String? locationText,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final backImageWidth = backImage.width.toDouble();
    final backImageHeight = backImage.height.toDouble();

    canvas.drawImage(backImage, Offset.zero, Paint());

    final frontImageSize = _calculateFrontImageSize(frontImage, backImageWidth);
    _drawFrontImage(canvas, frontImage, frontImageSize);

    _drawTextOverlay(
      canvas,
      backImageWidth,
      backImageHeight,
      frontImageSize,
      dateText: dateText,
      locationText: locationText,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
      backImageWidth.toInt(),
      backImageHeight.toInt(),
    );
  }

  Size _calculateFrontImageSize(ui.Image frontImage, double maxWidth) {
    final frontWidth = frontImage.width.toDouble();
    final frontHeight = frontImage.height.toDouble();
    final aspectRatio = frontWidth / frontHeight;

    final targetWidth = maxWidth * frontPhotoScaleFactor;
    final targetHeight = targetWidth / aspectRatio;

    return Size(targetWidth, targetHeight);
  }

  void _drawFrontImage(Canvas canvas, ui.Image frontImage, Size targetSize) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    final srcRect = Rect.fromLTWH(
      0,
      0,
      frontImage.width.toDouble(),
      frontImage.height.toDouble(),
    );

    final dstRect = Rect.fromLTWH(
      padding,
      padding,
      targetSize.width,
      targetSize.height,
    );

    final rrect = RRect.fromRectAndRadius(
      dstRect,
      const Radius.circular(frontPhotoRadius),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawImageRect(frontImage, srcRect, dstRect, paint);
    canvas.restore();

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawTextOverlay(
    Canvas canvas,
    double canvasWidth,
    double canvasHeight,
    Size frontImageSize, {
    required String dateText,
    String? locationText,
  }) {
    const textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      fontFamily: 'PeaceSans',
      shadows: [
        Shadow(
          offset: Offset(1.0, 1.0),
          blurRadius: 4.0,
          color: Color(0x80000000),
        ),
        Shadow(
          offset: Offset(-1.0, -1.0),
          blurRadius: 4.0,
          color: Color(0x80000000),
        ),
      ],
    );

    double currentY = canvasHeight - padding - textPadding;

    if (locationText != null && locationText.isNotEmpty) {
      final locationPainter = TextPainter(
        text: TextSpan(text: locationText, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      locationPainter.layout();

      locationPainter.paint(
        canvas,
        Offset(padding, currentY - locationPainter.height),
      );

      currentY -= locationPainter.height + textPadding;
    }

    final datePainter = TextPainter(
      text: TextSpan(text: dateText, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    datePainter.layout();

    datePainter.paint(canvas, Offset(padding, currentY - datePainter.height));
  }
}
