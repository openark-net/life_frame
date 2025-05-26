import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_detail_controller.dart';
import 'photo_stack.dart';

class PhotoPageView extends StatelessWidget {
  final PhotoDetailController controller;

  const PhotoPageView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.entries.length,
      itemBuilder: (context, index) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: Obx(() {
                  final isCurrentPage = controller.currentIndex.value == index;
                  return PhotoStack(
                    controller: controller,
                    entry: controller.entries[index],
                    index: index,
                    isCurrentPage: isCurrentPage,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
