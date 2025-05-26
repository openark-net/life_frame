import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../controllers/photo_detail_controller.dart';

class PhotoPreview extends StatelessWidget {
  final PhotoDetailController controller;
  final String photoPath;
  final double rotation;

  const PhotoPreview({
    super.key,
    required this.controller,
    required this.photoPath,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.nextPhotoFadeAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: 0.85,
            child: Transform.translate(
              offset: const Offset(25, 20),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.white.withValues(
                        alpha: controller.nextPhotoFadeAnimation.value * 0.1,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Opacity(
                    opacity: controller.nextPhotoFadeAnimation.value,
                    child: Image.file(File(photoPath), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
