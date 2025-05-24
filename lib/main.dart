import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'services/storage_service.dart';
import 'controllers/photo_journal_controller.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() async {
    final service = StorageService();
    await service.onInit();
    return service;
  });
  Get.put(PhotoJournalController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetCupertinoApp(
      title: 'Life Frame',
      theme: CupertinoThemeData(
        brightness: MediaQuery.platformBrightnessOf(context),
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: const MainScreen(),
    );
  }
}

