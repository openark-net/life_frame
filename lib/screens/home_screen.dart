import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:life_frame/theme.dart';
import '../controllers/photo_journal_controller.dart';
import '../controllers/navigation_controller.dart';
import '../services/daily_photo_capture_service.dart';
import '../widgets/home/photo_status_indicator.dart';
import '../widgets/home/day_streak_widget.dart';
import '../widgets/life_frame_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTakingPicture = false;

  PhotoStatus _getPhotoStatus(PhotoJournalController controller) {
    if (_isTakingPicture) {
      return PhotoStatus.loading;
    }
    return controller.hasTodayPhoto
        ? PhotoStatus.photoTaken
        : PhotoStatus.noPhoto;
  }

  Future<void> _handleTakePicture(BuildContext context) async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final dailyPhotoCaptureService = DailyPhotoCaptureService();
      await dailyPhotoCaptureService.captureDailyPhoto(context);
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();
    final navController = Get.find<NavigationController>();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 20.0,
              ),
              child: Obx(() {
                final photoStatus = _getPhotoStatus(controller);
                final isActionDisabled = _isTakingPicture;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LifeFrameLogo(
                      onDoubleTap: () => navController.toggleDebugMode(),
                    ),

                    const SizedBox(height: 60),

                    PhotoStatusIndicator(status: photoStatus),

                    const SizedBox(height: 40),

                    DayStreakWidget(streakCount: controller.getStreak()),

                    const SizedBox(height: 60),

                    CupertinoButton.filled(
                      onPressed: isActionDisabled
                          ? null
                          : () => _handleTakePicture(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      child: Text(
                        !controller.hasTodayPhoto
                            ? 'Take Your Daily Picture'
                            : 'Take ANOTHER Photo',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.yellowContrast,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
