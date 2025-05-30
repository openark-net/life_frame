import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxBool _isDebugModeVisible = false.obs;

  bool get isDebugModeVisible => _isDebugModeVisible.value;

  void toggleDebugMode() {
    _isDebugModeVisible.value = !_isDebugModeVisible.value;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
