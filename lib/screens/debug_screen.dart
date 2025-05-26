import 'package:flutter/cupertino.dart';
import 'debug/photo_debug_screen.dart';
import 'debug/controller_debug_screen.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PhotoDebugScreen(),
    const ControllerDebugScreen(),
  ];

  final List<String> _tabTitles = ['Photos', 'Controller'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Debug: ${_tabTitles[_selectedIndex]}'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedIndex,
              onValueChanged: (value) {
                setState(() {
                  _selectedIndex = value!;
                });
              },
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Photos'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Controller'),
                ),
              },
            ),
            const SizedBox(height: 8),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
