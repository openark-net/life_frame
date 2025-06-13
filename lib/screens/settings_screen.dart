import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:life_frame/widgets/life_frame_logo.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            LifeFrameLogo(),

            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoListSection.insetGrouped(
                children: [
                  Obx(
                    () => CupertinoListTile(
                      title: const Text('Daily Notifications'),
                      trailing: CupertinoSwitch(
                        value: settingsController.notificationsEnabled,
                        onChanged: (bool value) {
                          settingsController.setNotificationsEnabled(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
