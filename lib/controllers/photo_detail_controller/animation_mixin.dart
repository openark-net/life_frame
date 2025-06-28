import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

mixin PhotoDetailAnimationMixin on GetxController {
  TickerProvider get vsync;
  late AnimationController animationController;
  late AnimationController nextPhotoAnimationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> nextPhotoFadeAnimation;

  final Random random = Random();
  final RxDouble currentPhotoRotation = 0.0.obs;
  final RxDouble nextPhotoRotation = 0.0.obs;

  void setupAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    nextPhotoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
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

  void startNextPhotoPreview(int currentIndex, int totalEntries) {
    if (currentIndex < totalEntries - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        nextPhotoAnimationController.forward();
      });
    }
  }

  void resetAnimationsForPageChange() {
    animationController.reset();
    nextPhotoAnimationController.reset();
    generateRandomRotations();
    animationController.forward();
  }

  void disposeAnimations() {
    animationController.dispose();
    nextPhotoAnimationController.dispose();
  }
}