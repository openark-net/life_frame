import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'gallery_screen.dart';
import 'debug_screen.dart';

class TabDefinition {
  final IconData icon;
  final String label;
  final Widget screen;
  final bool Function() shouldShow;

  const TabDefinition({
    required this.icon,
    required this.label,
    required this.screen,
    required this.shouldShow,
  });
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(() {
      // Define all possible tabs with their show conditions
      final allTabs = <TabDefinition>[
        TabDefinition(
          icon: CupertinoIcons.home,
          label: 'Home',
          screen: const HomeScreen(),
          shouldShow: () => true, // Always show
        ),
        TabDefinition(
          icon: CupertinoIcons.map,
          label: 'Map',
          screen: const MapScreen(),
          shouldShow: () => Platform.isAndroid, // Only on Android
        ),
        TabDefinition(
          icon: CupertinoIcons.photo_on_rectangle,
          label: 'Gallery',
          screen: const GalleryScreen(),
          shouldShow: () => true, // Always show
        ),
        TabDefinition(
          icon: CupertinoIcons.wrench_fill,
          label: 'Debug',
          screen: const DebugScreen(),
          shouldShow: () => navController
              .isDebugModeVisible, // Only when debug mode is visible
        ),
      ];

      // Filter tabs based on their show conditions
      final visibleTabs = allTabs.where((tab) => tab.shouldShow()).toList();

      // Generate bottom navigation items
      final items = visibleTabs
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(tab.icon),
              ),
              label: tab.label,
            ),
          )
          .toList();

      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: items,
          border: Border(
            top: BorderSide(
              color: CupertinoTheme.of(context).brightness == Brightness.dark
                  ? CupertinoColors.separator
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
        ),
        tabBuilder: (BuildContext context, int index) {
          // Simply return the screen at the given index
          return CupertinoTabView(
            builder: (context) => visibleTabs[index].screen,
          );
        },
      );
    });
  }
}
