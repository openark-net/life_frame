import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/map_controller.dart';

class MapView extends StatelessWidget {
  final MapController controller;

  const MapView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GoogleMap(
        onMapCreated: controller.onMapCreated,
        initialCameraPosition: controller.defaultCameraPosition,
        markers: Set<Marker>.from(controller.markers),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        minMaxZoomPreference: const MinMaxZoomPreference(2.0, 20.0),
        onCameraMove: (CameraPosition position) {},
        onCameraIdle: () {},
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      );
    });
  }
}
