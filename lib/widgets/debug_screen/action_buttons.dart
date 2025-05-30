import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';
import '../../services/photo_stitching_service.dart';

class ActionButtons extends StatefulWidget {
  final Function(String?) onStitchedPhotoChanged;

  const ActionButtons({super.key, required this.onStitchedPhotoChanged});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Actions:',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 12),

          CupertinoButton.filled(
            onPressed: null,
            child: controller.isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : const Text('Capture Photos'),
          ),

          if (controller.hasTodayPhoto) ...[
            CupertinoButton(
              onPressed: _handleDeleteTodayEntry,
              child: const Text('Delete Today\'s Entry'),
            ),
          ],
        ],
      ),
    );
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
