import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/map_controller.dart';
import '../widgets/map/map_view.dart';
import '../widgets/map/map_loading_overlay.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.put(MapController());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Map'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => mapController.refreshData(),
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: Stack(
        children: [
          MapView(controller: mapController),
          MapLoadingOverlay(controller: mapController),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildInfoCard(mapController),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(MapController controller) {
    return Obx(() {
      if (controller.displayedEntries.isEmpty && !controller.isLoading.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'No photos found',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        );
      }

      if (controller.displayedEntries.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${controller.displayedEntries.length} photos',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
