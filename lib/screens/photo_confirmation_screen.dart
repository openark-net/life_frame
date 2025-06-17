import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:talker/talker.dart';

class PhotoConfirmationScreen extends StatefulWidget {
  final ui.Image photo;

  const PhotoConfirmationScreen({super.key, required this.photo});

  @override
  State<PhotoConfirmationScreen> createState() =>
      _PhotoConfirmationScreenState();
}

class _PhotoConfirmationScreenState extends State<PhotoConfirmationScreen> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  late Talker talker;

  @override
  void initState() {
    super.initState();
    _convertImageToBytes();
    talker = Get.find<Talker>();
  }

  Future<void> _convertImageToBytes() async {
    try {
      final byteData = await widget.photo.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        setState(() {
          _imageBytes = byteData.buffer.asUint8List();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onKeepPhoto() {
    talker.info("Chose to keep photo");
    Navigator.of(context).pop(true);
  }

  void _onRetakePhoto() {
    talker.info("Chose to retake photo");
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : _imageBytes != null
                    ? Container(
                        margin: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: CupertinoColors.white,
                        size: 48,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: _onRetakePhoto,
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
                      onPressed: _onKeepPhoto,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
