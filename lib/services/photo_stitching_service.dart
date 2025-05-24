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
    String? dateText,
    String? locationText,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final backImage = await _loadImageFromFile(backPhotoPath);
      final frontImage = await _loadImageFromFile(frontPhotoPath);
      
      if (backImage == null || frontImage == null) {
        throw Exception('Failed to load one or both images');
      }

      // Get formatted location from coordinates if provided
      String? finalLocationText = locationText;
      if (latitude != null && longitude != null) {
        finalLocationText = await getFormattedLocation(latitude, longitude);
      }

      final stitchedImage = await _createStitchedImage(
        backImage: backImage,
        frontImage: frontImage,
        dateText: dateText,
        locationText: finalLocationText,
      );

      final savedPath = await _saveImageToFile(stitchedImage);
      
      backImage.dispose();
      frontImage.dispose();
      stitchedImage.dispose();
      
      return savedPath;
    } catch (e) {
      print('Error stitching photos: $e');
      return null;
    }
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
    String? dateText,
    String? locationText,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final backImageWidth = backImage.width.toDouble();
    final backImageHeight = backImage.height.toDouble();
    
    canvas.drawImage(backImage, Offset.zero, Paint());
    
    final frontImageSize = _calculateFrontImageSize(frontImage, backImageWidth);
    _drawFrontImage(canvas, frontImage, frontImageSize);
    
    if (dateText != null || locationText != null) {
      _drawTextOverlay(
        canvas,
        backImageWidth,
        backImageHeight,
        frontImageSize,
        dateText: dateText,
        locationText: locationText,
      );
    }
    
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
    
    final rrect = RRect.fromRectAndRadius(dstRect, const Radius.circular(frontPhotoRadius));
    
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
    String? dateText,
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

    if (dateText != null && dateText.isNotEmpty) {
      final datePainter = TextPainter(
        text: TextSpan(text: dateText, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      datePainter.layout();
      
      datePainter.paint(
        canvas,
        Offset(padding, currentY - datePainter.height),
      );
    }
  }

  Future<String> _saveImageToFile(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }
    
    final bytes = byteData.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/stitched_photo_$timestamp.png';
    
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await Gal.putImage('$filePath', album: 'LifeFrame');
    
    return filePath;
  }


  Future<bool> deleteStitchedPhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting stitched photo: $e');
      return false;
    }
  }

  Future<List<String>> getAllStitchedPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .where((file) => file.path.contains('stitched_photo_'))
          .map((file) => file.path)
          .toList();
      
      files.sort((a, b) => b.compareTo(a));
      return files;
    } catch (e) {
      print('Error getting stitched photos: $e');
      return [];
    }
  }
}