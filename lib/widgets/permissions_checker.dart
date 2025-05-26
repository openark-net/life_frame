import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AndroidPermissionsScreen extends StatefulWidget {
  final VoidCallback? onAllPermissionsGranted;
  final Widget? child;

  const AndroidPermissionsScreen({
    super.key,
    this.onAllPermissionsGranted,
    this.child,
  });

  @override
  State<AndroidPermissionsScreen> createState() =>
      _AndroidPermissionsScreenState();
}

class _AndroidPermissionsScreenState extends State<AndroidPermissionsScreen> {
  final Map<PermissionType, PermissionStatus> _permissionStatuses = {};
  bool _isChecking = true;
  bool _allPermissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    // If on iOS, skip permission checking and continue immediately
    if (Platform.isIOS) {
      setState(() {
        _allPermissionsGranted = true;
        _isChecking = false;
      });
      widget.onAllPermissionsGranted?.call();
      return;
    }

    // Only check permissions on Android
    await _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isChecking = true);

    final statuses = await _getPermissionStatuses();

    setState(() {
      _permissionStatuses.clear();
      _permissionStatuses.addAll(statuses);
      _allPermissionsGranted = _areAllPermissionsGranted();
      _isChecking = false;
    });

    if (_allPermissionsGranted) {
      widget.onAllPermissionsGranted?.call();
    }
  }

  Future<Map<PermissionType, PermissionStatus>> _getPermissionStatuses() async {
    final statuses = <PermissionType, PermissionStatus>{};

    statuses[PermissionType.location] = await _checkLocationPermission();
    statuses[PermissionType.camera] = await Permission.camera.status;
    statuses[PermissionType.storage] = await _checkStoragePermission();
    statuses[PermissionType.notifications] =
        await _checkNotificationPermission();

    return statuses;
  }

  Future<PermissionStatus> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      final serviceStatus = await Permission.location.serviceStatus;
      if (!serviceStatus.isEnabled) {
        return PermissionStatus.restricted;
      }
    }
    return status;
  }

  Future<PermissionStatus> _checkStoragePermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt >= 33) {
      return await Permission.photos.status;
    } else if (deviceInfo.version.sdkInt >= 30) {
      return await Permission.manageExternalStorage.status;
    } else {
      return await Permission.storage.status;
    }
  }

  Future<PermissionStatus> _checkNotificationPermission() async {
    final androidImplementation = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted =
        await androidImplementation?.areNotificationsEnabled() ?? false;
    return granted ? PermissionStatus.granted : PermissionStatus.denied;
  }

  bool _areAllPermissionsGranted() {
    return _permissionStatuses.values.every(
      (status) =>
          status == PermissionStatus.granted ||
          status == PermissionStatus.limited,
    );
  }

  Future<void> _requestPermission(PermissionType type) async {
    PermissionStatus status;

    switch (type) {
      case PermissionType.location:
        status = await Permission.location.request();
        break;
      case PermissionType.camera:
        status = await Permission.camera.request();
        break;
      case PermissionType.storage:
        status = await _requestStoragePermission();
        break;
      case PermissionType.notifications:
        status = await _requestNotificationPermission();
        break;
    }

    await _checkAllPermissions();
  }

  Future<PermissionStatus> _requestStoragePermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt >= 33) {
      return await Permission.photos.request();
    } else if (deviceInfo.version.sdkInt >= 30) {
      return await Permission.manageExternalStorage.request();
    } else {
      return await Permission.storage.request();
    }
  }

  Future<PermissionStatus> _requestNotificationPermission() async {
    final androidImplementation = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted =
        await androidImplementation?.requestNotificationsPermission() ?? false;
    return granted ? PermissionStatus.granted : PermissionStatus.denied;
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_allPermissionsGranted && widget.child != null) {
      return widget.child!;
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Permissions Required'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPermissionsList(),
                    const SizedBox(height: 24),
                    if (!_allPermissionsGranted) _buildSettingsButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsList() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: PermissionType.values.map((type) {
          final status = _permissionStatuses[type] ?? PermissionStatus.denied;
          final isLast = type == PermissionType.values.last;

          return Column(
            children: [
              _PermissionTile(
                type: type,
                status: status,
                onRequest: () => _requestPermission(type),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return CupertinoButton.filled(
      child: const Text('Open Settings'),
      onPressed: () => openAppSettings(),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final PermissionType type;
  final PermissionStatus status;
  final VoidCallback onRequest;

  const _PermissionTile({
    required this.type,
    required this.status,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted =
        status == PermissionStatus.granted ||
        status == PermissionStatus.limited;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isGranted ? null : onRequest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _getIcon(),
              color: isGranted
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(),
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDescription(),
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusIndicator(context),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case PermissionType.location:
        return CupertinoIcons.location_fill;
      case PermissionType.camera:
        return CupertinoIcons.camera_fill;
      case PermissionType.storage:
        return CupertinoIcons.photo_fill;
      case PermissionType.notifications:
        return CupertinoIcons.bell_fill;
    }
  }

  String _getTitle() {
    switch (type) {
      case PermissionType.location:
        return 'Location';
      case PermissionType.camera:
        return 'Camera';
      case PermissionType.storage:
        return 'Photo Library';
      case PermissionType.notifications:
        return 'Notifications';
    }
  }

  String _getDescription() {
    switch (type) {
      case PermissionType.location:
        return 'Add location to your daily photos';
      case PermissionType.camera:
        return 'Capture your daily moments';
      case PermissionType.storage:
        return 'Save and view your photos';
      case PermissionType.notifications:
        return 'Get daily photo reminders';
    }
  }

  Widget _buildStatusIndicator(BuildContext context) {
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return const Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: CupertinoColors.systemGreen,
        size: 22,
      );
    }

    if (status == PermissionStatus.permanentlyDenied) {
      return Icon(
        CupertinoIcons.xmark_circle_fill,
        color: CupertinoColors.systemRed,
        size: 22,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Enable',
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum PermissionType { location, camera, storage, notifications }
