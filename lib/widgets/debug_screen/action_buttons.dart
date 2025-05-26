import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';
import '../../services/photo_stitching_service.dart';
import '../../screens/simple_camera_screen.dart';

class ActionButtons extends StatefulWidget {
  final Function(String?) onStitchedPhotoChanged;

  const ActionButtons({
    super.key,
    required this.onStitchedPhotoChanged,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Actions:',
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        const SizedBox(height: 12),
        
        CupertinoButton.filled(
          onPressed: controller.isLoading ? null : _handleCapturePhotos,
          child: controller.isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : const Text('Capture Photos'),
        ),

        if (controller.hasTodayPhoto) ...[
          const SizedBox(height: 12),
          CupertinoButton.filled(
            onPressed: _handleStitchPhotos,
            child: const Text('Stitch Today\'s Photos'),
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: _handleDeleteTodayEntry,
            child: const Text('Delete Today\'s Entry'),
          ),
        ],
      ],
    ));
  }

  Future<void> _handleCapturePhotos() async {
    final controller = Get.find<PhotoJournalController>();
    
    final result = await Navigator.of(context).push<Map<String, String>>(
      CupertinoPageRoute(
        builder: (context) => const SimpleCameraScreen(),
      ),
    );

    if (result != null &&
        result['backPhoto'] != null &&
        result['frontPhoto'] != null) {
      final success = await controller.savePhotosFromPaths(
        backPhotoPath: result['backPhoto']!,
        frontPhotoPath: result['frontPhoto']!,
      );

      _showSnackbar(
        success ? 'Success' : 'Error',
        success ? 'Photos captured successfully!' : 'Failed to save photos',
        success ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
      );
    }
  }

  Future<void> _handleStitchPhotos() async {
    final controller = Get.find<PhotoJournalController>();
    
    if (controller.todayBackPhoto.isEmpty || controller.todayFrontPhoto.isEmpty) {
      _showSnackbar(
        'Error',
        'Both front and back photos are required for stitching',
        CupertinoColors.systemRed,
      );
      return;
    }

    final stitchingService = PhotoStitchingService();

    final stitchedPath = await stitchingService.stitchPhotos(
      backPhotoPath: controller.todayBackPhoto,
      frontPhotoPath: controller.todayFrontPhoto,
      latitude: controller.todayEntry?.latitude,
      longitude: controller.todayEntry?.longitude,
    );

    if (stitchedPath != null) {
      widget.onStitchedPhotoChanged(stitchedPath);
      await controller.updateTodayEntryWithStitchedPhoto(stitchedPath);
      _showSnackbar(
        'Success',
        'Photos stitched successfully!',
        CupertinoColors.systemGreen,
      );
    } else {
      _showSnackbar(
        'Error',
        'Failed to stitch photos',
        CupertinoColors.systemRed,
      );
    }
  }

  Future<void> _handleDeleteTodayEntry() async {
    final controller = Get.find<PhotoJournalController>();
    
    final success = await controller.deleteTodayEntry();
    if (success) {
      widget.onStitchedPhotoChanged(null);
      _showSnackbar(
        'Deleted',
        'Today\'s photo entry removed',
        CupertinoColors.systemRed,
      );
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: CupertinoColors.white,
    );
  }
}
