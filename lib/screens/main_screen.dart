import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final talker = Get.find<Talker>();
      talker.info('App launched - Initial screen: Home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();
    final talker = Get.find<Talker>();

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
          icon: CupertinoIcons.photo_on_rectangle,
          label: 'Gallery',
          screen: const GalleryScreen(),
          shouldShow: () => true, // Always show
        ),
        TabDefinition(
          icon: CupertinoIcons.settings,
          label: 'Settings',
          screen: const SettingsScreen(),
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

      // Ensure current index is within bounds when tabs change
      if (_currentIndex >= visibleTabs.length) {
        _currentIndex = 0;
      }

      // Generate bottom navigation items
      final items = visibleTabs
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(tab.icon),
              ),
            ),
          )
          .toList();

      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: items,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              final newScreen = visibleTabs[index].label;
              final oldScreen = visibleTabs[_currentIndex].label;
              talker.info('Screen switch: $oldScreen -> $newScreen');
              setState(() {
                _currentIndex = index;
              });
            }
          },
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
