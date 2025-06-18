import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class PhotoPreviewWidget extends StatefulWidget {
  final ui.Image photo;

  const PhotoPreviewWidget({super.key, required this.photo});

  @override
  State<PhotoPreviewWidget> createState() => _PhotoPreviewWidgetState();
}

class _PhotoPreviewWidgetState extends State<PhotoPreviewWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  late Talker _talker;

  @override
  void initState() {
    super.initState();
    _talker = Get.find<Talker>();
    _convertImageToBytes();
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
    } catch (e, stackTrace) {
      _talker.handle(
        e,
        stackTrace,
        'Failed to convert image to bytes for preview',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Center(child: _buildPreviewContent()));
  }

  Widget _buildPreviewContent() {
    if (_isLoading) {
      return const CupertinoActivityIndicator(color: CupertinoColors.white);
    }

    if (_imageBytes != null) {
      return _buildImagePreview();
    }

    return _buildErrorState();
  }

  Widget _buildImagePreview() {
    return Container(
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
        child: Image.memory(_imageBytes!, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Icon(
      CupertinoIcons.exclamationmark_triangle,
      color: CupertinoColors.white,
      size: 48,
    );
  }
}
