import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_entry.dart';

class StorageService extends GetxService {
  static const String _entriesKey = 'daily_entries';
  late SharedPreferences _prefs;
  late Directory _photosDir;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _prefs = await SharedPreferences.getInstance();
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
}
