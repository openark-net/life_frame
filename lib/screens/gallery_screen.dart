import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/daily_entry_controller.dart';
import '../widgets/gallery/empty_gallery_state.dart';
import '../widgets/gallery/gallery_list.dart';
import '../widgets/background/AbstractBackground.dart';
import '../theme.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Gallery')),
      child: Stack(
        children: [
          const AbstractBackground(density: 0.4, seed: 54321),
          SafeArea(child: const GalleryList()),
        ],
      ),
    );
  }
}
