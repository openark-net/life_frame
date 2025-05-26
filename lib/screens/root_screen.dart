import 'package:flutter/cupertino.dart';
import 'main_screen.dart';
import '../widgets/permissions_checker.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionsChecker(
      onAllPermissionsGranted: () {},
      child:
          MainScreen(), // This will be shown when all permissions are granted
    );
  }
}
