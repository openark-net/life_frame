import 'dart:io';
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import '../models/daily_entry.dart';

class ImageMetadata {
  static const String _lifeFrameSoftware = 'life_frame';

  /// Converts decimal degrees to degrees, minutes, seconds format for EXIF
  static List<double> _decimalToDMS(double decimal) {
    final absDecimal = decimal.abs();
    final degrees = absDecimal.floor().toDouble();
    final minutes = ((absDecimal - degrees) * 60).floor().toDouble();
    final seconds = ((absDecimal - degrees - minutes / 60) * 3600);

    return [degrees, minutes, seconds];
  }

  /// Applies EXIF metadata to an image file based on DailyEntry data
  static Future<void> applyMetadata(DailyEntry entry) async {
    final exif = await Exif.fromPath(entry.photoPath);

    try {
      // Format timestamp for EXIF (YYYY:MM:DD HH:mm:ss format)
      final dateFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
      final formattedTimestamp = dateFormat.format(entry.timestamp);

      // Format GPS date and time
      final gpsDateFormat = DateFormat("yyyy:MM:dd");
      final gpsTimeFormat = DateFormat("HH:mm:ss");
      final gpsDate = gpsDateFormat.format(entry.timestamp);
      final gpsTime = gpsTimeFormat.format(entry.timestamp);

      // Prepare GPS coordinates with proper references
      final latRef = entry.latitude >= 0 ? 'N' : 'S';
      final lngRef = entry.longitude >= 0 ? 'E' : 'W';

      // Convert coordinates to DMS format
      final latDMS = _decimalToDMS(entry.latitude);
      final lngDMS = _decimalToDMS(entry.longitude);

      // Write all metadata at once with proper GPS formatting
      await exif.writeAttributes({
        'Software': _lifeFrameSoftware,
        'DateTimeOriginal': formattedTimestamp,
        'DateTime': formattedTimestamp,
        'DateTimeDigitized': formattedTimestamp,

        // GPS Version - required by many parsers
        'GPSVersionID': '2.3.0.0',

        // GPS coordinates in DMS format
        'GPSLatitude': latDMS,
        'GPSLatitudeRef': latRef,
        'GPSLongitude': lngDMS,
        'GPSLongitudeRef': lngRef,

        // GPS timestamp
        'GPSTimeStamp': gpsTime,
        'GPSDateStamp': gpsDate,

        // GPS map datum (standard)
        'GPSMapDatum': 'WGS-84',
      });
    } finally {
      await exif.close();
    }
  }

  /// Alternative method using decimal degrees if DMS doesn't work
  static Future<void> applyMetadataDecimal(DailyEntry entry) async {
    final exif = await Exif.fromPath(entry.photoPath);

    try {
      final dateFormat = DateFormat("yyyy:MM:dd HH:mm:ss");
      final formattedTimestamp = dateFormat.format(entry.timestamp);

      final latRef = entry.latitude >= 0 ? 'N' : 'S';
      final lngRef = entry.longitude >= 0 ? 'E' : 'W';

      // Some parsers prefer this format
      await exif.writeAttributes({
        'Software': _lifeFrameSoftware,
        'DateTimeOriginal': formattedTimestamp,
        'DateTime': formattedTimestamp,
        'DateTimeDigitized': formattedTimestamp,

        // Essential GPS tags
        'GPSVersionID': '2.3.0.0',
        'GPSLatitude': entry.latitude.abs(),
        'GPSLatitudeRef': latRef,
        'GPSLongitude': entry.longitude.abs(),
        'GPSLongitudeRef': lngRef,
        'GPSMapDatum': 'WGS-84',

        // Additional GPS tags that some apps expect
        'GPSAltitudeRef': '0', // Above sea level
        'GPSAltitude': 0.0, // Default altitude
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
        timestamp: timestamp,
        latitude: latLong.latitude,
        longitude: latLong.longitude,
      );
    } catch (e) {
      return null;
    } finally {
      await exif.close();
    }
  }
}
