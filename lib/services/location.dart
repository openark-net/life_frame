import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:talker/talker.dart';

class LocationService extends GetxService {
  Position? _cachedPosition;
  DateTime? _lastLocationUpdate;
  Timer? _backgroundLocationTimer;
  Talker? _talker;

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
    _talker ??= Get.find<Talker>();
    await _initializeLocationService();
  }

  @override
  void onClose() {
    _backgroundLocationTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeLocationService() async {
    _talker!.info('Initializing location service');
    await _requestLocationPermissions();
    await _fetchLocationInBackground();
    _startBackgroundLocationUpdates();
    _talker!.info('Location service initialized');
  }

  Future<bool> _requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        _talker!.info('Requesting location permission');
        permission = await Geolocator.requestPermission();
      }

      final granted =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      _talker!.info('Location permission result', {
        'permission': permission.toString(),
        'granted': granted,
      });

      return granted;
    } catch (e, stackTrace) {
      _talker!.handle(e, stackTrace, 'Error requesting location permissions');
      return false;
    }
  }

  Future<void> _fetchLocationInBackground() async {
    try {
      final hasPermission = await _requestLocationPermissions();
      if (!hasPermission) {
        _talker!.warning('Location permission denied, skipping fetch');
        return;
      }

      _cachedPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        ),
      );

      _lastLocationUpdate = DateTime.now();
      _talker!.info('Location cached successfully', {
        'latitude': _cachedPosition?.latitude,
        'longitude': _cachedPosition?.longitude,
        'accuracy': _cachedPosition?.accuracy,
      });
    } catch (e, stackTrace) {
      _talker!.handle(e, stackTrace, 'Error fetching location in background');
    }
  }

  void _startBackgroundLocationUpdates() {
    _backgroundLocationTimer = Timer.periodic(_locationUpdateInterval, (_) {
      _fetchLocationInBackground();
    });
  }

  Future<Position?> getCurrentLocationWithFallback() async {
    if (hasValidCachedLocation) {
      _talker!.info('Using valid cached location');
      return _cachedPosition;
    }

    _talker!.info('Cached location invalid, fetching fresh location');
    try {
      await _fetchLocationInBackground();
      return _cachedPosition;
    } catch (e, stackTrace) {
      _talker!.handle(e, stackTrace, 'Fallback location fetch failed');
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
