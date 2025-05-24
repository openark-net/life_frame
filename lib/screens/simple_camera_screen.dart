import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';

class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  List<String> _capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Start with back camera (index 0 is usually back camera)
      _currentCameraIndex = 0;
      
      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
    });

    try {
      await _controller?.dispose();
      
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      
      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      
      setState(() {
        _capturedPhotos.add(photo.path);
        _isCapturing = false;
      });
      
    } catch (e) {
      print('Error taking picture: $e');
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBackCamera = _cameras.isNotEmpty && 
        _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.back;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isBackCamera ? 'Back Camera' : 'Front Camera'),
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
        child: Stack(
          children: [
            if (_isInitialized && _controller != null)
              Positioned.fill(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CupertinoActivityIndicator(),
              ),
            
            // Bottom controls
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch camera button
                  if (_cameras.length > 1)
                    CupertinoButton(
                      onPressed: _switchCamera,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: CupertinoColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.switch_camera,
                          color: CupertinoColors.white,
                          size: 25,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 50),
                  
                  // Capture button
                  GestureDetector(
                    onTap: _isCapturing ? null : _capturePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing ? CupertinoColors.systemGrey : CupertinoColors.white,
                        border: Border.all(
                          color: CupertinoColors.systemGrey2,
                          width: 4,
                        ),
                      ),
                      child: _isCapturing
                          ? const CupertinoActivityIndicator()
                          : const Icon(
                              CupertinoIcons.camera,
                              size: 40,
                              color: CupertinoColors.black,
                            ),
                    ),
                  ),
                  
                  // Photo count
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: CupertinoColors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_capturedPhotos.length}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Instructions
            if (_capturedPhotos.isEmpty)
              const Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Text(
                  'Take your back camera photo first',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              )
            else if (_capturedPhotos.length == 1)
              const Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Text(
                  'Switch to front camera and take your selfie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              )
            else
              const Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Text(
                  'Both photos captured! Tap Done to finish',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: CupertinoColors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}