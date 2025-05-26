import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../controllers/photo_detail_controller.dart';

class AnimatedPhoto extends StatelessWidget {
  final PhotoDetailController controller;
  final String photoPath;
  final double rotation;

  const AnimatedPhoto({
    super.key,
    required this.controller,
    required this.photoPath,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: controller.scaleAnimation.value,
            child: Opacity(
              opacity: controller.fadeAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: CupertinoColors.white.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: CupertinoColors.systemGrey6,
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 40,
                            color: CupertinoColors.systemGrey3,
                          ),
                        ),
                      );
                    },
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
