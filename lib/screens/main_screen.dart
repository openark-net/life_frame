import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'gallery_screen.dart';
import 'debug_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(() {
      final baseItems = [
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(CupertinoIcons.home),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(CupertinoIcons.map),
          ),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(CupertinoIcons.photo_on_rectangle),
          ),
          label: 'Gallery',
        ),
      ];

      final items = navController.isDebugModeVisible
          ? [
              ...baseItems,
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(CupertinoIcons.wrench_fill),
                ),
                label: 'Debug',
              ),
            ]
          : baseItems;

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
          switch (index) {
            case 0:
              return CupertinoTabView(builder: (context) => const HomeScreen());
            case 1:
              return CupertinoTabView(builder: (context) => const MapScreen());
            case 2:
              return CupertinoTabView(
                builder: (context) => const GalleryScreen(),
              );
            case 3:
              return CupertinoTabView(
                builder: (context) => const DebugScreen(),
              );
            default:
              return CupertinoTabView(builder: (context) => const HomeScreen());
          }
        },
      );
    });
  }
}
