import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:life_frame/screens/main_screen.dart';
import 'package:life_frame/services/app_notification_service.dart';
import 'package:life_frame/services/donation_service.dart';
import 'package:life_frame/services/location.dart';
import 'package:life_frame/services/permissions_service.dart';
import 'package:life_frame/theme.dart';
import 'package:life_frame/widgets/permissions_checker.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'services/notification_service.dart';
import 'controllers/daily_entry_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/settings_controller.dart';

void main() async {
  final talker = TalkerFlutter.init();
  Get.put<Talker>(talker);
  try {
    WidgetsFlutterBinding.ensureInitialized();

    Get.put(DailyEntryController());
    Get.put(NavigationController());
    Get.put(SettingsController());
    Get.put(PermissionsService());
    Get.put(InAppPurchaseService());
    Get.put(AppNotificationService());
    await Get.putAsync(() async {
      final notificationService = NotificationService();
      await notificationService.onInit();
      return notificationService;
    });
    await Get.putAsync<LocationService>(() async {
      final service = LocationService();
      await service.onInit();
      return service;
    });
  } catch (e, st) {
    talker.handle(e, st, "ERROR INITIALIZING");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'Life Frame',
      debugShowCheckedModeBanner: false,
      theme: getTheme(),
      home: AndroidPermissionsScreen(
        onAllPermissionsGranted: () {},
        child: MainScreen(),
      ),
    );
  }
}
