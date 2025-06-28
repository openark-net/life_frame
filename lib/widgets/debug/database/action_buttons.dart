import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../../../controllers/daily_entry_controller.dart';
import '../../../models/daily_entry.dart';

class ActionButtons extends StatefulWidget {
  final List<DailyEntry> entries;

  const ActionButtons({super.key, required this.entries});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  final Talker _talker = Get.find<Talker>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Database Entries (${widget.entries.length})',
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle
              .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (widget.entries.isEmpty)
          _buildEmptyState()
        else
          ...widget.entries.map((entry) => _buildEntryCard(entry)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.photo,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 12),
          Text(
            'No entries found',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(DailyEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(entry.photoPath),
          const SizedBox(width: 16),
          Expanded(child: _buildEntryDetails(entry)),
          const SizedBox(width: 16),
          _buildDeleteButton(entry),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String photoPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: File(photoPath).existsSync()
            ? Image.file(
                File(photoPath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageError(),
              )
            : _buildImageError(),
      ),
    );
  }

  Widget _buildImageError() {
    return Icon(
      CupertinoIcons.photo,
      size: 32,
      color: CupertinoColors.systemGrey,
    );
  }

  Widget _buildEntryDetails(DailyEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.timestamp.toIso8601String(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          entry.locationName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.latitude.toStringAsFixed(6)}, ${entry.longitude.toStringAsFixed(6)}',
          style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(DailyEntry entry) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: CupertinoColors.systemRed,
      minSize: 0,
      onPressed: () => _handleDeleteEntry(entry),
      child: const Icon(
        CupertinoIcons.delete,
        size: 18,
        color: CupertinoColors.white,
      ),
    );
  }

  Future<void> _handleDeleteEntry(DailyEntry entry) async {
    final confirmed = await _showDeleteConfirmation(entry);
    if (!confirmed) return;

    try {
      final controller = Get.find<DailyEntryController>();
      final success = await controller.deleteEntryByTimestamp(entry.timestamp);

      if (success) {
        _showSnackbar(
          'Deleted',
          'Entry removed successfully',
          CupertinoColors.systemRed,
        );
      } else {
        _showSnackbar(
          'Error',
          'Failed to delete entry',
          CupertinoColors.systemRed,
        );
      }
    } catch (e, st) {
      _talker.handle(e, st, 'Error deleting entry');
      _showSnackbar(
        'Error',
        'Failed to delete entry',
        CupertinoColors.systemRed,
      );
    }
  }

  Future<bool> _showDeleteConfirmation(DailyEntry entry) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Delete Entry'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to delete this entry?'),
                const SizedBox(height: 12),
                Text(
                  'Timestamp: ${entry.timestamp.toIso8601String()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  'Location: ${entry.locationName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: CupertinoColors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
