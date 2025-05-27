import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import '../utils/location_formatter.dart';

class PhotoStitchingService {
  static const double frontPhotoScaleFactor = 0.25;
  static const double padding = 16.0;
  static const double textPadding = 8.0;
  static const double frontPhotoRadius = 12.0;

  Future<String?> stitchPhotos({
    required String backPhotoPath,
    required String frontPhotoPath,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final backImage = await _loadImageFromFile(backPhotoPath);
      final frontImage = await _loadImageFromFile(frontPhotoPath);

      if (backImage == null || frontImage == null) {
        throw Exception('Failed to load one or both images');
      }
      String locationText = await getFormattedLocation(latitude, longitude);
      final dateText = _formatCurrentDate();

      final stitchedImage = await _createStitchedImage(
        backImage: backImage,
        frontImage: frontImage,
        dateText: dateText,
        locationText: locationText,
      );

      final savedPath = await _saveImageToFile(stitchedImage);

      backImage.dispose();
      frontImage.dispose();
      stitchedImage.dispose();

      await _deleteOriginalPhotos(backPhotoPath, frontPhotoPath);

      return savedPath;
    } catch (e) {
      print('Error stitching photos: $e');
      return null;
    }
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

  Future<ui.Image?> _loadImageFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        allowUpscaling: false,
        targetWidth: null,
        targetHeight: null,
      );
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('Error loading image from $filePath: $e');
      return null;
    }
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
      fontSize: 80.0,
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

  Future<String> _saveImageToFile(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }

    final bytes = byteData.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final filePath = '${directory.path}/life_frame_$dateString.png';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Gal.putImage('$filePath', album: 'LifeFrame');

    return filePath;
  }

  Future<void> _deleteOriginalPhotos(
    String backPhotoPath,
    String frontPhotoPath,
  ) async {
    try {
      final backFile = File(backPhotoPath);
      final frontFile = File(frontPhotoPath);

      if (await backFile.exists()) {
        await backFile.delete();
        print('Deleted original back photo: $backPhotoPath');
      }

      if (await frontFile.exists()) {
        await frontFile.delete();
        print('Deleted original front photo: $frontPhotoPath');
      }
    } catch (e) {
      print('Error deleting original photos: $e');
    }
  }


}
