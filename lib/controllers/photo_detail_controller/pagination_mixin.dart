import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../models/daily_entry.dart';
import '../daily_entry_controller.dart';

mixin PhotoDetailPaginationMixin on GetxController {
  late PageController pageController;
  final RxList<DailyEntry> entries = <DailyEntry>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;

  DailyEntryController get photoJournalController;
  DailyEntry get initialEntry;

  Future<void> loadEntries() async {
    isLoading.value = true;

    try {
      final allEntries = await getAllEntriesWithPhotos();
      final initialIndex = allEntries.indexWhere(
        (entry) => entry.timestamp == initialEntry.timestamp,
      );

      entries.value = allEntries;
      currentIndex.value = initialIndex >= 0 ? initialIndex : 0;
      isLoading.value = false;

      if (entries.isNotEmpty) {
        pageController = PageController(initialPage: currentIndex.value);
        await preloadInitialImages();
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<List<DailyEntry>> getAllEntriesWithPhotos() async {
    return (await photoJournalController.list()).results;
  }

  Future<void> preloadInitialImages() async {
    if (entries.isEmpty) return;

    final context = Get.context;
    if (context == null) return;

    final currentEntry = entries[currentIndex.value];
    final currentImage = FileImage(File(currentEntry.photoPath));
    await precacheImage(currentImage, context);

    if (currentIndex.value < entries.length - 1) {
      final nextEntry = entries[currentIndex.value + 1];
      final nextImage = FileImage(File(nextEntry.photoPath));
      await precacheImage(nextImage, context);
    }
  }

  Future<void> preloadImageForIndex(int index) async {
    final context = Get.context;
    if (context == null || entries.isEmpty || index >= entries.length) return;

    final entry = entries[index];
    final currentImage = FileImage(File(entry.photoPath));
    await precacheImage(currentImage, context);
  }

  bool get hasNextPhoto => currentIndex.value < entries.length - 1;

  DailyEntry get currentEntry => entries[currentIndex.value];

  DailyEntry? get nextEntry =>
      hasNextPhoto ? entries[currentIndex.value + 1] : null;

  void disposePagination() {
    if (entries.isNotEmpty) {
      pageController.dispose();
    }
  }
}