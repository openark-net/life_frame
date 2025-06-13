import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../controllers/settings_controller.dart';
import 'permissions_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  late final PermissionsService _permissionsService;
  late final SettingsController _settingsController;

  static const String channelId = 'life_frame_daily';
  static const String channelName = 'Daily Photo Reminder';
  static const String channelDescription =
      'Reminds you to take your daily photo';

  Future<NotificationService> onInit() async {
    super.onInit();
    _permissionsService = Get.find<PermissionsService>();
    _settingsController = Get.find<SettingsController>();

    if (!await _shouldDoNotifications()) {
      return this;
    }

    await _initializeNotifications();
    await _initializeTimezone();
    await _permissionsService.requestNotificationPermissions();
    await _scheduleDailyNotification(
      time: const TimeOfDay(hour: 9, minute: 00),
    );
    return this;
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<bool> _shouldDoNotifications() async {
    if (!_settingsController.notificationsEnabled) {
      return false;
    }
    return await _permissionsService.areNotificationsEnabled();
  }

  Future<void> scheduleTestNotifications() async {
    await _cancelAllNotifications();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.periodicallyShow(
      1,
      'TEST!',
      '📸',
      RepeatInterval.everyMinute,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('Test notifications scheduled - every minute');
  }

  Future<void> _scheduleDailyNotification({required TimeOfDay time}) async {
    await _cancelAllNotifications();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0,
      'Time for your daily photo!',
      'Capture a moment from your life today 📸',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily notification scheduled for ${time.hour}:${time.minute}');
  }

  Future<void> showInstantNotification() async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Test Notification',
      'This is a test notification from Life Frame',
      details,
    );
  }

  Future<void> _cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Navigate to camera screen when notification is tapped
  }

  Future<void> cancelNotifications() async {
    await _cancelAllNotifications();
  }
}
