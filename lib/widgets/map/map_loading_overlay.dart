import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/map_controller.dart';

class MapLoadingOverlay extends StatelessWidget {
  final MapController controller;

  const MapLoadingOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoading.value && !controller.isLoadingMoreEntries.value) {
        return const SizedBox.shrink();
      }

      return Container(
        color: CupertinoColors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(),
                const SizedBox(height: 12),
                Text(
                  _getLoadingText(),
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
                if (controller.displayedEntries.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${controller.displayedEntries.length} photos loaded',
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.secondaryLabel.resolveFrom(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getLoadingText() {
    if (controller.isLoading.value) {
      return 'Loading map...';
    } else if (controller.isLoadingMoreEntries.value) {
      return 'Loading more photos...';
    }
    return 'Loading...';
  }
}