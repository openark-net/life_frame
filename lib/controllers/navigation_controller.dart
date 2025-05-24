import 'dart:async';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxBool _isNavBarVisible = false.obs;
  Timer? _longPressTimer;

  bool get isNavBarVisible => _isNavBarVisible.value;

  void startLongPressTimer() {
    _cancelLongPressTimer();
    _longPressTimer = Timer(const Duration(seconds: 3), () {
      _isNavBarVisible.value = true;
    });
  }

  void cancelLongPressTimer() {
    _cancelLongPressTimer();
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void hideNavBar() {
    _isNavBarVisible.value = false;
  }

  void showNavBar() {
    _isNavBarVisible.value = true;
  }

  void toggleNavBar() {
    _isNavBarVisible.value = !_isNavBarVisible.value;
  }

  @override
  void onClose() {
    _cancelLongPressTimer();
    super.onClose();
  }
}