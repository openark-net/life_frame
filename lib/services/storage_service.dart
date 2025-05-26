import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_entry.dart';

class StorageService extends GetxService {
  static const String _entriesKey = 'daily_entries';
  static const String _photosDirectory = 'life_frame_photos';

  late SharedPreferences _prefs;
  late Directory _photosDir;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _prefs = await SharedPreferences.getInstance();
    await _setupPhotosDirectory();
  }

  Future<void> _setupPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    _photosDir = Directory('${appDir.path}/$_photosDirectory');

    if (!await _photosDir.exists()) {
      await _photosDir.create(recursive: true);
    }
  }

  Future<String> getPhotosDirectoryPath() async {
    final now = DateTime.now();
    final yearMonth = '${now.year}/${now.month.toString().padLeft(2, '0')}';
    final monthDir = Directory('${_photosDir.path}/$yearMonth');

    if (!await monthDir.exists()) {
      await monthDir.create(recursive: true);
    }

    return monthDir.path;
  }

  Future<Directory> getPhotosDirectory() async {
    final path = await getPhotosDirectoryPath();
    return Directory(path);
  }

  String generatePhotoFileName() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'photo_$timestamp.jpg';
  }

  Future<bool> saveDailyEntry(DailyEntry entry) async {
    try {
      if (!entry.isValid()) {
        print('StorageService: Invalid entry data');
        return false;
      }

      final entries = await _getAllEntries();
      entries[entry.date] = entry.toJson();

      final entriesJson = json.encode(entries);
      return await _prefs.setString(_entriesKey, entriesJson);
    } catch (e) {
      print('StorageService: Error saving entry: $e');
      return false;
    }
  }

  Future<DailyEntry?> getDailyEntry(DateTime date) async {
    try {
      final dateKey = DailyEntry.formatDate(date);
      final entries = await _getAllEntries();
      final entryData = entries[dateKey];

      if (entryData != null) {
        return DailyEntry.fromJson(entryData);
      }
      return null;
    } catch (e) {
      print('StorageService: Error getting entry: $e');
      return null;
    }
  }

  Future<DailyEntry?> getTodayEntry() async {
    return await getDailyEntry(DateTime.now());
  }

  Future<bool> hasPhotoForDate(DateTime date) async {
    final entry = await getDailyEntry(date);
    return entry != null;
  }

  Future<bool> hasTodayPhoto() async {
    return await hasPhotoForDate(DateTime.now());
  }

  Future<Map<String, dynamic>> _getAllEntries() async {
    try {
      final entriesJson = _prefs.getString(_entriesKey);
      if (entriesJson != null) {
        return json.decode(entriesJson);
      }
      return <String, dynamic>{};
    } catch (e) {
      print('StorageService: Error getting all entries: $e');
      return <String, dynamic>{};
    }
  }

  Future<List<DailyEntry>> getAllEntries() async {
    try {
      final entriesMap = await _getAllEntries();
      return entriesMap.values
          .map((entryData) => DailyEntry.fromJson(entryData))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('StorageService: Error getting all entries list: $e');
      return [];
    }
  }

  Future<List<String>> _getSortedDateKeys() async {
    try {
      final entriesMap = await _getAllEntries();
      final dateKeys = entriesMap.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
      return dateKeys;
    } catch (e) {
      print('StorageService: Error getting sorted date keys: $e');
      return [];
    }
  }

  Future<int> getTotalEntriesCount() async {
    try {
      final entriesMap = await _getAllEntries();
      return entriesMap.length;
    } catch (e) {
      print('StorageService: Error getting total entries count: $e');
      return 0;
    }
  }

  Future<int> getTotalPages(int pageSize) async {
    final totalCount = await getTotalEntriesCount();
    return (totalCount / pageSize).ceil();
  }

  Future<List<DailyEntry>> getEntriesPage(int page, int pageSize) async {
    try {
      final dateKeys = await _getSortedDateKeys();
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, dateKeys.length);

      if (startIndex >= dateKeys.length) {
        return [];
      }

      final pageKeys = dateKeys.sublist(startIndex, endIndex);
      final entriesMap = await _getAllEntries();

      final entries = <DailyEntry>[];
      for (final key in pageKeys) {
        final entryData = entriesMap[key];
        if (entryData != null) {
          entries.add(DailyEntry.fromJson(entryData));
        }
      }

      return entries;
    } catch (e) {
      print('StorageService: Error getting entries page: $e');
      return [];
    }
  }

  Future<DailyEntry?> getNextEntry(DateTime currentDate) async {
    try {
      final currentDateKey = DailyEntry.formatDate(currentDate);
      final dateKeys = await _getSortedDateKeys();

      final currentIndex = dateKeys.indexOf(currentDateKey);
      if (currentIndex == -1 || currentIndex == 0) {
        return null; // No next entry (already at newest)
      }

      final nextDateKey = dateKeys[currentIndex - 1];
      final entriesMap = await _getAllEntries();
      final entryData = entriesMap[nextDateKey];

      return entryData != null ? DailyEntry.fromJson(entryData) : null;
    } catch (e) {
      print('StorageService: Error getting next entry: $e');
      return null;
    }
  }

  Future<DailyEntry?> getPreviousEntry(DateTime currentDate) async {
    try {
      final currentDateKey = DailyEntry.formatDate(currentDate);
      final dateKeys = await _getSortedDateKeys();

      final currentIndex = dateKeys.indexOf(currentDateKey);
      if (currentIndex == -1 || currentIndex >= dateKeys.length - 1) {
        return null; // No previous entry (already at oldest)
      }

      final previousDateKey = dateKeys[currentIndex + 1];
      final entriesMap = await _getAllEntries();
      final entryData = entriesMap[previousDateKey];

      return entryData != null ? DailyEntry.fromJson(entryData) : null;
    } catch (e) {
      print('StorageService: Error getting previous entry: $e');
      return null;
    }
  }

  Future<List<DailyEntry>> getEntriesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entriesMap = await _getAllEntries();
      final entries = <DailyEntry>[];

      for (final entryData in entriesMap.values) {
        final entry = DailyEntry.fromJson(entryData);
        final entryDate = DateTime.parse('${entry.date}T00:00:00');

        if (entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entryDate.isBefore(endDate.add(const Duration(days: 1)))) {
          entries.add(entry);
        }
      }

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      print('StorageService: Error getting entries in date range: $e');
      return [];
    }
  }

  Future<bool> deleteDailyEntry(String date) async {
    try {
      final entries = await _getAllEntries();
      final entry = entries[date];

      if (entry != null) {
        final photoPath = entry['photoPath'];
        if (photoPath != null) {
          final photoFile = File(photoPath);
          if (await photoFile.exists()) {
            await photoFile.delete();
          }
        }

        entries.remove(date);
        final entriesJson = json.encode(entries);
        return await _prefs.setString(_entriesKey, entriesJson);
      }
      return true;
    } catch (e) {
      print('StorageService: Error deleting entry: $e');
      return false;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _prefs.remove(_entriesKey);
      if (await _photosDir.exists()) {
        await _photosDir.delete(recursive: true);
        await _setupPhotosDirectory();
      }
    } catch (e) {
      print('StorageService: Error clearing all data: $e');
    }
  }
}
