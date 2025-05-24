import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../services/daily_photo_capture_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();
    final dailyPhotoCaptureService = DailyPhotoCaptureService();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
              child: Obx(() {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Life Frame logo
                    Text(
                      'Life Frame',
                      style: TextStyle(
                        fontFamily: 'PeaceSans',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 60),

                    // Photo status indicator (large check mark or X)
                    Icon(
                      controller.hasTodayPhoto
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.xmark_circle_fill,
                      size: 120,
                      color: controller.hasTodayPhoto
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemRed,
                    ),

                    const SizedBox(height: 20),

                    // Supporting text below check mark/X
                    Text(
                      controller.hasTodayPhoto
                          ? 'Great job! You\'ve captured your photo for today.'
                          : 'You haven\'t taken your daily photo yet.',
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        fontSize: 18,
                        color: CupertinoColors.secondaryLabel,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Day streak with fire icon background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CupertinoColors.systemOrange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Fire icon background
                          Positioned(
                            child: Icon(
                              CupertinoIcons.flame_fill,
                              size: 80,
                              color: CupertinoColors.systemOrange.withOpacity(0.3),
                            ),
                          ),
                          // Streak counter in front
                          Column(
                            children: [
                              Text(
                                '${controller.getStreak()}',
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .navLargeTitleTextStyle
                                    .copyWith(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.systemOrange,
                                    ),
                              ),
                              Text(
                                'Day Streak',
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.systemOrange,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // CTA button - only show if no photo taken today
                    if (!controller.hasTodayPhoto) ...[
                      CupertinoButton.filled(
                        onPressed: controller.isLoading ? null : () async {
                          await dailyPhotoCaptureService.captureDailyPhoto(context);
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        child: controller.isLoading
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : const Text(
                                'Take Your Daily Picture',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}