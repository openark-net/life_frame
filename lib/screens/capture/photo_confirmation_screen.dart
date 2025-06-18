import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:talker/talker.dart';

import '../../widgets/capture/confirm/action_buttons.dart';
import '../../widgets/capture/confirm/image_preview.dart';

enum PhotoConfirmationResult { retake, keep, updateLocation }

class PhotoConfirmationScreen extends StatefulWidget {
  final ui.Image photo;

  const PhotoConfirmationScreen({super.key, required this.photo});

  @override
  State<PhotoConfirmationScreen> createState() =>
      _PhotoConfirmationScreenState();
}

class _PhotoConfirmationScreenState extends State<PhotoConfirmationScreen> {
  late Talker _talker;

  @override
  void initState() {
    super.initState();
    _talker = Get.find<Talker>();
  }

  void _onKeepPhoto() {
    _talker.info("User chose to keep photo");
    Navigator.of(context).pop(PhotoConfirmationResult.keep);
  }

  void _onRetakePhoto() {
    _talker.info("User chose to retake photo");
    Navigator.of(context).pop(PhotoConfirmationResult.retake);
  }

  void _onUpdateLocation() {
    _talker.info("User chose to update location");
    Navigator.of(context).pop(PhotoConfirmationResult.updateLocation);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            PhotoPreviewWidget(photo: widget.photo),
            PhotoActionButtons(
              onUpdateLocation: _onUpdateLocation,
              onRetakePhoto: _onRetakePhoto,
              onKeepPhoto: _onKeepPhoto,
            ),
          ],
        ),
      ),
    );
  }
}
