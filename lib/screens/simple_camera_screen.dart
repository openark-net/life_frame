import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _backPhotoPath;
  String? _frontPhotoPath;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  String _statusMessage = 'Position your shot';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No cameras available');
        return;
      }

      await _setupCamera(isBack: true);
    } catch (e) {
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _setupCamera({required bool isBack}) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    final camera = _cameras!.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (isBack ? CameraLensDirection.back : CameraLensDirection.front),
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          _isFrontCamera = !isBack;
          _statusMessage = _isFrontCamera
              ? 'Now take your selfie'
              : 'Position your shot';
        });
      }
    } catch (e) {
      _showError('Camera initialization failed');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await HapticFeedback.lightImpact();

      final XFile photo = await _controller!.takePicture();
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = _isFrontCamera
          ? 'front_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'back_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(tempDir.path, fileName);

      await photo.saveTo(filePath);

      if (_isFrontCamera) {
        _frontPhotoPath = filePath;
        _completeCapture();
      } else {
        _backPhotoPath = filePath;
        await _switchToFrontCamera();
      }
    } catch (e) {
      _showError('Failed to capture photo');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _switchToFrontCamera() async {
    await _controller?.dispose();
    await _setupCamera(isBack: false);
    setState(() => _isProcessing = false);
  }

  void _completeCapture() {
    if (_backPhotoPath != null && _frontPhotoPath != null) {
      Navigator.of(
        context,
      ).pop({'backPhoto': _backPhotoPath!, 'frontPhoto': _frontPhotoPath!});
    }
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            ClipRect(
              child: Transform.scale(
                scale:
                    _controller!.value.aspectRatio /
                    mediaQuery.size.aspectRatio,
                child: Center(child: CameraPreview(_controller!)),
              ),
            )
          else
            const Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: CupertinoColors.white,
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _capturePhoto,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessing
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.white,
                        border: Border.all(
                          color: CupertinoColors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? const CupertinoActivityIndicator()
                          : Icon(
                              CupertinoIcons.camera_fill,
                              color: CupertinoColors.black,
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_backPhotoPath != null && !_isFrontCamera)
            Positioned(
              bottom: 40,
              left: 20,
              child: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(File(_backPhotoPath!), fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
