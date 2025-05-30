import 'dart:io';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class ImageFilesystem {
  static const String _lifeFrameSoftware = 'life_frame';

  /// Saves a ui.Image as JPEG with metadata to app directory and gallery
  /// Returns the path where the image was saved in the gallery
  static Future<String> saveImageWithMetadata(
    ui.Image image, {
    double? latitude,
    double? longitude,
  }) async {
    // Convert image to bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }

    final bytes = byteData.buffer.asUint8List();

    // Generate unique filename with current date and time
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(now);
    final timeString = DateFormat('HHmmss').format(now);
    final fileName = 'life_frame_${dateString}_$timeString.jpg';
    final filePath = '${directory.path}/$fileName';

    // Save image file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Apply metadata to the saved file
    await _applyMetadataToFile(filePath, now, latitude, longitude);

    // Save to gallery and return the gallery path
    await Gal.putImage(filePath, album: 'LifeFrame');

    return filePath;
  }

  /// Internal method to apply metadata to a saved file
  static Future<void> _applyMetadataToFile(
    String filePath,
    DateTime timestamp,
    double? latitude,
    double? longitude,
  ) async {
    final exif = await Exif.fromPath(filePath);

    try {
      // Format timestamp for EXIF (YYYY:MM:DD HH:mm:ss format)
      final dateFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
      final formattedTimestamp = dateFormat.format(timestamp);

      // Base metadata that's always applied
      final metadata = <String, Object>{
        'Software': _lifeFrameSoftware,
        'DateTimeOriginal': formattedTimestamp,
        'DateTime': formattedTimestamp,
        'DateTimeDigitized': formattedTimestamp,
      };

      // Add GPS metadata only if coordinates are provided
      if (latitude != null && longitude != null) {
        final gpsMetadata = _buildGpsMetadata(latitude, longitude, timestamp);
        metadata.addAll(gpsMetadata);
      }

      // Write all metadata at once
      await exif.writeAttributes(metadata);
    } finally {
      await exif.close();
    }
  }

  /// Builds GPS metadata map from coordinates and timestamp
  /// Note: native_exif expects GPS coordinates as double values in decimal degrees
  static Map<String, Object> _buildGpsMetadata(
    double latitude,
    double longitude,
    DateTime timestamp,
  ) {
    // Format GPS date and time
    final gpsDateFormat = DateFormat("yyyy:MM:dd");
    final gpsTimeFormat = DateFormat("HH:mm:ss");
    final gpsDate = gpsDateFormat.format(timestamp);
    final gpsTime = gpsTimeFormat.format(timestamp);

    // Prepare GPS coordinates with proper references
    final latRef = latitude >= 0 ? 'N' : 'S';
    final lngRef = longitude >= 0 ? 'E' : 'W';

    // Use absolute values for coordinates, as direction is handled by reference
    final absLatitude = latitude.abs();
    final absLongitude = longitude.abs();

    return {
      'GPSVersionID': '2.3.0.0',
      'GPSLatitude': absLatitude,
      'GPSLatitudeRef': latRef,
      'GPSLongitude': absLongitude,
      'GPSLongitudeRef': lngRef,
      'GPSTimeStamp': gpsTime,
      'GPSDateStamp': gpsDate,
      'GPSMapDatum': 'WGS-84',
    };
  }
}
