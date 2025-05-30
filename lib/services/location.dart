import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends GetxService {
  Position? _cachedPosition;
  DateTime? _lastLocationUpdate;
  Timer? _backgroundLocationTimer;

  static const Duration _locationUpdateInterval = Duration(minutes: 5);
  static const Duration _locationCacheTimeout = Duration(minutes: 10);

  Position? get cachedPosition => _cachedPosition;
  bool get hasValidCachedLocation =>
      _cachedPosition != null &&
      _lastLocationUpdate != null &&
      DateTime.now().difference(_lastLocationUpdate!) < _locationCacheTimeout;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLocationService();
  }

  @override
  void onClose() {
    _backgroundLocationTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocationService() async {
    await _requestLocationPermissions();
    await _fetchLocationInBackground();
    _startBackgroundLocationUpdates();
  }

  Future<bool> _requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('LocationService: Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _fetchLocationInBackground() async {
    try {
      final hasPermission = await _requestLocationPermissions();
      if (!hasPermission) return;

      _cachedPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        ),
      );

      _lastLocationUpdate = DateTime.now();
      print('LocationService: Location cached successfully');
    } catch (e) {
      print('LocationService: Error fetching location: $e');
    }
  }

  void _startBackgroundLocationUpdates() {
    _backgroundLocationTimer = Timer.periodic(_locationUpdateInterval, (_) {
      _fetchLocationInBackground();
    });
  }

  Future<Position?> getCurrentLocationWithFallback() async {
    if (hasValidCachedLocation) {
      return _cachedPosition;
    }

    try {
      await _fetchLocationInBackground();
      return _cachedPosition;
    } catch (e) {
      print('LocationService: Fallback location fetch failed: $e');
      return _cachedPosition;
    }
  }

  Future<void> refreshLocation() async {
    await _fetchLocationInBackground();
  }

  void onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!hasValidCachedLocation) {
        _fetchLocationInBackground();
      }
    }
  }
}
