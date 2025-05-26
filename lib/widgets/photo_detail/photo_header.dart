import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PhotoHeader extends StatelessWidget {
  const PhotoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.black.withValues(alpha: 0.7),
                CupertinoColors.black.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Row(
            children: [
              CupertinoButton(
                onPressed: () => Get.back(),
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
