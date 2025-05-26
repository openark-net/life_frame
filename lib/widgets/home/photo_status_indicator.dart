import 'package:flutter/cupertino.dart';

enum PhotoStatus { loading, noPhoto, photoTaken }

class PhotoStatusIndicator extends StatelessWidget {
  final PhotoStatus status;

  const PhotoStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusIcon(),
        const SizedBox(height: 20),
        _buildStatusText(context),
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case PhotoStatus.loading:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CupertinoColors.systemGrey.withOpacity(0.1),
          ),
          child: const Center(
            child: CupertinoActivityIndicator(
              radius: 24,
              color: CupertinoColors.systemBlue,
            ),
          ),
        );
      case PhotoStatus.noPhoto:
        return const Icon(
          CupertinoIcons.xmark_circle_fill,
          size: 120,
          color: CupertinoColors.systemRed,
        );
      case PhotoStatus.photoTaken:
        return const Icon(
          CupertinoIcons.checkmark_circle_fill,
          size: 120,
          color: CupertinoColors.systemGreen,
        );
    }
  }

  Widget _buildStatusText(BuildContext context) {
    final String text;
    final Color textColor;

    switch (status) {
      case PhotoStatus.loading:
        text = 'Capturing your daily photo...';
        textColor = CupertinoColors.systemBlue;
        break;
      case PhotoStatus.noPhoto:
        text = 'You haven\'t taken your daily photo yet.';
        textColor = CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.lightBackgroundGray
            : CupertinoColors.secondaryLabel;
        break;
      case PhotoStatus.photoTaken:
        text = 'Great job! You\'ve captured your photo for today.';
        textColor = CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.lightBackgroundGray
            : CupertinoColors.secondaryLabel;
        break;
    }

    return Text(
      text,
      style: CupertinoTheme.of(
        context,
      ).textTheme.textStyle.copyWith(fontSize: 18, color: textColor),
      textAlign: TextAlign.center,
    );
  }
}
