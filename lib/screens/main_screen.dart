import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/layout/tab_bar_widget.dart';
import 'home_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
import 'debug_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    // Define all possible tabs with their show conditions
    final tabs = <TabDefinition>[
      TabDefinition(
        icon: CupertinoIcons.home,
        label: 'Home',
        screen: const HomeScreen(),
        shouldShow: () => true,
      ),
      TabDefinition(
        icon: CupertinoIcons.photo_on_rectangle,
        label: 'Gallery',
        screen: const GalleryScreen(),
        shouldShow: () => true,
      ),
      TabDefinition(
        icon: CupertinoIcons.settings,
        label: 'Settings',
        screen: const SettingsScreen(),
        shouldShow: () => true,
      ),
      TabDefinition(
        icon: CupertinoIcons.wrench_fill,
        label: 'Debug',
        screen: const DebugScreen(),
        shouldShow: () => navController.isDebugModeVisible,
      ),
    ];

    return TabBarWidget(tabs: tabs);
  }
}
