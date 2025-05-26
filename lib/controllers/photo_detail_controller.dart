import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/daily_entry.dart';
import '../controllers/photo_journal_controller.dart';

class PhotoDetailController extends GetxController
    with GetTickerProviderStateMixin {
  final PhotoJournalController photoJournalController;
  final DailyEntry initialEntry;

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

  final RxList<DailyEntry> entries = <DailyEntry>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;

  final Random random = Random();
  final RxDouble currentPhotoRotation = 0.0.obs;
  final RxDouble nextPhotoRotation = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAnimations();
    _loadEntries();
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

  Future<void> _loadEntries() async {
    isLoading.value = true;

    try {
      final allEntries = await _getAllEntriesWithPhotos();
      final initialIndex = allEntries.indexWhere(
        (entry) => entry.date == initialEntry.date,
      );

      entries.value = allEntries;
      currentIndex.value = initialIndex >= 0 ? initialIndex : 0;
      isLoading.value = false;

      if (entries.isNotEmpty) {
        pageController = PageController(initialPage: currentIndex.value);
        await _preloadInitialImages();
        startNextPhotoPreview();
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<List<DailyEntry>> _getAllEntriesWithPhotos() async {
    final allEntries = photoJournalController.allEntries
        .where(
          (entry) =>
              entry.stitchedPhotoPath != null &&
              entry.stitchedPhotoPath!.isNotEmpty &&
              File(entry.stitchedPhotoPath!).existsSync(),
        )
        .toList();

    allEntries.sort((a, b) => b.date.compareTo(a.date));
    return allEntries;
  }

  Future<void> _preloadInitialImages() async {
    if (entries.isEmpty) return;

    final context = Get.context;
    if (context == null) return;

    final currentImage = FileImage(
      File(entries[currentIndex.value].stitchedPhotoPath!),
    );
    await precacheImage(currentImage, context);

    if (currentIndex.value < entries.length - 1) {
      final nextImage = FileImage(
        File(entries[currentIndex.value + 1].stitchedPhotoPath!),
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
  }

  Future<void> _preloadImageForIndex(int index) async {
    final context = Get.context;
    if (context == null || entries.isEmpty) return;

    final currentImage = FileImage(File(entries[index].stitchedPhotoPath!));
    await precacheImage(currentImage, context);
  }

  bool get hasNextPhoto => currentIndex.value < entries.length - 1;

  DailyEntry get currentEntry => entries[currentIndex.value];

  DailyEntry? get nextEntry =>
      hasNextPhoto ? entries[currentIndex.value + 1] : null;

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
