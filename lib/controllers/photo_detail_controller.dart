import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../models/daily_entry.dart';
import '../models/pagination_result.dart';
import '../controllers/daily_entry_controller.dart';

class PhotoDetailController extends GetxController
    with GetTickerProviderStateMixin {
  final DailyEntryController photoJournalController;
  final DailyEntry initialEntry;
  final Talker _talker = Get.find<Talker>();

  PhotoDetailController({
    required this.photoJournalController,
    required this.initialEntry,
  });

  late PageController pageController;
  late AnimationController animationController;
  late AnimationController nextPhotoAnimationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> nextPhotoFadeAnimation;

  // Pagination state
  static const int _pageSize = 20;
  static const int _preloadThreshold =
      5; // Load more when within 5 items of edge

  final RxList<DailyEntry> entries = <DailyEntry>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Pagination tracking
  bool _hasNextPage = true;
  bool _hasPreviousPage = false;
  int? _nextCursor;
  int? _previousCursor;
  int _totalEntries = 0;
  int _initialEntryGlobalIndex = 0;

  final Random random = Random();
  final RxDouble currentPhotoRotation = 0.0.obs;
  final RxDouble nextPhotoRotation = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAnimations();
    _loadInitialEntries();
  }

  void _setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    nextPhotoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    nextPhotoFadeAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: nextPhotoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    animationController.forward();
    generateRandomRotations();
  }

  void generateRandomRotations() {
    currentPhotoRotation.value = (random.nextDouble() - 0.5) * 20 * pi / 180;
    nextPhotoRotation.value = (random.nextDouble() - 0.5) * 20 * pi / 180;

    while ((currentPhotoRotation.value - nextPhotoRotation.value).abs() <
        10 * pi / 180) {
      nextPhotoRotation.value = (random.nextDouble() - 0.5) * 20 * pi / 180;
    }
  }

  Future<void> _loadInitialEntries() async {
    isLoading.value = true;

    try {
      // First, find the initial entry's position in the full dataset
      await _findInitialEntryPosition();

      // Load the page containing the initial entry
      await _loadPageContainingInitialEntry();

      // Set up the page controller
      if (entries.isNotEmpty) {
        final initialIndex = entries.indexWhere(
          (entry) => entry.timestamp == initialEntry.timestamp,
        );
        currentIndex.value = initialIndex >= 0 ? initialIndex : 0;
        pageController = PageController(initialPage: currentIndex.value);

        await _preloadInitialImages();
        startNextPhotoPreview();
      }

      isLoading.value = false;
      _talker.info(
        'Loaded initial entries, current index: ${currentIndex.value}',
      );
    } catch (e, st) {
      _talker.handle(e, st, 'Error loading initial entries');
      isLoading.value = false;
    }
  }

  Future<void> _findInitialEntryPosition() async {
    try {
      // Get first page to establish total count and find initial entry
      final firstPage = await photoJournalController.list(pageSize: _pageSize);
      _totalEntries = firstPage.total;

      // Check if initial entry is in first page
      final entryIndex = firstPage.results.indexWhere(
        (entry) => entry.timestamp == initialEntry.timestamp,
      );

      if (entryIndex != -1) {
        _initialEntryGlobalIndex = entryIndex;
        return;
      }

      // If not in first page, we need to paginate through to find it
      int currentGlobalIndex = firstPage.results.length;
      int? cursor = firstPage.results.isNotEmpty
          ? firstPage.results.last.timestamp.millisecondsSinceEpoch
          : null;

      while (cursor != null) {
        final page = await photoJournalController.list(
          cursor: cursor,
          pageSize: _pageSize,
        );

        final entryIndex = page.results.indexWhere(
          (entry) => entry.timestamp == initialEntry.timestamp,
        );

        if (entryIndex != -1) {
          _initialEntryGlobalIndex = currentGlobalIndex + entryIndex;
          return;
        }

        if (!page.hasNextPage) break;

        currentGlobalIndex += page.results.length;
        cursor = page.results.isNotEmpty
            ? page.results.last.timestamp.millisecondsSinceEpoch
            : null;
      }

      // If we get here, entry wasn't found - default to beginning
      _initialEntryGlobalIndex = 0;
      _talker.warning('Initial entry not found, defaulting to first photo');
    } catch (e, st) {
      _talker.handle(e, st, 'Error finding initial entry position');
      _initialEntryGlobalIndex = 0;
    }
  }

  Future<void> _loadPageContainingInitialEntry() async {
    try {
      // Calculate which page the initial entry should be on
      final targetPage = _initialEntryGlobalIndex ~/ _pageSize;

      if (targetPage == 0) {
        // Initial entry is on first page
        await _loadFirstPage();
      } else {
        // Need to navigate to the correct page
        await _loadSpecificPage(targetPage);
      }
    } catch (e, st) {
      _talker.handle(e, st, 'Error loading page containing initial entry');
      // Fallback to first page
      await _loadFirstPage();
    }
  }

  Future<void> _loadFirstPage() async {
    final result = await photoJournalController.list(pageSize: _pageSize);
    entries.value = result.results;
    _hasNextPage = result.hasNextPage;
    _hasPreviousPage = false;
    _nextCursor = result.results.isNotEmpty
        ? result.results.last.timestamp.millisecondsSinceEpoch
        : null;
    _previousCursor = null;
    _totalEntries = result.total;
  }

  Future<void> _loadSpecificPage(int targetPage) async {
    // Start from beginning and paginate to target page
    PaginationResult<DailyEntry> result = await photoJournalController.list(
      pageSize: _pageSize,
    );

    for (int page = 0; page < targetPage && result.hasNextPage; page++) {
      final cursor = result.results.isNotEmpty
          ? result.results.last.timestamp.millisecondsSinceEpoch
          : null;
      if (cursor == null) break;

      result = await photoJournalController.list(
        cursor: cursor,
        pageSize: _pageSize,
      );
    }

    entries.value = result.results;
    _hasNextPage = result.hasNextPage;
    _hasPreviousPage = result.hasPreviousPage;
    _nextCursor = result.results.isNotEmpty
        ? result.results.last.timestamp.millisecondsSinceEpoch
        : null;
    // For previous cursor, we'd need the first entry's timestamp of this page
    // For simplicity, we'll reload from beginning when going backward
    _previousCursor = null;
    _totalEntries = result.total;
  }

  Future<void> _loadNextPage() async {
    if (!_hasNextPage || isLoadingMore.value || _nextCursor == null) return;

    isLoadingMore.value = true;
    try {
      final result = await photoJournalController.list(
        cursor: _nextCursor,
        pageSize: _pageSize,
      );

      entries.addAll(result.results);
      _hasNextPage = result.hasNextPage;
      _nextCursor = result.results.isNotEmpty
          ? result.results.last.timestamp.millisecondsSinceEpoch
          : null;

      _talker.debug('Loaded next page: ${result.results.length} items');
    } catch (e, st) {
      _talker.handle(e, st, 'Error loading next page');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _loadPreviousPage() async {
    if (!_hasPreviousPage || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      // For previous pages, we need to reload from the beginning
      // This is a simplification - a more complex implementation would
      // maintain a proper bidirectional cursor system

      final currentFirstEntry = entries.first;
      final firstPageResult = await photoJournalController.list(
        pageSize: _pageSize,
      );

      // Find how many pages we need to load to get to our current position
      final entriesToLoad = entries.length + _pageSize;
      final pagesToLoad = (entriesToLoad / _pageSize).ceil();

      List<DailyEntry> allEntries = firstPageResult.results;
      PaginationResult<DailyEntry> result = firstPageResult;

      for (int i = 1; i < pagesToLoad && result.hasNextPage; i++) {
        final cursor = result.results.isNotEmpty
            ? result.results.last.timestamp.millisecondsSinceEpoch
            : null;
        if (cursor == null) break;

        result = await photoJournalController.list(
          cursor: cursor,
          pageSize: _pageSize,
        );
        allEntries.addAll(result.results);
      }

      // Find where our current first entry is in the expanded list
      final currentFirstIndex = allEntries.indexWhere(
        (entry) => entry.timestamp == currentFirstEntry.timestamp,
      );

      if (currentFirstIndex > 0) {
        // Update current index to account for new entries at the beginning
        final newEntriesCount = currentFirstIndex;
        currentIndex.value += newEntriesCount;

        // Update page controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(currentIndex.value);
          }
        });
      }

      entries.value = allEntries;
      _hasPreviousPage = result.hasPreviousPage;
      _hasNextPage = result.hasNextPage;
      _nextCursor = result.results.isNotEmpty
          ? result.results.last.timestamp.millisecondsSinceEpoch
          : null;

      _talker.debug('Loaded previous page, total entries: ${entries.length}');
    } catch (e, st) {
      _talker.handle(e, st, 'Error loading previous page');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> _preloadInitialImages() async {
    if (entries.isEmpty) return;

    final context = Get.context;
    if (context == null) return;

    final currentImage = FileImage(
      File(entries[currentIndex.value].photoPath!),
    );
    await precacheImage(currentImage, context);

    if (currentIndex.value < entries.length - 1) {
      final nextImage = FileImage(
        File(entries[currentIndex.value + 1].photoPath!),
      );
      await precacheImage(nextImage, context);
    }
  }

  void startNextPhotoPreview() {
    if (currentIndex.value < entries.length - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        nextPhotoAnimationController.forward();
      });
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;

    animationController.reset();
    nextPhotoAnimationController.reset();
    generateRandomRotations();
    animationController.forward();

    _preloadImageForIndex(index);
    startNextPhotoPreview();

    // Check if we need to load more entries
    _checkAndLoadMoreEntries(index);
  }

  void _checkAndLoadMoreEntries(int index) {
    // Load next page if approaching end
    if (index >= entries.length - _preloadThreshold && _hasNextPage) {
      _loadNextPage();
    }

    // Load previous page if approaching beginning
    if (index < _preloadThreshold && _hasPreviousPage) {
      _loadPreviousPage();
    }
  }

  Future<void> _preloadImageForIndex(int index) async {
    final context = Get.context;
    if (context == null || entries.isEmpty || index >= entries.length) return;

    final currentImage = FileImage(File(entries[index].photoPath!));
    await precacheImage(currentImage, context);
  }

  bool get hasNextPhoto =>
      currentIndex.value < entries.length - 1 || _hasNextPage;

  DailyEntry get currentEntry => entries[currentIndex.value];

  DailyEntry? get nextEntry => currentIndex.value < entries.length - 1
      ? entries[currentIndex.value + 1]
      : null;

  int get totalPhotoCount => _totalEntries;

  int get currentPhotoNumber =>
      _initialEntryGlobalIndex - (entries.length - 1 - currentIndex.value) + 1;

  @override
  void onClose() {
    animationController.dispose();
    nextPhotoAnimationController.dispose();
    if (entries.isNotEmpty) {
      pageController.dispose();
    }
    super.onClose();
  }
}
