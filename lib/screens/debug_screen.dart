import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'debug/image_restoration_screen.dart';
import 'debug/database.dart';
import 'debug/exif_debug_screen.dart';
import 'debug/notifications_debug_screen.dart';
import 'debug/talker_debug_screen.dart';
import '../widgets/debug/shapes_showcase.dart';
import '../widgets/life_frame_logo.dart';
import '../models/menu_option.dart';
import '../widgets/menu_list.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = Get.find<Talker>();

    try {
      return _buildDebugContent(context, talker);
    } catch (e, st) {
      talker.handle(e, st, 'Error initializing debug screen');
      return _buildErrorContent(context, talker);
    }
  }

  Widget _buildDebugContent(BuildContext context, Talker talker) {
    final List<MenuOption> debugOptions = [
      MenuOption(
        title: 'Database',
        icon: CupertinoIcons.archivebox,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemBlue,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Photo Debug screen');
            Get.to(() => const PhotoDebugScreen());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to Photo Debug screen');
          }
        },
      ),
      MenuOption(
        title: 'EXIF Data Viewer',
        icon: CupertinoIcons.info_circle_fill,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemGreen,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to EXIF Debug screen');
            Get.to(() => const ExifViewerWidget());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to EXIF Debug screen');
          }
        },
      ),
      MenuOption(
        title: 'Notifications Testing',
        icon: CupertinoIcons.bell_fill,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemOrange,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Notifications Debug screen');
            Get.to(() => const NotificationsDebugScreen());
          } catch (e, st) {
            talker.handle(
              e,
              st,
              'Error navigating to Notifications Debug screen',
            );
          }
        },
      ),
      MenuOption(
        title: 'System Logs',
        icon: CupertinoIcons.text_alignleft,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemRed,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Talker Debug screen');
            Get.to(() => const TalkerDebugScreen());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to Talker Debug screen');
          }
        },
      ),
      MenuOption(
        title: 'UI Components',
        icon: CupertinoIcons.square_on_circle,
        iconColor: CupertinoColors.white,
        iconBackgroundColor: CupertinoColors.systemPurple,
        isLink: true,
        onTap: () {
          try {
            talker.info('Navigating to Shapes Showcase screen');
            Get.to(() => const ShapesShowcase());
          } catch (e, st) {
            talker.handle(e, st, 'Error navigating to Shapes Showcase screen');
          }
        },
      ),
      MenuOption(
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
                  'Debug Tools',
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
            MenuList(options: debugOptions),
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
                  'Debug Tools',
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
                      'Debug Tools Unavailable',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'There was an error loading the debug tools.\nPlease restart the app.',
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
                          talker.info('User retrying debug tools load');
                          Get.forceAppUpdate();
                        } catch (e, st) {
                          talker.handle(
                            e,
                            st,
                            'Error retrying debug tools load',
                          );
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
