import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsController extends GetxController {
  static const String _settingsKey = 'app_settings';

  final Rx<Settings> _settings = const Settings().obs;

  Settings get settings => _settings.value;
  bool get notificationsEnabled => _settings.value.notificationsEnabled;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings.value = Settings.fromJson(settingsMap);
      }
    } catch (e) {
      _settings.value = const Settings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.value.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings.value = _settings.value.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }
}
