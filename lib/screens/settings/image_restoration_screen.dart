import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

import '../../services/image_restoration_service.dart';
import '../../widgets/common/content_card.dart';

class ImageRestorationScreen extends StatefulWidget {
  const ImageRestorationScreen({super.key});

  @override
  State<ImageRestorationScreen> createState() => _ImageRestorationScreenState();
}

class _ImageRestorationScreenState extends State<ImageRestorationScreen> {
  final Talker _talker = Get.find<Talker>();
  final ImageRestorationService _restorationService = ImageRestorationService();

  bool _isRestoring = false;
  String? _resultMessage;
  String? _errorMessage;
  String _directoryPath = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDirectoryPath();
  }

  Future<void> _loadDirectoryPath() async {
    try {
      final path = await _restorationService.getLifeFrameDirectoryPath();
      if (mounted) {
        setState(() {
          _directoryPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _directoryPath = 'Pictures/LifeFrame (error loading path)';
        });
      }
    }
  }

  Future<void> _startRestoration() async {
    if (_isRestoring) return;

    setState(() {
      _isRestoring = true;
      _resultMessage = null;
      _errorMessage = null;
    });

    try {
      _talker.info('User initiated image restoration');
      final restoredCount = await _restorationService
          .restoreImagesFromDirectory();

      setState(() {
        _isRestoring = false;
        if (restoredCount > 0) {
          _resultMessage =
              'Successfully restored $restoredCount image${restoredCount == 1 ? '' : 's'}';
        } else {
          _resultMessage = 'No new images found to restore';
        }
      });
    } catch (e, st) {
      _talker.handle(e, st, 'Error during image restoration');
      setState(() {
        _isRestoring = false;
        _errorMessage =
            'An error occurred during restoration. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Restore Images'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              ContentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Restoration',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This tool will scan your ~/Pictures/LifeFrame directory and restore any images that are not currently in your photo timeline.',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            fontSize: 16,
                            color: CupertinoColors.secondaryLabel,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Directory: $_directoryPath',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            fontSize: 14,
                            color: CupertinoColors.tertiaryLabel,
                            fontFamily: 'Courier',
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_isRestoring) ...[
                ContentCard(
                  child: Column(
                    children: [
                      const CupertinoActivityIndicator(radius: 16),
                      const SizedBox(height: 16),
                      Text(
                        'Restoring images...',
                        style: CupertinoTheme.of(context).textTheme.textStyle
                            .copyWith(
                              fontSize: 16,
                              color: CupertinoColors.secondaryLabel,
                            ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                CupertinoButton.filled(
                  onPressed: _startRestoration,
                  child: const Text('Start Image Restoration'),
                ),
              ],

              const SizedBox(height: 24),

              if (_resultMessage != null) ...[
                ContentCard(
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: CupertinoColors.systemGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _resultMessage!,
                          style: CupertinoTheme.of(context).textTheme.textStyle
                              .copyWith(
                                fontSize: 16,
                                color: CupertinoColors.systemGreen,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                ContentCard(
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: CupertinoColors.systemRed,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: CupertinoTheme.of(context).textTheme.textStyle
                              .copyWith(
                                fontSize: 16,
                                color: CupertinoColors.systemRed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              ContentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildStepText(
                      context,
                      '1.',
                      'Scans Pictures/LifeFrame directory for images',
                    ),
                    const SizedBox(height: 8),
                    _buildStepText(
                      context,
                      '2.',
                      'Reads metadata from each image file',
                    ),
                    const SizedBox(height: 8),
                    _buildStepText(
                      context,
                      '3.',
                      'Adds new images to your photo timeline',
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepText(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ),
      ],
    );
  }
}
