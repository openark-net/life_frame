import 'package:flutter/cupertino.dart';

class PhotoActionButtons extends StatelessWidget {
  final VoidCallback onUpdateLocation;
  final VoidCallback onRetakePhoto;
  final VoidCallback onKeepPhoto;

  const PhotoActionButtons({
    super.key,
    required this.onUpdateLocation,
    required this.onRetakePhoto,
    required this.onKeepPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildLocationUpdateButton(),
          const SizedBox(height: 16),
          _buildDecisionButtons(),
        ],
      ),
    );
  }

  Widget _buildLocationUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: onUpdateLocation,
        color: CupertinoColors.systemGrey,
        borderRadius: BorderRadius.circular(12.0),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location,
              color: CupertinoColors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Update Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionButtons() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            onPressed: onRetakePhoto,
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(12.0),
            child: const Text(
              'Retake',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CupertinoButton(
            onPressed: onKeepPhoto,
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(12.0),
            child: const Text(
              'Keep Photo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
