import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'gallery_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.photo_on_rectangle),
            label: 'Gallery',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const MapScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const GalleryScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}