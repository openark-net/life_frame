import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:life_frame/theme.dart';
import 'package:life_frame/widgets/life_frame_logo.dart';
import '../controllers/settings_controller.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final notifications = Get.find<NotificationService>();

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
                backgroundColor: AppColors.background,
                children: [
                  Obx(
                    () => CupertinoListTile(
                      title: const Text('Daily Notifications'),
                      trailing: CupertinoSwitch(
                        value: settingsController.notificationsEnabled,
                        onChanged: (bool value) {
                          settingsController.setNotificationsEnabled(value);
                          if (value) {
                            notifications.enableNotifications();
                          } else {
                            notifications.cancelAllNotifications();
                          }
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
