// File: ./lib/screens/simple_camera_screen.dart
import 'package:flutter/cupertino.dart';
import '../services/camera_service.dart';
import '../widgets/camera_widget.dart';

class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  final CameraService _cameraService = CameraService();
  final List<String> _capturedPhotos = [];
  bool _isCapturing = false;

  Future<void> _capturePhoto({required bool isBackCamera}) async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final String? photoPath = await _cameraService.capturePhoto(
        isBackCamera: isBackCamera,
      );

      if (photoPath != null) {
        setState(() {
          _capturedPhotos.add(photoPath);
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error taking picture: $e');
      }
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

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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

              // Photo capture sections
              Expanded(
                child: Column(
                  children: [
                    // Back camera section
                    CameraWidget(
                      title: 'Back Camera Photo',
                      photoPath: _capturedPhotos.isNotEmpty
                          ? _capturedPhotos[0]
                          : null,
                      isBackCamera: true,
                      canCapture: true,
                      isCapturing: _isCapturing,
                      onCapture: () => _capturePhoto(isBackCamera: true),
                      onDelete: _capturedPhotos.isNotEmpty
                          ? () => _retakePhoto(0)
                          : null,
                    ),

                    const SizedBox(height: 30),

                    // Front camera section
                    CameraWidget(
                      title: 'Front Camera Photo (Selfie)',
                      photoPath: _capturedPhotos.length > 1
                          ? _capturedPhotos[1]
                          : null,
                      isBackCamera: false,
                      canCapture: _capturedPhotos.isNotEmpty,
                      isCapturing: _isCapturing,
                      onCapture: () => _capturePhoto(isBackCamera: false),
                      onDelete: _capturedPhotos.length > 1
                          ? () => _retakePhoto(1)
                          : null,
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
}
