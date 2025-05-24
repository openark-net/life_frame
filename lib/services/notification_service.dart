import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../controllers/photo_journal_controller.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_photo_reminder';
  static const String _channelName = 'Daily Photo Reminders';
  static const String _channelDescription = 'Reminders to take your daily photo';

  @override
  Future<void> onInit() async {
    super.onInit();
    tz.initializeTimeZones();
    await _initializeNotifications();
    await _scheduleDailyReminder();
  }

  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _scheduleDailyReminder() async {
    await _notifications.cancelAll();

    // Check if exact alarms are available on Android
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    bool canScheduleExactNotifications = true;
    if (androidPlugin != null) {
      try {
        canScheduleExactNotifications = await androidPlugin.canScheduleExactNotifications() ?? false;
      } catch (e) {
        print('Error checking exact alarm permission: $e');
        canScheduleExactNotifications = false;
      }
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default.caf',
        badgeNumber: 1,
      ),
    );

    try {
      if (canScheduleExactNotifications) {
        await _notifications.zonedSchedule(
          0,
          'Daily Photo Reminder',
          'Don\'t forget to capture today\'s moment! 📸',
          _getNext11AM(),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        // Fall back to inexact scheduling
        await _notifications.zonedSchedule(
          0,
          'Daily Photo Reminder',
          'Don\'t forget to capture today\'s moment! 📸',
          _getNext11AM(),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        print('Using inexact notifications - exact alarms not permitted');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      // App can still function without notifications
    }
  }

  static tz.TZDateTime _getNext11AM() {
    final now = tz.TZDateTime.now(tz.local);
    var next11AM = tz.TZDateTime(tz.local, now.year, now.month, now.day, 11, 0);
    
    if (next11AM.isBefore(now)) {
      next11AM = next11AM.add(const Duration(days: 1));
    }
    
    return next11AM;
  }

  static Future<void> _onNotificationTapped(
      NotificationResponse notificationResponse) async {
    // When notification is tapped, navigate to camera screen
    // This will be handled by your app's navigation
  }

  // Method to check if notification should be sent
  static Future<bool> _shouldSendNotification() async {
    final photoController = Get.find<PhotoJournalController>();
    return !photoController.hasTodayPhoto;
  }

  // Method to manually trigger notification check (for testing)
  static Future<void> checkAndSendReminder() async {
    if (await _shouldSendNotification()) {
      await _sendImmediateNotification();
    }
  }

  static Future<void> _sendImmediateNotification() async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default.caf',
        badgeNumber: 1,
      ),
    );

    await _notifications.show(
      1,
      'Daily Photo Reminder',
      'Don\'t forget to capture today\'s moment! 📸',
      notificationDetails,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Reschedule notifications (useful when app is updated)
  static Future<void> rescheduleNotifications() async {
    await _scheduleDailyReminder();
  }
}