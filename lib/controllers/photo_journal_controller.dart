import 'dart:io';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/daily_entry.dart';
import '../services/storage_service.dart';

class PhotoJournalController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool _hasTodayPhoto = false.obs;
  final RxBool _isLoading = false.obs;
  final Rx<DailyEntry?> _todayEntry = Rx<DailyEntry?>(null);
  final RxList<DailyEntry> _allEntries = <DailyEntry>[].obs;
  final RxList<DailyEntry> _paginatedEntries = <DailyEntry>[].obs;
  final RxInt _totalPhotosCount = 0.obs;
  final RxInt _currentPage = 0.obs;
  final RxBool _hasMorePages = true.obs;
  final RxBool _isLoadingMore = false.obs;

  static const int _pageSize = 30;
  final RxString _currentDate = ''.obs;
  final RxString _todayBackPhoto = ''.obs;
  final RxString _todayFrontPhoto = ''.obs;

  bool get hasTodayPhoto => _hasTodayPhoto.value;
  bool get isLoading => _isLoading.value;
  DailyEntry? get todayEntry => _todayEntry.value;
  List<DailyEntry> get allEntries => _allEntries;
  List<DailyEntry> get paginatedEntries => _paginatedEntries;
  int get totalPhotosCount => _totalPhotosCount.value;
  int get currentPage => _currentPage.value;
  bool get hasMorePages => _hasMorePages.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get currentDate => _currentDate.value;
  String get todayBackPhoto => _todayBackPhoto.value;
  String get todayFrontPhoto => _todayFrontPhoto.value;

  @override
  void onInit() {
    super.onInit();
    _updateCurrentDate();
    _checkTodayPhoto();
    _loadInitialEntries();
    _loadAllEntries();
    _startDateUpdateTimer();
  }

  void _updateCurrentDate() {
    _currentDate.value = DailyEntry.getTodayKey();
  }

  void _startDateUpdateTimer() {
    ever(_currentDate, (String date) {
      _checkTodayPhoto();
    });

    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      final newDate = DailyEntry.getTodayKey();
      if (newDate != _currentDate.value) {
        _updateCurrentDate();
      }
    });
  }

  Future<void> _checkTodayPhoto() async {
    try {
      _isLoading.value = true;
      final hasPhoto = await _storageService.hasTodayPhoto();
      _hasTodayPhoto.value = hasPhoto;

      if (hasPhoto) {
        _todayEntry.value = await _storageService.getTodayEntry();
      } else {
        _todayEntry.value = null;
      }
    } catch (e) {
      print('PhotoJournalController: Error checking today photo: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadAllEntries() async {
    try {
      final entries = await _storageService.getAllEntries();
      _allEntries.value = entries;
      _totalPhotosCount.value = entries.length;
    } catch (e) {
      print('PhotoJournalController: Error loading all entries: $e');
    }
  }

  Future<void> _loadInitialEntries() async {
    try {
      _isLoading.value = true;
      _currentPage.value = 0;

      final entries = await _storageService.getEntriesPage(0, _pageSize);
      final totalCount = await _storageService.getTotalEntriesCount();

      _paginatedEntries.value = entries;
      _totalPhotosCount.value = totalCount;
      _hasMorePages.value =
          entries.length == _pageSize && totalCount > _pageSize;
    } catch (e) {
      print('PhotoJournalController: Error loading initial entries: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreEntries() async {
    if (_isLoadingMore.value || !_hasMorePages.value) return;

    try {
      _isLoadingMore.value = true;
      final nextPage = _currentPage.value + 1;

      final newEntries = await _storageService.getEntriesPage(
        nextPage,
        _pageSize,
      );

      if (newEntries.isNotEmpty) {
        _paginatedEntries.addAll(newEntries);
        _currentPage.value = nextPage;
        _hasMorePages.value = newEntries.length == _pageSize;
      } else {
        _hasMorePages.value = false;
      }
    } catch (e) {
      print('PhotoJournalController: Error loading more entries: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  Future<void> refreshEntries() async {
    await _loadInitialEntries();
  }

  Future<DailyEntry?> getEntryByDate(DateTime date) async {
    try {
      return await _storageService.getDailyEntry(date);
    } catch (e) {
      print('PhotoJournalController: Error getting entry by date: $e');
      return null;
    }
  }

  Future<DailyEntry?> getNextEntry(DateTime currentDate) async {
    try {
      return await _storageService.getNextEntry(currentDate);
    } catch (e) {
      print('PhotoJournalController: Error getting next entry: $e');
      return null;
    }
  }

  Future<DailyEntry?> getPreviousEntry(DateTime currentDate) async {
    try {
      return await _storageService.getPreviousEntry(currentDate);
    } catch (e) {
      print('PhotoJournalController: Error getting previous entry: $e');
      return null;
    }
  }

  Future<DailyEntry?> savePhotoEntry({
    required String photoPath,
    required double latitude,
    required double longitude,
    String? stitchedPhotoPath,
  }) async {
    try {
      _isLoading.value = true;

      final now = DateTime.now();
      final entry = DailyEntry(
        date: DailyEntry.formatDate(now),
        photoPath: photoPath,
        latitude: latitude,
        longitude: longitude,
        timestamp: now,
        stitchedPhotoPath: stitchedPhotoPath,
      );

      final success = await _storageService.saveDailyEntry(entry);

      if (success) {
        _hasTodayPhoto.value = true;
        _todayEntry.value = entry;
        await _loadAllEntries();
        await refreshEntries();
        return entry;
      }
    } catch (e) {
      print('PhotoJournalController: Error saving photo entry: $e');
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<bool> deleteEntry(String date) async {
    try {
      _isLoading.value = true;
      final success = await _storageService.deleteDailyEntry(date);

      if (success) {
        if (date == DailyEntry.getTodayKey()) {
          _hasTodayPhoto.value = false;
          _todayEntry.value = null;
          _todayBackPhoto.value = '';
          _todayFrontPhoto.value = '';
        }
        await _loadAllEntries();
        await refreshEntries();
      }

      return success;
    } catch (e) {
      print('PhotoJournalController: Error deleting entry: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteTodayEntry() async {
    final today = DailyEntry.getTodayKey();
    return await deleteEntry(today);
  }

  int getStreak() {
    if (_allEntries.isEmpty) return 0;

    final sortedEntries = List<DailyEntry>.from(_allEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    // Check if we have a photo for today
    final todayKey = DailyEntry.getTodayKey();
    final hasTodayPhoto = sortedEntries.any((entry) => entry.date == todayKey);

    // If no photo today, start counting from yesterday
    if (!hasTodayPhoto) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (final entry in sortedEntries) {
      final entryDate = DateTime.parse('${entry.date}T00:00:00');
      final expectedDate = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
      );

      if (entryDate.isAtSameMomentAs(expectedDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> clearAllData() async {
    try {
      _isLoading.value = true;
      await _storageService.clearAllData();
      _hasTodayPhoto.value = false;
      _todayEntry.value = null;
      _allEntries.clear();
      _paginatedEntries.clear();
      _totalPhotosCount.value = 0;
      _currentPage.value = 0;
      _hasMorePages.value = true;
    } catch (e) {
      print('PhotoJournalController: Error clearing all data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateTodayEntryWithStitchedPhoto(
    String stitchedPhotoPath,
  ) async {
    try {
      _isLoading.value = true;

      final currentEntry = _todayEntry.value;
      if (currentEntry == null) {
        return false;
      }

      final updatedEntry = currentEntry.copyWith(
        stitchedPhotoPath: stitchedPhotoPath,
      );

      final success = await _storageService.saveDailyEntry(updatedEntry);

      if (success) {
        _todayEntry.value = updatedEntry;
        await _loadAllEntries();
        await refreshEntries();
      }

      return success;
    } catch (e) {
      print(
        'PhotoJournalController: Error updating entry with stitched photo: $e',
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
