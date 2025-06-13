import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

import '../theme.dart';
import '../services/permissions_service.dart';

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
  final PermissionsService _permissionsService = Get.find<PermissionsService>();

  final RxMap<LFPermission, PermissionStatus> _permissionStatuses =
      <LFPermission, PermissionStatus>{}.obs;
  final RxBool _isChecking = true.obs;
  final RxBool _allPermissionsGranted = false.obs;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    if (Platform.isIOS) {
      _allPermissionsGranted.value = true;
      _isChecking.value = false;
      widget.onAllPermissionsGranted?.call();
      return;
    }

    await _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    _isChecking.value = true;

    final statuses = await _permissionsService.getAllPermissionStatuses();

    _permissionStatuses.clear();
    _permissionStatuses.addAll(statuses);
    _allPermissionsGranted.value = _permissionsService.areAllPermissionsGranted(
      statuses,
    );
    _isChecking.value = false;

    if (_allPermissionsGranted.value) {
      widget.onAllPermissionsGranted?.call();
    }
  }

  Future<void> _requestPermission(LFPermission permission) async {
    await _permissionsService.requestPermission(permission);
    await _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isChecking.value) {
        return const Center(child: CupertinoActivityIndicator());
      }

      if (_allPermissionsGranted.value && widget.child != null) {
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
                      if (!_allPermissionsGranted.value) _buildSettingsButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPermissionsList() {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: LFPermission.all.map((permission) {
          return Obx(() {
            final status =
                _permissionStatuses[permission] ?? PermissionStatus.denied;
            return _PermissionTile(
              permission: permission,
              status: status,
              onRequest: () => _requestPermission(permission),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return CupertinoButton.filled(
      child: const Text(
        'Open Settings',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.yellowContrast,
        ),
      ),
      onPressed: () => openAppSettings(),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final LFPermission permission;
  final PermissionStatus status;
  final VoidCallback onRequest;

  const _PermissionTile({
    required this.permission,
    required this.status,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = permission.isGranted(status);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isGranted ? null : onRequest,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              permission.icon,
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
                    permission.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    permission.description,
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
            _buildStatusIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (permission.isGranted(status)) {
      return const Icon(
        CupertinoIcons.check_mark_circled_solid,
        color: CupertinoColors.systemGreen,
        size: 22,
      );
    }

    if (permission.isPermanentlyDenied(status)) {
      return const Icon(
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
