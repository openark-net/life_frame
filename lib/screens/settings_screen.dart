import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_frame/theme.dart';
import 'package:life_frame/widgets/life_frame_logo.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_option.dart';
import '../openark_theme.dart';
import '../services/notification_service.dart';
import '../widgets/background/AbstractBackground.dart';
import '../widgets/settings/settings_list.dart';
import 'settings/about_screen.dart';
import 'settings/submit_a_bug.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final notifications = Get.find<NotificationService>();

    final List<SettingsOption> settingsOptions = [
      SettingsOption(
        title: 'Daily Notifications',
        icon: CupertinoIcons.bell_fill,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemRed,
        trailing: Obx(
          () => CupertinoSwitch(
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
      SettingsOption(
        title: 'About OpenArk',
        icon: CupertinoIcons.app,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: OpenArkColors.primary,
        isLink: true,
        onTap: () => Get.to(() => const AboutScreen()),
      ),
      SettingsOption(
        title: 'Submit a Bug',
        icon: CupertinoIcons.ant,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemOrange,
        isLink: true,
        onTap: () => Get.to(() => const SubmitABugScreen()),
      ),
    ];

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: Stack(
        children: [
          const AbstractBackground(density: 0.6, seed: 11103),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                LifeFrameLogo(),
                const SizedBox(height: 60),
                SettingsList(options: settingsOptions),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
