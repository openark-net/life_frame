import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/photo_journal_controller.dart';
import '../widgets/debug_screen/debug_screen_header.dart';
import '../widgets/debug_screen/today_photo_status_card.dart';
import '../widgets/debug_screen/stats_row.dart';
import '../widgets/debug_screen/action_buttons.dart';
import '../widgets/debug_screen/photo_preview_section.dart';
import '../widgets/debug_screen/stitched_photo_preview.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? stitchedPhotoPath;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Debug Screen'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CupertinoActivityIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DebugScreenHeader(),
                  const SizedBox(height: 20),
                  const TodayPhotoStatusCard(),
                  const SizedBox(height: 20),
                  const StatsRow(),
                  const SizedBox(height: 30),
                  ActionButtons(
                    onStitchedPhotoChanged: (path) {
                      setState(() {
                        stitchedPhotoPath = path;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  const PhotoPreviewSection(),
                  const SizedBox(height: 30),
                  StitchedPhotoPreview(stitchedPhotoPath: stitchedPhotoPath),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
