import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

enum PermissionType { location, camera, storage, notifications }

class LFPermission {
  final PermissionType type;
  final String title;
  final String description;
  final IconData icon;

  const LFPermission._({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const location = LFPermission._(
    type: PermissionType.location,
    title: 'Location',
    description: 'Add location to your daily photos',
    icon: CupertinoIcons.location_fill,
  );

  static const camera = LFPermission._(
    type: PermissionType.camera,
    title: 'Camera',
    description: 'Capture your daily moments',
    icon: CupertinoIcons.camera_fill,
  );

  static const storage = LFPermission._(
    type: PermissionType.storage,
    title: 'Photo Library',
    description: 'Save and view your photos',
    icon: CupertinoIcons.photo_fill,
  );

  static const notifications = LFPermission._(
    type: PermissionType.notifications,
    title: 'Notifications',
    description: 'Get daily photo reminders',
    icon: CupertinoIcons.bell_fill,
  );

  static const List<LFPermission> all = [
    location,
    camera,
    storage,
    notifications,
  ];

  static LFPermission fromType(PermissionType type) {
    return all.firstWhere((permission) => permission.type == type);
  }

  bool isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  bool isPermanentlyDenied(PermissionStatus status) {
    return status == PermissionStatus.permanentlyDenied;
  }

  bool isDenied(PermissionStatus status) {
    return status == PermissionStatus.denied;
  }
}

class PermissionsService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission granted: $granted');

        await androidPlugin.requestExactAlarmsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
        return granted ?? false;
      }
    }

    return false;
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final settings = await iosPlugin.checkPermissions();
        return settings?.isEnabled ?? false;
      }
    }

    return false;
  }

  Future<Map<LFPermission, PermissionStatus>> getAllPermissionStatuses() async {
    final statuses = <LFPermission, PermissionStatus>{};

    for (final permission in LFPermission.all) {
      statuses[permission] = await getPermissionStatus(permission);
    }

    return statuses;
  }

  Future<PermissionStatus> getPermissionStatus(LFPermission permission) async {
    switch (permission.type) {
      case PermissionType.location:
        return await _getLocationPermissionStatus();
      case PermissionType.camera:
        return await Permission.camera.status;
      case PermissionType.storage:
        return await _getStoragePermissionStatus();
      case PermissionType.notifications:
        return await _getNotificationPermissionStatus();
    }
  }

  Future<PermissionStatus> _getLocationPermissionStatus() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      final serviceStatus = await Permission.location.serviceStatus;
      if (!serviceStatus.isEnabled) {
        return PermissionStatus.restricted;
      }
    }
    return status;
  }

  Future<PermissionStatus> _getStoragePermissionStatus() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        return await Permission.photos.status;
      } else if (deviceInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.status;
      } else {
        return await Permission.storage.status;
      }
    } else {
      return await Permission.photos.status;
    }
  }

  Future<PermissionStatus> _getNotificationPermissionStatus() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted =
          await androidImplementation?.areNotificationsEnabled() ?? false;
      return granted ? PermissionStatus.granted : PermissionStatus.denied;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final settings = await iosPlugin.checkPermissions();
        return (settings?.isEnabled ?? false)
            ? PermissionStatus.granted
            : PermissionStatus.denied;
      }
    }
    return PermissionStatus.denied;
  }

  Future<PermissionStatus> requestPermission(LFPermission permission) async {
    switch (permission.type) {
      case PermissionType.location:
        return await Permission.location.request();
      case PermissionType.camera:
        return await Permission.camera.request();
      case PermissionType.storage:
        return await _requestStoragePermission();
      case PermissionType.notifications:
        final granted = await requestNotificationPermissions();
        return granted ? PermissionStatus.granted : PermissionStatus.denied;
    }
  }

  Future<PermissionStatus> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        return await Permission.photos.request();
      } else if (deviceInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.request();
      } else {
        return await Permission.storage.request();
      }
    } else {
      return await Permission.photos.request();
    }
  }

  bool areAllPermissionsGranted(Map<LFPermission, PermissionStatus> statuses) {
    return statuses.entries.every((entry) => entry.key.isGranted(entry.value));
  }

  Future<bool> checkAndRequestAllPermissions() async {
    if (Platform.isIOS) {
      return true;
    }

    final statuses = await getAllPermissionStatuses();

    if (areAllPermissionsGranted(statuses)) {
      return true;
    }

    for (final permission in LFPermission.all) {
      final status = statuses[permission];
      if (status != null && !permission.isGranted(status)) {
        await requestPermission(permission);
      }
    }

    final updatedStatuses = await getAllPermissionStatuses();
    return areAllPermissionsGranted(updatedStatuses);
  }
}
