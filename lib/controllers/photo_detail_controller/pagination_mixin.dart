import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../../models/daily_entry.dart';
import '../daily_entry_controller.dart';

mixin PhotoDetailPaginationMixin on GetxController {
  late PageController pageController;
  final RxList<DailyEntry> entries = <DailyEntry>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  static const int _windowSize = 20;
  static const int _loadThreshold = 5;
  static const int _loadBatchSize = 10;

  int _absolutePosition = 0;
  int _entriesLoadedBefore = 0;
  int _entriesLoadedAfter = 0;

  DailyEntryController get photoJournalController;
  DailyEntry get initialEntry;
  Talker get talker => Get.find<Talker>();

  Future<void> loadEntries() async {
    isLoading.value = true;

    try {
      _absolutePosition = await photoJournalController.getEntryPosition(
        initialEntry,
      );
      talker.debug('Initial entry absolute position: $_absolutePosition');

      final initialEntries = await photoJournalController
          .getEntriesAroundPosition(_absolutePosition, _windowSize);

      if (initialEntries.isEmpty) {
        talker.warning('No entries found around position $_absolutePosition');
        isLoading.value = false;
        return;
      }

      entries.value = initialEntries;

      final initialIndex = entries.indexWhere(
        (entry) => entry.timestamp == initialEntry.timestamp,
      );
      currentIndex.value = initialIndex >= 0 ? initialIndex : 0;

      _entriesLoadedBefore = currentIndex.value;
      _entriesLoadedAfter = entries.length - currentIndex.value - 1;

      talker.debug(
        'Loaded ${entries.length} initial entries. '
        'Before: $_entriesLoadedBefore, After: $_entriesLoadedAfter',
      );

      pageController = PageController(initialPage: currentIndex.value);
      pageController.addListener(_onScroll);

      await preloadInitialImages();

      isLoading.value = false;
    } catch (e, st) {
      talker.handle(e, st, 'Error loading initial entries');
      isLoading.value = false;
    }
  }

  void _onScroll() {
    if (isLoadingMore.value || entries.isEmpty) return;

    final needsMoreAtEnd =
        currentIndex.value >= entries.length - _loadThreshold;
    final needsMoreAtStart = currentIndex.value < _loadThreshold;

    if (needsMoreAtEnd) {
      _loadOlderEntries();
    } else if (needsMoreAtStart) {
      _loadNewerEntries();
    }
  }

  Future<void> _loadNewerEntries() async {
    if (isLoadingMore.value || _absolutePosition - _entriesLoadedBefore <= 0) {
      talker.debug('No newer entries to load');
      return;
    }

    isLoadingMore.value = true;

    try {
      final positionToLoad = _absolutePosition - _entriesLoadedBefore - 1;
      talker.debug('Loading newer entries from position: $positionToLoad');

      final newEntries = await photoJournalController.getEntriesAfterPosition(
        positionToLoad,
        _loadBatchSize,
      );

      if (newEntries.isEmpty) {
        talker.debug('No newer entries found');
        isLoadingMore.value = false;
        return;
      }

      newEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final uniqueNewEntries = newEntries.where((entry) {
        return !entries.any((e) => e.timestamp == entry.timestamp);
      }).toList();

      if (uniqueNewEntries.isEmpty) {
        talker.debug('All fetched entries already exist');
        isLoadingMore.value = false;
        return;
      }

      final currentEntry = entries[currentIndex.value];

      entries.insertAll(0, uniqueNewEntries);
      _entriesLoadedBefore += uniqueNewEntries.length;

      currentIndex.value = entries.indexWhere(
        (e) => e.timestamp == currentEntry.timestamp,
      );

      pageController.jumpToPage(currentIndex.value);

      talker.info(
        'Loaded ${uniqueNewEntries.length} newer entries. '
        'Total before: $_entriesLoadedBefore',
      );

      for (var i = 0; i < uniqueNewEntries.length && i < 3; i++) {
        await preloadImageForIndex(i);
      }
    } catch (e, st) {
      talker.handle(e, st, 'Error loading newer entries');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadOlderEntries() async {
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;

    try {
      final positionToLoad = _absolutePosition + _entriesLoadedAfter + 1;
      talker.debug('Loading older entries from position: $positionToLoad');

      final newEntries = await photoJournalController.getEntriesBeforePosition(
        positionToLoad,
        _loadBatchSize,
      );

      if (newEntries.isEmpty) {
        talker.debug('No older entries found');
        isLoadingMore.value = false;
        return;
      }

      final uniqueNewEntries = newEntries.where((entry) {
        return !entries.any((e) => e.timestamp == entry.timestamp);
      }).toList();

      if (uniqueNewEntries.isEmpty) {
        talker.debug('All fetched entries already exist');
        isLoadingMore.value = false;
        return;
      }

      entries.addAll(uniqueNewEntries);
      _entriesLoadedAfter += uniqueNewEntries.length;

      talker.info(
        'Loaded ${uniqueNewEntries.length} older entries. '
        'Total after: $_entriesLoadedAfter',
      );

      final startIndex = entries.length - uniqueNewEntries.length;
      for (var i = 0; i < uniqueNewEntries.length && i < 3; i++) {
        await preloadImageForIndex(startIndex + i);
      }
    } catch (e, st) {
      talker.handle(e, st, 'Error loading older entries');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> preloadInitialImages() async {
    if (entries.isEmpty) return;

    final context = Get.context;
    if (context == null) return;

    final indicesToPreload = <int>[];

    indicesToPreload.add(currentIndex.value);

    if (currentIndex.value > 0) {
      indicesToPreload.add(currentIndex.value - 1);
    }
    if (currentIndex.value < entries.length - 1) {
      indicesToPreload.add(currentIndex.value + 1);
    }

    for (final index in indicesToPreload) {
      await preloadImageForIndex(index);
    }
  }

  Future<void> preloadImageForIndex(int index) async {
    final context = Get.context;
    if (context == null ||
        entries.isEmpty ||
        index < 0 ||
        index >= entries.length)
      return;

    try {
      final entry = entries[index];
      final file = File(entry.photoPath);

      if (!file.existsSync()) {
        talker.warning('Photo file does not exist: ${entry.photoPath}');
        return;
      }

      final image = FileImage(file);
      await precacheImage(image, context);
      talker.debug('Preloaded image for index $index');
    } catch (e, st) {
      talker.handle(e, st, 'Error preloading image at index $index');
    }
  }

  bool get hasNextPhoto => currentIndex.value < entries.length - 1;
  bool get hasPreviousPhoto => currentIndex.value > 0;

  DailyEntry get currentEntry => entries[currentIndex.value];

  DailyEntry? get nextEntry =>
      hasNextPhoto ? entries[currentIndex.value + 1] : null;

  DailyEntry? get previousEntry =>
      hasPreviousPhoto ? entries[currentIndex.value - 1] : null;

  void disposePagination() {
    if (entries.isNotEmpty) {
      pageController.removeListener(_onScroll);
      pageController.dispose();
    }
  }
}
