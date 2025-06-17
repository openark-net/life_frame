import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

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

class TabBarWidget extends StatefulWidget {
  final List<TabDefinition> tabs;

  const TabBarWidget({super.key, required this.tabs});

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final talker = Get.find<Talker>();
      final visibleTabs = widget.tabs.where((tab) => tab.shouldShow()).toList();
      if (visibleTabs.isNotEmpty) {
        talker.info('App launched - Initial screen: ${visibleTabs[0].label}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final talker = Get.find<Talker>();

    return Obx(() {
      // Filter tabs based on their show conditions
      final visibleTabs = widget.tabs.where((tab) => tab.shouldShow()).toList();

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
          return CupertinoTabView(
            builder: (context) => visibleTabs[index].screen,
          );
        },
      );
    });
  }
}
