import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../../models/frame_photos.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _backPhoto;
  XFile? _frontPhoto;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  String _statusMessage = 'Position your shot';
  late Talker talker;

  @override
  void initState() {
    super.initState();
    talker = Get.find<Talker>();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No cameras available');
        talker.error("No cameras available!");
        return;
      }

      await _setupCamera(isBack: true);
    } catch (e, st) {
      talker.handle(e, st, "Failed to initialize camera!");
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
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (mounted) {
        setState(() {
          _isFrontCamera = !isBack;
          _statusMessage = _isFrontCamera
              ? 'Now take your selfie'
              : 'Position your shot';
        });
      }
    } catch (e, st) {
      const err = 'Camera initialization failed';
      talker.handle(e, st, err);
      _showError(err);
    }
  }

  Future<ui.Image> _convertXFileToImage(XFile xFile) async {
    talker.debug("Converting XFile to image");
    final Uint8List bytes = await xFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      allowUpscaling: false, // Prevent any upscaling
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
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

      final XFile image = await _controller!.takePicture();
      if (_isFrontCamera) {
        _frontPhoto = image;
        _completeCapture();
      } else {
        _backPhoto = image;
        await _switchToFrontCamera();
      }
    } catch (e, st) {
      talker.handle(
        e,
        st,
        "Failed to capture photo isFrontCamera=$_isFrontCamera",
      );
      _showError('Failed to capture photo');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _switchToFrontCamera() async {
    await _controller?.dispose();
    await _setupCamera(isBack: false);
    setState(() => _isProcessing = false);
    talker.debug("Switched to front camera");
  }

  void _completeCapture() {
    if (_backPhoto != null && _frontPhoto != null) {
      final framePhotos = FramePhotos(front: _frontPhoto!, back: _backPhoto!);
      talker.info("Completed capture of both photos!");
      Navigator.of(context).pop(framePhotos);
    } else {
      talker.warning(
        "Tried to complete capture without both photos! _backPhoto=$_backPhoto, _frontPhoto=$_frontPhoto",
      );
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

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 20,
          color: CupertinoColors.white,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        var scale = size.aspectRatio * _controller!.value.aspectRatio;

        if (scale < 1) {
          scale = 1 / scale;
        }

        Widget cameraPreview = ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(_controller!)),
          ),
        );

        if (_shouldMirrorPreview) {
          cameraPreview = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: cameraPreview,
          );
        }

        return cameraPreview;
      },
    );
  }

  Widget _buildPhotoThumbnail(XFile xFile) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(File(xFile.path), fit: BoxFit.cover),
      ),
    );
  }

  bool get _shouldMirrorPreview => _isFrontCamera && Platform.isAndroid;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
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
                          : const Icon(
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
          if (_backPhoto != null && !_isFrontCamera)
            Positioned(
              bottom: 40,
              left: 20,
              child: _buildPhotoThumbnail(_backPhoto!),
            ),
        ],
      ),
    );
  }
}
