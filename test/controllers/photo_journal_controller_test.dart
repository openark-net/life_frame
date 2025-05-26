import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:life_frame/controllers/photo_journal_controller.dart';
import 'package:life_frame/services/storage_service.dart';
import 'package:life_frame/models/daily_entry.dart';

import 'photo_journal_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<StorageService>(), MockSpec<Directory>(), MockSpec<File>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhotoJournalController', () {
    late PhotoJournalController controller;
    late MockStorageService mockStorageService;

    setUpAll(() {
      // Initialize GetX system once
      Get.testMode = true;
    });

    setUp(() {
      // Reset GetX system
      Get.reset();

      mockStorageService = MockStorageService();

      // Stub the GetX lifecycle methods
      when(mockStorageService.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
      when(mockStorageService.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
      when(mockStorageService.initialized).thenReturn(true);
      when(mockStorageService.isClosed).thenReturn(false);

      // Stub the onInit method
      when(mockStorageService.onInit()).thenAnswer((_) async {});

      // Stub the default methods that will be called during initialization
      when(mockStorageService.hasTodayPhoto()).thenAnswer((_) async => false);
      when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

      // Put the mock service first
      Get.put<StorageService>(mockStorageService);

      // Create controller using Get.put to ensure onInit is called
      controller = Get.put(PhotoJournalController());
    });

    tearDown(() {
      Get.reset();
    });

    group('initialization', () {
      test('should initialize with correct default values', () {
        expect(controller.hasTodayPhoto, isFalse);
        expect(controller.isLoading, isFalse);
        expect(controller.todayEntry, isNull);
        expect(controller.allEntries, isEmpty);
        expect(controller.totalPhotosCount, equals(0));
        expect(controller.currentDate, isNotEmpty);
        expect(controller.todayBackPhoto, isEmpty);
        expect(controller.todayFrontPhoto, isEmpty);

        // Verify initialization methods were called
        verify(mockStorageService.hasTodayPhoto()).called(1);
        verify(mockStorageService.getAllEntries()).called(1);
      });

      test('should set current date on init', () {
        expect(controller.currentDate, equals(DailyEntry.getTodayKey()));
      });
    });

    group('save photo entry', () {
      test('should save photo entry successfully', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        final result = await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(result, isTrue);
        expect(controller.hasTodayPhoto, isTrue);
        expect(controller.todayEntry, isNotNull);
        expect(controller.todayEntry!.photoPath, equals('/test/photo.jpg'));
        expect(controller.todayEntry!.latitude, equals(37.7749));
        expect(controller.todayEntry!.longitude, equals(-122.4194));

        verify(mockStorageService.saveDailyEntry(any)).called(1);
        verify(mockStorageService.getAllEntries()).called(greaterThan(1)); // Called during init and save
      });

      test('should handle save photo entry failure', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => false);

        final result = await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(result, isFalse);
        expect(controller.hasTodayPhoto, isFalse);
        verify(mockStorageService.saveDailyEntry(any)).called(1);
      });

      test('should include stitched photo path when provided', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        final result = await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
          stitchedPhotoPath: '/test/stitched.jpg',
        );

        expect(result, isTrue);
        expect(controller.todayEntry!.stitchedPhotoPath, equals('/test/stitched.jpg'));
      });
    });

    group('delete entries', () {
      test('should delete entry successfully', () async {
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        final result = await controller.deleteEntry('2024-01-15');

        expect(result, isTrue);
        verify(mockStorageService.deleteDailyEntry('2024-01-15')).called(1);
        verify(mockStorageService.getAllEntries()).called(greaterThan(1)); // Called during init and delete
      });

      test('should handle delete entry failure', () async {
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => false);

        final result = await controller.deleteEntry('2024-01-15');

        expect(result, isFalse);
        verify(mockStorageService.deleteDailyEntry('2024-01-15')).called(1);
      });

      test('should delete today entry', () async {
        when(mockStorageService.deleteDailyEntry(DailyEntry.getTodayKey()))
            .thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        final result = await controller.deleteTodayEntry();

        expect(result, isTrue);
        verify(mockStorageService.deleteDailyEntry(DailyEntry.getTodayKey())).called(1);
      });
    });

    group('streak calculation', () {
      test('should return 0 for empty entries', () {
        expect(controller.getStreak(), equals(0));
      });

      test('should return 3 when no photo today but last 3 days have photos', () async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final dayBefore = today.subtract(const Duration(days: 2));
        final threeDaysAgo = today.subtract(const Duration(days: 3));

        final entries = [
          DailyEntry(
            date: DailyEntry.formatDate(yesterday),
            photoPath: '/test/photo1.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: yesterday,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(dayBefore),
            photoPath: '/test/photo2.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: dayBefore,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(threeDaysAgo),
            photoPath: '/test/photo3.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: threeDaysAgo,
          ),
        ];

        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);

        // Trigger loading of entries
        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        // Then delete today's entry to simulate no photo today
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        await controller.deleteTodayEntry();

        expect(controller.getStreak(), equals(3));
      });

      test('should return 3 when photo today and last 2 days have photos', () async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final dayBefore = today.subtract(const Duration(days: 2));

        final entries = [
          DailyEntry(
            date: DailyEntry.formatDate(today),
            photoPath: '/test/photo1.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: today,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(yesterday),
            photoPath: '/test/photo2.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: yesterday,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(dayBefore),
            photoPath: '/test/photo3.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: dayBefore,
          ),
        ];

        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(controller.getStreak(), equals(3));
      });

      test('should return 0 when no photo yesterday', () async {
        final today = DateTime.now();
        final dayBefore = today.subtract(const Duration(days: 2));

        final entries = [
          DailyEntry(
            date: DailyEntry.formatDate(dayBefore),
            photoPath: '/test/photo1.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: dayBefore,
          ),
        ];

        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        // Delete today's entry to simulate checking streak before taking today's photo
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        await controller.deleteTodayEntry();

        expect(controller.getStreak(), equals(0));
      });

      test('should return 1 when no photo yesterday but photo today', () async {
        final today = DateTime.now();
        final dayBefore = today.subtract(const Duration(days: 2));

        final entries = [
          DailyEntry(
            date: DailyEntry.formatDate(today),
            photoPath: '/test/photo1.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: today,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(dayBefore),
            photoPath: '/test/photo2.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: dayBefore,
          ),
        ];

        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(controller.getStreak(), equals(1));
      });

      test('should handle streak with gap correctly', () async {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final threeDaysAgo = today.subtract(const Duration(days: 3));
        final fourDaysAgo = today.subtract(const Duration(days: 4));

        final entries = [
          DailyEntry(
            date: DailyEntry.formatDate(yesterday),
            photoPath: '/test/photo1.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: yesterday,
          ),
          // Gap on day 2
          DailyEntry(
            date: DailyEntry.formatDate(threeDaysAgo),
            photoPath: '/test/photo2.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: threeDaysAgo,
          ),
          DailyEntry(
            date: DailyEntry.formatDate(fourDaysAgo),
            photoPath: '/test/photo3.jpg',
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: fourDaysAgo,
          ),
        ];

        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        // Delete today's entry
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => entries);
        await controller.deleteTodayEntry();

        // Should only count yesterday since there's a gap
        expect(controller.getStreak(), equals(1));
      });
    });

    group('clear all data', () {
      test('should clear all data and reset state', () async {
        when(mockStorageService.clearAllData()).thenAnswer((_) async {});

        await controller.clearAllData();

        expect(controller.hasTodayPhoto, isFalse);
        expect(controller.todayEntry, isNull);
        expect(controller.allEntries, isEmpty);
        expect(controller.totalPhotosCount, equals(0));
        verify(mockStorageService.clearAllData()).called(1);
      });
    });

    group('update stitched photo', () {
      test('should update today entry with stitched photo', () async {
        // First create a today entry
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final result = await controller.updateTodayEntryWithStitchedPhoto('/test/stitched.jpg');

        expect(result, isTrue);
        expect(controller.todayEntry!.stitchedPhotoPath, equals('/test/stitched.jpg'));
        verify(mockStorageService.saveDailyEntry(any)).called(2); // Once for original, once for update
      });

      test('should return false when no today entry exists', () async {
        final result = await controller.updateTodayEntryWithStitchedPhoto('/test/stitched.jpg');

        expect(result, isFalse);
        verifyNever(mockStorageService.saveDailyEntry(any));
      });
    });

    group('loading state management', () {
      test('should handle loading state during save operations', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async {
          // Simulate some delay
          await Future.delayed(const Duration(milliseconds: 10));
          return true;
        });
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        expect(controller.isLoading, isFalse);

        final future = controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        await future;

        // Loading should be false after completion
        expect(controller.isLoading, isFalse);
      });
    });

    group('error handling', () {
      test('should handle errors in savePhotoEntry', () async {
        when(mockStorageService.saveDailyEntry(any)).thenThrow(Exception('Test error'));

        final result = await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(result, isFalse);
        expect(controller.isLoading, isFalse);
      });

      test('should handle errors in deleteEntry', () async {
        when(mockStorageService.deleteDailyEntry(any)).thenThrow(Exception('Test error'));

        final result = await controller.deleteEntry('2024-01-15');

        expect(result, isFalse);
        expect(controller.isLoading, isFalse);
      });

      test('should handle errors in clearAllData', () async {
        when(mockStorageService.clearAllData()).thenThrow(Exception('Test error'));

        await controller.clearAllData();

        expect(controller.isLoading, isFalse);
        verify(mockStorageService.clearAllData()).called(1);
      });
    });

    group('date and time management', () {
      test('should format current date correctly', () {
        final currentDate = controller.currentDate;
        expect(currentDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      });

      test('should generate timestamp correctly in saved entries', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        final beforeSave = DateTime.now();

        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final afterSave = DateTime.now();
        final savedEntry = controller.todayEntry!;

        expect(savedEntry.timestamp.isAfter(beforeSave) || savedEntry.timestamp.isAtSameMomentAs(beforeSave), isTrue);
        expect(savedEntry.timestamp.isBefore(afterSave) || savedEntry.timestamp.isAtSameMomentAs(afterSave), isTrue);
      });
    });

    group('public API consistency', () {
      test('should maintain consistent state between getters', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);

        // Initially no photo
        expect(controller.hasTodayPhoto, isFalse);
        expect(controller.todayEntry, isNull);
        expect(controller.totalPhotosCount, equals(0));

        // Save a photo
        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        // State should be consistent
        expect(controller.hasTodayPhoto, isTrue);
        expect(controller.todayEntry, isNotNull);
        expect(controller.todayEntry!.date, equals(DailyEntry.getTodayKey()));
      });

      test('should handle reactive updates correctly', () async {
        when(mockStorageService.saveDailyEntry(any)).thenAnswer((_) async => true);
        when(mockStorageService.getAllEntries()).thenAnswer((_) async => []);
        when(mockStorageService.deleteDailyEntry(any)).thenAnswer((_) async => true);

        // Save a photo
        await controller.savePhotoEntry(
          photoPath: '/test/photo.jpg',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(controller.hasTodayPhoto, isTrue);

        // Delete the photo
        await controller.deleteTodayEntry();

        expect(controller.hasTodayPhoto, isFalse);
        expect(controller.todayEntry, isNull);
      });
    });
  });
}