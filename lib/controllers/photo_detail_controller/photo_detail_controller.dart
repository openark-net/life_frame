import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../models/daily_entry.dart';
import '../daily_entry_controller.dart';
import 'animation_mixin.dart';
import 'pagination_mixin.dart';

class PhotoDetailController extends GetxController
    with
        GetTickerProviderStateMixin,
        PhotoDetailAnimationMixin,
        PhotoDetailPaginationMixin {
  @override
  final DailyEntryController photoJournalController;
  @override
  final DailyEntry initialEntry;

  @override
  TickerProvider get vsync => this;

  PhotoDetailController({
    required this.photoJournalController,
    required this.initialEntry,
  });

  @override
  void onInit() {
    super.onInit();
    setupAnimations();
    loadEntries().then((_) {
      if (entries.isNotEmpty) {
        startNextPhotoPreview(currentIndex.value, entries.length);
      }
    });
  }

  void onPageChanged(int index) {
    final previousIndex = currentIndex.value;
    currentIndex.value = index;

    resetAnimationsForPageChange();

    if (index > previousIndex) {
      if (index + 2 < entries.length) {
        preloadImageForIndex(index + 2);
      }
    } else if (index < previousIndex) {
      if (index - 2 >= 0) {
        preloadImageForIndex(index - 2);
      }
    }

    startNextPhotoPreview(index, entries.length);
  }

  @override
  void onClose() {
    disposeAnimations();
    disposePagination();
    super.onClose();
  }
}
