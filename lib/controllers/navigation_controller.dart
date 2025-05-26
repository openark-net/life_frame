import 'dart:async';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxBool _isDebugModeVisible = false.obs;
  Timer? _longPressTimer;

  bool get isDebugModeVisible => _isDebugModeVisible.value;

  void startLongPressTimer() {
    _cancelLongPressTimer();
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      _isDebugModeVisible.value = true;
    });
  }

  void cancelLongPressTimer() {
    _cancelLongPressTimer();
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void hideDebugMode() {
    _isDebugModeVisible.value = false;
  }

  void showDebugMode() {
    _isDebugModeVisible.value = true;
  }

  void toggleDebugMode() {
    _isDebugModeVisible.value = !_isDebugModeVisible.value;
  }

  @override
  void onClose() {
    _cancelLongPressTimer();
    super.onClose();
  }
}
