import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../controllers/navigation_controller.dart';
import '../services/daily_photo_capture_service.dart';
import '../widgets/home/photo_status_indicator.dart';

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
                    GestureDetector(
                      onDoubleTap: () => navController.toggleDebugMode(),
                      child: Text(
                        'Life Frame 📸',
                        style: TextStyle(
                          fontFamily: 'PeaceSans',
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Photo status indicator
                    PhotoStatusIndicator(status: photoStatus),

                    const SizedBox(height: 40),

                    // Day streak with fire icon background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
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
                              color: CupertinoColors.systemOrange.withOpacity(
                                0.3,
                              ),
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
                    if (photoStatus == PhotoStatus.noPhoto) ...[
                      CupertinoButton.filled(
                        onPressed: isActionDisabled
                            ? null
                            : () => _handleTakePicture(context),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        child: const Text(
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
