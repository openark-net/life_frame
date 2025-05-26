import 'dart:io';
import 'package:flutter/cupertino.dart';

class StitchedPhotoPreview extends StatelessWidget {
  final String? stitchedPhotoPath;

  const StitchedPhotoPreview({super.key, required this.stitchedPhotoPath});

  @override
  Widget build(BuildContext context) {
    if (stitchedPhotoPath == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stitched Photo:',
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.separator, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(stitchedPhotoPath!),
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: CupertinoColors.systemGrey6,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 40,
                      color: CupertinoColors.systemGrey3,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
