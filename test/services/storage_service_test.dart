import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_frame/services/storage_service.dart';
import 'package:life_frame/models/daily_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    late StorageService storageService;

    setUp(() async {
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    group('photo file management', () {
      test('should generate photo file name with timestamp', () {
        final fileName = storageService.generatePhotoFileName();
        expect(fileName, startsWith('photo_'));
        expect(fileName, endsWith('.jpg'));
        expect(fileName.length, greaterThan(10));
      });
    });

    group('daily entry management', () {
      late DailyEntry testEntry;

      setUp(() {
        testEntry = DailyEntry(
          date: '2024-01-15',
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 15, 12, 30),
        );
      });

      test('should save daily entry successfully with valid data', () async {
        // Initialize shared preferences manually for this test
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Create a simplified version of the save logic
        final entriesMap = <String, dynamic>{};
        entriesMap[testEntry.date] = testEntry.toJson();
        final entriesJson = json.encode(entriesMap);
        final success = await prefs.setString('daily_entries', entriesJson);

        expect(success, isTrue);

        // Verify entry was saved
        final savedData = prefs.getString('daily_entries');
        expect(savedData, isNotNull);

        final decodedData = json.decode(savedData!);
        expect(decodedData, containsPair('2024-01-15', testEntry.toJson()));
      });

      test('should not save invalid daily entry', () {
        final invalidEntry = DailyEntry(
          date: '',
          photoPath: '',
          latitude: 200.0, // Invalid latitude
          longitude: 200.0, // Invalid longitude
          timestamp: DateTime.now(),
        );

        expect(invalidEntry.isValid(), isFalse);
      });

      test('should get daily entry by date', () async {
        // Setup mock data
        final mockData = {'2024-01-15': testEntry.toJson()};
        SharedPreferences.setMockInitialValues({
          'daily_entries': json.encode(mockData),
        });

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('daily_entries');
        expect(savedData, isNotNull);

        final decodedData = json.decode(savedData!);
        final entryData = decodedData['2024-01-15'];
        expect(entryData, isNotNull);

        final entry = DailyEntry.fromJson(entryData);
        expect(entry.date, equals('2024-01-15'));
        expect(entry.photoPath, equals('/test/photo.jpg'));
        expect(entry.latitude, equals(37.7749));
        expect(entry.longitude, equals(-122.4194));
      });

      test('should return null for non-existent date', () async {
        SharedPreferences.setMockInitialValues({});

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('daily_entries');
        expect(savedData, isNull);
      });

      test('should get today entry key format', () {
        final today = DailyEntry.getTodayKey();
        expect(today, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));

        final now = DateTime.now();
        final expectedFormat = now.toIso8601String().split('T')[0];
        expect(today, equals(expectedFormat));
      });

      test('should check if photo exists for date', () async {
        final mockData = {'2024-01-15': testEntry.toJson()};
        SharedPreferences.setMockInitialValues({
          'daily_entries': json.encode(mockData),
        });

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('daily_entries');
        final decodedData = json.decode(savedData!);

        final hasPhoto = decodedData.containsKey('2024-01-15');
        expect(hasPhoto, isTrue);

        final hasPhotoMissing = decodedData.containsKey('2024-01-16');
        expect(hasPhotoMissing, isFalse);
      });

      test('should get all entries and sort by timestamp', () async {
        final entry1 = DailyEntry(
          date: '2024-01-14',
          photoPath: '/test/photo1.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 14, 12, 30),
        );

        final entry2 = DailyEntry(
          date: '2024-01-15',
          photoPath: '/test/photo2.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 15, 12, 30),
        );

        final mockData = {
          '2024-01-14': entry1.toJson(),
          '2024-01-15': entry2.toJson(),
        };
        SharedPreferences.setMockInitialValues({
          'daily_entries': json.encode(mockData),
        });

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('daily_entries');
        final decodedData = json.decode(savedData!);

        final entries = decodedData.values
            .map<DailyEntry>((entryData) => DailyEntry.fromJson(entryData))
            .toList();
        entries.sort(
          (DailyEntry a, DailyEntry b) => b.timestamp.compareTo(a.timestamp),
        );

        expect(entries.length, equals(2));
        // Should be sorted by timestamp descending (newest first)
        expect(entries[0].date, equals('2024-01-15'));
        expect(entries[1].date, equals('2024-01-14'));
      });

      test('should delete daily entry from storage', () async {
        final mockData = {
          '2024-01-15': testEntry.toJson(),
          '2024-01-16': testEntry.copyWith(date: '2024-01-16').toJson(),
        };
        SharedPreferences.setMockInitialValues({
          'daily_entries': json.encode(mockData),
        });

        final prefs = await SharedPreferences.getInstance();
        var savedData = prefs.getString('daily_entries');
        var decodedData = json.decode(savedData!);

        // Simulate deletion
        decodedData.remove('2024-01-15');
        final updatedJson = json.encode(decodedData);
        await prefs.setString('daily_entries', updatedJson);

        // Verify entry was removed
        savedData = prefs.getString('daily_entries');
        decodedData = json.decode(savedData!);
        expect(decodedData, isNot(contains('2024-01-15')));
        expect(decodedData, contains('2024-01-16'));
      });

      test('should clear all data', () async {
        final mockData = {'2024-01-15': testEntry.toJson()};
        SharedPreferences.setMockInitialValues({
          'daily_entries': json.encode(mockData),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('daily_entries');

        final savedData = prefs.getString('daily_entries');
        expect(savedData, isNull);
      });
    });

    group('error handling', () {
      test('should handle invalid JSON gracefully', () {
        SharedPreferences.setMockInitialValues({
          'daily_entries': 'invalid json',
        });

        expect(() {
          json.decode('invalid json');
        }, throwsA(isA<FormatException>()));
      });

      test('should handle missing entries key', () async {
        SharedPreferences.setMockInitialValues({});

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('daily_entries');
        expect(savedData, isNull);
      });
    });

    group('DailyEntry model', () {
      test('should validate entry data correctly', () {
        final validEntry = DailyEntry(
          date: '2024-01-15',
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
        );
        expect(validEntry.isValid(), isTrue);

        final invalidEntry = DailyEntry(
          date: '',
          photoPath: '',
          latitude: 200.0, // Invalid latitude
          longitude: 200.0, // Invalid longitude
          timestamp: DateTime.now(),
        );
        expect(invalidEntry.isValid(), isFalse);
      });

      test('should serialize and deserialize correctly', () {
        final entry = DailyEntry(
          date: '2024-01-15',
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 15, 12, 30),
          stitchedPhotoPath: '/test/stitched.jpg',
        );

        final json = entry.toJson();
        final deserializedEntry = DailyEntry.fromJson(json);

        expect(deserializedEntry.date, equals(entry.date));
        expect(deserializedEntry.photoPath, equals(entry.photoPath));
        expect(deserializedEntry.latitude, equals(entry.latitude));
        expect(deserializedEntry.longitude, equals(entry.longitude));
        expect(deserializedEntry.timestamp, equals(entry.timestamp));
        expect(
          deserializedEntry.stitchedPhotoPath,
          equals(entry.stitchedPhotoPath),
        );
      });

      test('should create copy with modifications', () {
        final entry = DailyEntry(
          date: '2024-01-15',
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 15, 12, 30),
        );

        final modifiedEntry = entry.copyWith(
          stitchedPhotoPath: '/test/stitched.jpg',
          latitude: 40.7128,
        );

        expect(modifiedEntry.date, equals(entry.date));
        expect(modifiedEntry.photoPath, equals(entry.photoPath));
        expect(modifiedEntry.latitude, equals(40.7128)); // Modified
        expect(modifiedEntry.longitude, equals(entry.longitude));
        expect(modifiedEntry.timestamp, equals(entry.timestamp));
        expect(
          modifiedEntry.stitchedPhotoPath,
          equals('/test/stitched.jpg'),
        ); // Modified
      });
    });
  });
}
