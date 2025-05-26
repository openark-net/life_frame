import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'controllers/photo_journal_controller.dart';
import 'controllers/navigation_controller.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() async {
    final service = StorageService();
    await service.onInit();
    return service;
  });
  Get.put(PhotoJournalController());
  Get.put(NavigationController());
  await Get.putAsync(() async {
    final notificationService = NotificationService();
    await notificationService.onInit();
    return notificationService;
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'Life Frame',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: MediaQuery.platformBrightnessOf(context),
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: const RootScreen(),
    );
  }
}
