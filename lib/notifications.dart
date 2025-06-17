import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'models/notifications.dart';

const testEveryMinuteNotification = PeriodicNotification(
  id: 1,
  title: 'TEST!',
  body: '📸',
  repeatInterval: RepeatInterval.everyMinute,
);

const dailyNotification = ScheduledNotification(
  id: 0,
  title: 'Time for your daily photo!',
  body: 'Capture a moment from your life today 📸',
  timeOfDay: TimeOfDay(hour: 9, minute: 0),
  matchDateTimeComponents: DateTimeComponents.time,
);

const instantNotification = InstantNotification(
  id: 999, // Use a high ID to avoid conflicts
  title: 'Test Notification',
  body: 'This is a test notification from Life Frame',
);

const notifications = [dailyNotification];
