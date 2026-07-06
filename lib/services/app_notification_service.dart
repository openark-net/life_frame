import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';

import '../widgets/common/notification_banner.dart';

export '../widgets/common/notification_banner.dart' show NotificationPosition;

class AppNotificationService {
  static const Duration _defaultDisplayDuration = Duration(seconds: 3);

  final Talker _talker = Get.find<Talker>();

  OverlayEntry? _activeEntry;

  void showSuccess(
    String title,
    String message, {
    NotificationPosition position = NotificationPosition.top,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: CupertinoColors.systemGreen,
      position: position,
    );
  }

  void showError(
    String title,
    String message, {
    NotificationPosition position = NotificationPosition.top,
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: CupertinoColors.systemRed,
      position: position,
    );
  }

  void show({
    required String title,
    required String message,
    Color backgroundColor = CupertinoColors.darkBackgroundGray,
    NotificationPosition position = NotificationPosition.top,
    Duration displayDuration = _defaultDisplayDuration,
  }) {
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) {
      _talker.warning(
        'Notification dropped, root overlay unavailable: $title - $message',
      );
      return;
    }

    _dismissActive();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => NotificationBanner(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        position: position,
        displayDuration: displayDuration,
        onDismissed: () => _remove(entry),
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
    _talker.debug('Notification shown: $title');
  }

  void _dismissActive() {
    final entry = _activeEntry;
    if (entry != null) {
      _remove(entry);
    }
  }

  void _remove(OverlayEntry entry) {
    if (!identical(_activeEntry, entry)) return;
    _activeEntry = null;
    entry.remove();
    entry.dispose();
  }
}
