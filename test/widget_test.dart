// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_frame/models/daily_entry.dart';

void main() {
  group('DailyEntry Tests', () {
    test('should create a valid DailyEntry', () {
      final now = DateTime.now();
      final entry = DailyEntry(
        date: '2025-05-24',
        photoPath: '/path/to/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: now,
      );

      expect(entry.isValid(), isTrue);
      expect(entry.date, equals('2025-05-24'));
      expect(entry.photoPath, equals('/path/to/photo.jpg'));
      expect(entry.latitude, equals(37.7749));
      expect(entry.longitude, equals(-122.4194));
    });

    test('should serialize to and from JSON correctly', () {
      final now = DateTime.now();
      final entry = DailyEntry(
        date: '2025-05-24',
        photoPath: '/path/to/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: now,
      );

      final json = entry.toJson();
      final deserializedEntry = DailyEntry.fromJson(json);

      expect(deserializedEntry.date, equals(entry.date));
      expect(deserializedEntry.photoPath, equals(entry.photoPath));
      expect(deserializedEntry.latitude, equals(entry.latitude));
      expect(deserializedEntry.longitude, equals(entry.longitude));
      expect(deserializedEntry.timestamp, equals(entry.timestamp));
    });

    test('should format today\'s date correctly', () {
      final today = DailyEntry.getTodayKey();
      final expectedFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      expect(today, matches(expectedFormat));
    });

    test('should validate coordinates correctly', () {
      final validEntry = DailyEntry(
        date: '2025-05-24',
        photoPath: '/path/to/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
      );

      final invalidLatEntry = DailyEntry(
        date: '2025-05-24',
        photoPath: '/path/to/photo.jpg',
        latitude: 91.0, // Invalid latitude
        longitude: -122.4194,
        timestamp: DateTime.now(),
      );

      final invalidLngEntry = DailyEntry(
        date: '2025-05-24',
        photoPath: '/path/to/photo.jpg',
        latitude: 37.7749,
        longitude: 181.0, // Invalid longitude
        timestamp: DateTime.now(),
      );

      expect(validEntry.isValid(), isTrue);
      expect(invalidLatEntry.isValid(), isFalse);
      expect(invalidLngEntry.isValid(), isFalse);
    });
  });
}
