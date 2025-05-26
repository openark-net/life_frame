import 'dart:io';
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import '../models/daily_entry.dart';

class ImageMetadata {
  static const String _lifeFrameSoftware = 'life_frame';

  /// Applies EXIF metadata to an image file based on DailyEntry data
  static Future<void> applyMetadata(DailyEntry entry) async {
    final exif = await Exif.fromPath(entry.photoPath);

    try {
      // Format timestamp for EXIF (YYYY:MM:DD HH:mm:ss format)
      final dateFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
      final formattedTimestamp = dateFormat.format(entry.timestamp);

      // Prepare GPS coordinates with proper references
      final latRef = entry.latitude >= 0 ? 'N' : 'S';
      final lngRef = entry.longitude >= 0 ? 'E' : 'W';

      // Write all metadata at once
      await exif.writeAttributes({
        'Software': _lifeFrameSoftware,
        'DateTimeOriginal': formattedTimestamp,
        'DateTime': formattedTimestamp,
        'GPSLatitude': entry.latitude.abs(),
        'GPSLatitudeRef': latRef,
        'GPSLongitude': entry.longitude.abs(),
        'GPSLongitudeRef': lngRef,
      });
    } finally {
      await exif.close();
    }
  }

  /// Checks if an image was created by life_frame and returns DailyEntry if valid
  static Future<DailyEntry?> loadDailyEntry(String path) async {
    if (!await File(path).exists()) {
      return null;
    }

    final exif = await Exif.fromPath(path);

    try {
      // Check if software tag matches our app
      final software = await exif.getAttribute<String>('Software');
      if (software != _lifeFrameSoftware) {
        return null;
      }

      // Extract required data
      final timestamp = await exif.getOriginalDate();
      final latLong = await exif.getLatLong();

      if (timestamp == null || latLong == null) {
        return null;
      }

      // Format date as YYYY-MM-DD
      final dateFormat = DateFormat("yyyy-MM-dd");
      final dateString = dateFormat.format(timestamp);

      return DailyEntry(
        date: dateString,
        photoPath: path,
        latitude: latLong.latitude,
        longitude: latLong.longitude,
        timestamp: timestamp,
      );
    } catch (e) {
      return null;
    } finally {
      await exif.close();
    }
  }
}
