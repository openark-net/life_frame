import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

import 'package:life_frame/models/daily_entry.dart';

import '../utils/location_formatter.dart';

class ImageFilesystem {
  static const String _lifeFrameSoftware = 'life_frame';
  static const int _jpegQuality = 95; // High quality JPEG (0-100)

  /// Saves a ui.Image as high-quality JPEG with metadata to app directory and gallery
  /// Returns the path where the image was saved in the gallery
  static Future<String> saveImageWithMetadata(
    ui.Image image, {
    double? latitude,
    double? longitude,
  }) async {
    final bytes = await _convertToHighQualityJpeg(image);

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

    await Gal.putImage(filePath, album: 'LifeFrame');

    return filePath;
  }

  /// Converts ui.Image to high-quality JPEG bytes
  static Future<Uint8List> _convertToHighQualityJpeg(ui.Image image) async {
    // First convert to PNG to get lossless byte data
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }

    // Decode PNG bytes to image package format
    final pngBytes = byteData.buffer.asUint8List();
    final decodedImage = img.decodeImage(pngBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // Encode as high-quality JPEG
    final jpegBytes = img.encodeJpg(decodedImage, quality: _jpegQuality);
    return Uint8List.fromList(jpegBytes);
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

  /// Loads a DailyEntry from an existing image file
  /// Extracts metadata from EXIF data and returns a DailyEntry object
  static Future<DailyEntry?> loadDailyEntry(File file) async {
    try {
      final exif = await Exif.fromPath(file.path);

      try {
        final attributes = await exif.getAttributes();

        // Extract timestamp from EXIF data
        final dateTimeOriginal = attributes?['DateTimeOriginal'] as String?;
        final dateTime = attributes?['DateTime'] as String?;
        final dateTimeStr = dateTimeOriginal ?? dateTime;

        if (dateTimeStr == null) {
          throw Exception('No timestamp found in EXIF data');
        }

        // Parse EXIF timestamp (format: "YYYY:MM:DD HH:mm:ss")
        final timestamp = DateFormat("yyyy:MM:dd HH:mm:ss").parse(dateTimeStr);

        // Extract GPS coordinates
        final lat = attributes?['GPSLatitude'] as double?;
        final lng = attributes?['GPSLongitude'] as double?;

        String locationName = 'Unknown Location';
        if (lat != null && lng != null) {
          locationName =
              await getFormattedLocationLatLng(lat, lng) ?? "Unknown Location";
        }

        return DailyEntry(
          photoPath: file.path,
          locationName: locationName,
          latitude: lat ?? 0.0,
          longitude: lng ?? 0.0,
          timestamp: timestamp,
        );
      } finally {
        await exif.close();
      }
    } catch (e) {
      // If we can't read EXIF data, use file modification time as fallback
      final stat = await file.stat();
      return DailyEntry(
        photoPath: file.path,
        locationName: 'Unknown Location',
        latitude: 0.0,
        longitude: 0.0,
        timestamp: stat.modified,
      );
    }
  }
}
