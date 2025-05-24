// File: ./lib/widgets/camera_widget.dart
import 'package:flutter/cupertino.dart';
import 'dart:io';

class CameraWidget extends StatelessWidget {
  final String title;
  final String? photoPath;
  final bool isBackCamera;
  final bool canCapture;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback? onDelete;

  const CameraWidget({
    super.key,
    required this.title,
    this.photoPath,
    required this.isBackCamera,
    required this.canCapture,
    required this.isCapturing,
    required this.onCapture,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photoPath != null;

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasPhoto
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey4,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _buildPhotoPreview(hasPhoto),
            ),

            const SizedBox(height: 16),

            _buildActionButtons(hasPhoto),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(bool hasPhoto) {
    if (hasPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(photoPath!),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isBackCamera
            ? CupertinoIcons.camera
            : CupertinoIcons.camera_on_rectangle,
        size: 60,
        color: CupertinoColors.systemGrey2,
      ),
    );
  }

  Widget _buildActionButtons(bool hasPhoto) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton.filled(
            onPressed: (canCapture && !isCapturing) ? onCapture : null,
            child: isCapturing
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : Text(hasPhoto ? 'Retake' : 'Take Photo'),
          ),
        ),
        if (hasPhoto && onDelete != null) ...[
          const SizedBox(width: 8),
          CupertinoButton(
            onPressed: onDelete,
            child: const Icon(CupertinoIcons.delete),
          ),
        ],
      ],
    );
  }
}