import 'package:flutter_test/flutter_test.dart';
import 'package:life_frame/models/daily_entry.dart';

void main() {
  group('DailyEntry', () {
    final entry = DailyEntry(
      photoPath: '/path/to/photo.jpg',
      locationName: 'San Francisco',
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.fromMillisecondsSinceEpoch(1748000000000),
    );

    test('creates an entry with the provided fields', () {
      expect(entry.photoPath, '/path/to/photo.jpg');
      expect(entry.locationName, 'San Francisco');
      expect(entry.latitude, 37.7749);
      expect(entry.longitude, -122.4194);
    });

    test('round-trips through toMap and fromMap', () {
      final restored = DailyEntry.fromMap(entry.toMap());

      expect(restored.photoPath, entry.photoPath);
      expect(restored.locationName, entry.locationName);
      expect(restored.latitude, entry.latitude);
      expect(restored.longitude, entry.longitude);
      expect(restored.timestamp, entry.timestamp);
    });
  });
}
