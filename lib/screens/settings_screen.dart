import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:life_frame/widgets/life_frame_logo.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_option.dart';
import '../openark_theme.dart';
import '../services/notification_service.dart';
import '../widgets/settings/settings_list.dart';
import 'settings/about_screen.dart';
import 'settings/submit_a_bug.dart';
import 'settings/image_restoration_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = Get.find<Talker>();

    try {
      final settingsController = Get.find<SettingsController>();
      final notifications = Get.find<NotificationService>();

      return _buildSettingsContent(
        context,
        settingsController,
        notifications,
        talker,
      );
    } catch (e, st) {
      talker.handle(e, st, 'Error initializing settings dependencies');
      return _buildErrorContent(context, talker);
    }
  }

  Widget _buildSettingsContent(
    BuildContext context,
    SettingsController settingsController,
    NotificationService notifications,
    Talker talker,
  ) {
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
              try {
                talker.info('User toggling notifications: $value');
                settingsController.setNotificationsEnabled(value);
                if (value) {
                  notifications.enableNotifications();
                } else {
                  notifications.cancelAllNotifications();
                }
              } catch (e, st) {
                talker.handle(e, st, 'Error toggling notifications');
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
        onTap: () {
          try {
            talker.info('Navigating to About screen');
            Get.to(() => const AboutScreen());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to About screen');
          }
        },
      ),
      SettingsOption(
        title: 'Submit a Bug',
        icon: CupertinoIcons.ant,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemOrange,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Submit a Bug screen');
            Get.to(() => const SubmitABugScreen());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to Submit a Bug screen');
          }
        },
      ),
      SettingsOption(
        title: 'Restore Images',
        icon: CupertinoIcons.photo_on_rectangle,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemBlue,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Image Restoration screen');
            Get.to(() => const ImageRestorationScreen());
          } catch (e, st) {
            talker.handle(
              e,
              st,
              'Error navigating to Image Restoration screen',
            );
          }
        },
      ),
    ];

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              child: Center(
                child: Text(
                  'Settings',

                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navLargeTitleTextStyle
                      ?.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            LifeFrameLogo(),
            const SizedBox(height: 60),
            SettingsList(options: settingsOptions),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Talker talker) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              child: Center(
                child: Text(
                  'Settings',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navLargeTitleTextStyle
                      ?.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            LifeFrameLogo(),
            const SizedBox(height: 60),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 60,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Settings Unavailable',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'There was an error loading the settings.\nPlease restart the app.',
                      textAlign: TextAlign.center,
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                    ),
                    const SizedBox(height: 30),
                    CupertinoButton(
                      onPressed: () {
                        try {
                          talker.info('User retrying settings load');
                          Get.forceAppUpdate();
                        } catch (e, st) {
                          talker.handle(e, st, 'Error retrying settings load');
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
