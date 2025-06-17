import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class LFNotification {
  const LFNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String? payload;
}

class ScheduledNotification extends LFNotification {
  const ScheduledNotification({
    required super.id,
    required super.title,
    required super.body,
    required this.timeOfDay,
    super.payload,
    this.matchDateTimeComponents,
  });

  final TimeOfDay timeOfDay;
  final DateTimeComponents? matchDateTimeComponents;
}

class PeriodicNotification extends LFNotification {
  const PeriodicNotification({
    required super.id,
    required super.title,
    required super.body,
    required this.repeatInterval,
    super.payload,
  });

  final RepeatInterval repeatInterval;
}

class InstantNotification extends LFNotification {
  const InstantNotification({
    required super.id,
    required super.title,
    required super.body,
    super.payload,
  });
}
