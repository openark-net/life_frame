import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:life_frame/theme.dart';
import 'package:life_frame/widgets/life_frame_logo.dart';
import '../controllers/settings_controller.dart';
import '../openark_theme.dart';
import '../services/notification_service.dart';
import '../widgets/permissions_checker.dart';
import 'about_screen.dart';

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
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          CupertinoIcons.bell_fill,
                          color: CupertinoColors.white,
                          size: 16,
                        ),
                      ),
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
                  CupertinoListTile(
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: OpenArkColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.app,
                        color: CupertinoColors.white,
                        size: 16,
                      ),
                    ),
                    title: const Text('About OpenArk'),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      color: OpenArkColors.primary,
                      size: 16,
                    ),
                    onTap: () {
                      Get.to(() => const SupportDeveloperScreen());
                    },
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
