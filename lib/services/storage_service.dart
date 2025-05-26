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

  Future<DailyEntry?> getDailyEntry(String date) async {
    try {
      final entries = await _getAllEntries();
      final entryData = entries[date];

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
    final today = DailyEntry.getTodayKey();
    return await getDailyEntry(today);
  }

  Future<bool> hasPhotoForDate(String date) async {
    final entry = await getDailyEntry(date);
    return entry != null;
  }

  Future<bool> hasTodayPhoto() async {
    final today = DailyEntry.getTodayKey();
    return await hasPhotoForDate(today);
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
