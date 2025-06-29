import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:life_frame/notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:talker/talker.dart';
import '../controllers/settings_controller.dart';
import '../models/notifications.dart';
import 'permissions_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  PermissionsService? _permissionsService;
  SettingsController? _settingsController;
  Talker? _talker;
  bool _initializationFailure = false;

  static const String channelId = 'life_frame_daily';
  static const String channelName = 'Daily Photo Reminder';
  static const String channelDescription =
      'Reminds you to take your daily photo';

  Talker get talker => _talker!;

  @override
  Future<NotificationService> onInit() async {
    super.onInit();
    _talker ??= Get.find<Talker>();
    _permissionsService ??= Get.find<PermissionsService>();
    _settingsController ??= Get.find<SettingsController>();

    try {
      talker.info('Initializing notification service');
      await _initializeNotifications();
      await _initializeTimezone();
      await _permissionsService!.requestNotificationPermissions();

      if (await _shouldDoNotifications()) {
        await registerNotifications(notifications);
      } else {
        talker.info(
          'Notifications disabled or not permitted, skipping registration',
        );
      }
    } catch (e, st) {
      _initializationFailure = true;
      talker.handle(e, st, 'Failed to initialize notification service');
    }

    return this;
  }

  Future<void> _initializeNotifications() async {
    try {
      await _tryInitializeWithIcon('@drawable/ic_notification');
      talker.debug('Notifications initialized with custom icon');
    } catch (e, st) {
      talker.warning('Failed to initialize with custom icon, trying app icon');
      talker.handle(e, st, 'Custom icon initialization failed');

      try {
        await _tryInitializeWithIcon('@mipmap/ic_launcher');
        talker.debug('Notifications initialized with app icon fallback');
      } catch (fallbackError, fallbackSt) {
        talker.handle(
          fallbackError,
          fallbackSt,
          'Both custom and app icon initialization failed',
        );
        rethrow;
      }
    }
  }

  Future<void> _tryInitializeWithIcon(String iconPath) async {
    final androidSettings = AndroidInitializationSettings(iconPath);

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
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
    talker.debug('Timezone initialized: $timeZoneName');
  }

  Future<bool> _shouldDoNotifications() async {
    if (_initializationFailure) {
      talker.warning('Notifications unavailable due to initialization failure');
      return false;
    }

    if (!_settingsController!.notificationsEnabled) {
      talker.debug('Notifications disabled in settings');
      return false;
    }

    final areEnabled = await _permissionsService!.areNotificationsEnabled();
    if (!areEnabled) {
      talker.warning('Notification permissions not granted');
    }
    return areEnabled;
  }

  Future<void> registerNotifications(List<LFNotification> notifications) async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot register notifications due to initialization failure',
      );
      return;
    }

    talker.info('Registering ${notifications.length} notifications');
    await cancelAllNotifications();

    for (final notification in notifications) {
      try {
        if (notification is ScheduledNotification) {
          await _scheduleNotification(notification);
        } else if (notification is PeriodicNotification) {
          await _schedulePeriodicNotification(notification);
        } else {
          talker.warning(
            'Unsupported notification type in registerNotifications: ${notification.runtimeType}',
          );
        }
      } catch (e, stackTrace) {
        talker.error(
          'Failed to register notification ${notification.id}',
          e,
          stackTrace,
        );
      }
    }
  }

  Future<void> showInstantNotification(InstantNotification notification) async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot show instant notification due to initialization failure',
      );
      return;
    }

    talker.info('Showing instant notification: ${notification.title}');

    try {
      final details = _createNotificationDetails();
      await _notifications.show(
        notification.id,
        notification.title,
        notification.body,
        details,
        payload: notification.payload,
      );
      talker.debug('Instant notification shown successfully');
    } catch (e, stackTrace) {
      talker.error('Failed to show instant notification', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _scheduleNotification(ScheduledNotification notification) async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot schedule notification due to initialization failure',
      );
      return;
    }

    final details = _createNotificationDetails();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      notification.timeOfDay.hour,
      notification.timeOfDay.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: notification.matchDateTimeComponents,
      payload: notification.payload,
    );

    talker.debug(
      'Scheduled inexact notification ${notification.id} for approximately ${scheduledDate}',
    );
  }

  Future<void> _schedulePeriodicNotification(
    PeriodicNotification notification,
  ) async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot schedule periodic notification due to initialization failure',
      );
      return;
    }

    final details = _createNotificationDetails();

    await _notifications.periodicallyShow(
      notification.id,
      notification.title,
      notification.body,
      notification.repeatInterval,
      details,
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: notification.payload,
    );

    talker.debug(
      'Scheduled inexact periodic notification ${notification.id} with interval ${notification.repeatInterval}',
    );
  }

  NotificationDetails _createNotificationDetails() {
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

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot cancel notifications due to initialization failure',
      );
      return;
    }

    talker.info('Cancelling all notifications');
    await _notifications.cancelAll();
  }

  Future<void> enableNotifications() async {
    if (_initializationFailure) {
      talker.warning(
        'Cannot enable notifications due to initialization failure',
      );
      return;
    }

    talker.info('Enabling notifications');
    await registerNotifications(notifications);
  }

  void _handleNotificationTap(NotificationResponse response) {
    talker.info(
      'Notification tapped - ID: ${response.id}, Payload: ${response.payload}',
    );
    // Navigate to camera screen when notification is tapped
  }

  bool get isInitialized => !_initializationFailure;
}
