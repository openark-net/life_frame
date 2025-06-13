import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../services/notification_service.dart';
import '../../services/permissions_service.dart';

class NotificationsDebugScreen extends StatefulWidget {
  const NotificationsDebugScreen({super.key});

  @override
  State<NotificationsDebugScreen> createState() =>
      _NotificationsDebugScreenState();
}

class _NotificationsDebugScreenState extends State<NotificationsDebugScreen> {
  final SettingsController _settingsController = Get.find<SettingsController>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final PermissionsService _permissionsService = Get.find<PermissionsService>();

  bool _settingsEnabled = false;
  bool _permissionsGranted = false;
  bool _isLoading = false;
  bool _testNotificationsRunning = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    try {
      final settingsEnabled = _settingsController.notificationsEnabled;
      final permissionsGranted = await _permissionsService
          .areNotificationsEnabled();

      setState(() {
        _settingsEnabled = settingsEnabled;
        _permissionsGranted = permissionsGranted;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scheduleInstantNotification() async {
    try {
      await _notificationService.showInstantNotification();
      _showAlert('Success', 'Instant notification scheduled');
    } catch (e) {
      _showAlert('Error', 'Failed to schedule notification: $e');
    }
  }

  Future<void> _startTestNotifications() async {
    try {
      await _notificationService.scheduleTestNotifications();
      setState(() => _testNotificationsRunning = true);
      _showAlert('Success', 'Test notifications started (every minute)');
    } catch (e) {
      _showAlert('Error', 'Failed to start test notifications: $e');
    }
  }

  Future<void> _stopTestNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      setState(() => _testNotificationsRunning = false);
      _showAlert('Success', 'Test notifications stopped');
    } catch (e) {
      _showAlert('Error', 'Failed to stop test notifications: $e');
    }
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status
                  ? (color ?? CupertinoColors.systemGreen)
                  : CupertinoColors.systemRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status ? 'Enabled' : 'Disabled',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: color ?? CupertinoColors.systemBlue,
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatusRow('Settings Enabled', _settingsEnabled),
                    _buildStatusRow('System Permissions', _permissionsGranted),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildButton('Refresh Status', _loadStatus),
              const SizedBox(height: 12),

              _buildButton(
                'Send Instant Notification',
                _scheduleInstantNotification,
              ),
              const SizedBox(height: 12),

              _buildButton(
                _testNotificationsRunning
                    ? 'Stop Test Notifications'
                    : 'Start Test Notifications (Every Minute)',
                _testNotificationsRunning
                    ? _stopTestNotifications
                    : _startTestNotifications,
                color: _testNotificationsRunning
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGreen,
              ),

              const SizedBox(height: 24),

              if (_testNotificationsRunning)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CupertinoColors.systemYellow,
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: CupertinoColors.systemYellow,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Test notifications are running every minute. Remember to stop them when done testing.',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
