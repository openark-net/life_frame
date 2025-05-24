import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'main_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(() {
      if (navController.isNavBarVisible) {
        return const MainScreen();
      } else {
        return const HomeScreen();
      }
    });
  }
}