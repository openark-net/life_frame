import 'package:get/get.dart';
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

  bool get hasTodayPhoto => _hasTodayPhoto.value;
  bool get isLoading => _isLoading.value;
  DailyEntry? get todayEntry => _todayEntry.value;
  List<DailyEntry> get allEntries => _allEntries;
  List<DailyEntry> get paginatedEntries => _paginatedEntries;
  bool get hasMorePages => _hasMorePages.value;
  bool get isLoadingMore => _isLoadingMore.value;

  @override
  void onInit() {
    super.onInit();
    _checkTodayPhoto();
    _loadInitialEntries();
    _loadAllEntries();
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

  Future<DailyEntry?> savePhotoEntry({
    required String photoPath,
    required double latitude,
    required double longitude,
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
}
