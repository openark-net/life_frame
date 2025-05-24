import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  List<String> _capturedPhotos = [];
  bool _isCapturing = false;

  Future<void> _capturePhoto({required bool isBackCamera}) async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: isBackCamera
            ? CameraDevice.rear
            : CameraDevice.front,
        imageQuality: 85, // Slightly reduce quality to make images less sharp
        maxWidth: 1920,   // Limit resolution
        maxHeight: 1920,
      );

      if (photo != null) {
        setState(() {
          _capturedPhotos.add(photo.path);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _finishCapture() {
    if (_capturedPhotos.length >= 2) {
      Navigator.of(context).pop({
        'backPhoto': _capturedPhotos[0],
        'frontPhoto': _capturedPhotos[1],
      });
    } else if (_capturedPhotos.length == 1) {
      Navigator.of(context).pop({
        'backPhoto': _capturedPhotos[0],
        'frontPhoto': _capturedPhotos[0], // Use same photo for both
      });
    }
  }

  void _retakePhoto(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Take Photos'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: _capturedPhotos.length >= 2
            ? CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _finishCapture,
          child: const Text('Done'),
        )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getInstructionText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Photo previews and capture buttons
              Expanded(
                child: Column(
                  children: [
                    // Back photo section
                    _buildPhotoSection(
                      title: 'Back Camera Photo',
                      photoIndex: 0,
                      onCapture: () => _capturePhoto(isBackCamera: true),
                      isBackCamera: true,
                    ),

                    const SizedBox(height: 30),

                    // Front photo section
                    _buildPhotoSection(
                      title: 'Front Camera Photo (Selfie)',
                      photoIndex: 1,
                      onCapture: () => _capturePhoto(isBackCamera: false),
                      isBackCamera: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection({
    required String title,
    required int photoIndex,
    required VoidCallback onCapture,
    required bool isBackCamera,
  }) {
    final bool hasPhoto = _capturedPhotos.length > photoIndex;
    final bool canCapture = photoIndex == 0 || _capturedPhotos.isNotEmpty;

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
              child: hasPhoto
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_capturedPhotos[photoIndex]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : Container(
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
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CupertinoButton.filled(
                    onPressed: (canCapture && !_isCapturing) ? onCapture : null,
                    child: _isCapturing
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Text(hasPhoto ? 'Retake' : 'Take Photo'),
                  ),
                ),
                if (hasPhoto) ...[
                  const SizedBox(width: 8),
                  CupertinoButton(
                    onPressed: () => _retakePhoto(photoIndex),
                    child: const Icon(CupertinoIcons.delete),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructionText() {
    if (_capturedPhotos.isEmpty) {
      return 'First, take a photo with the back camera';
    } else if (_capturedPhotos.length == 1) {
      return 'Now take a selfie with the front camera';
    } else {
      return 'Both photos captured! Tap Done to finish';
    }
  }
}