import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../models/settings.dart';

class SettingsController extends GetxController {
  static const String _settingsKey = 'app_settings';

  final Rx<Settings> _settings = const Settings().obs;
  late final Talker _talker;

  Settings get settings => _settings.value;
  bool get notificationsEnabled => _settings.value.notificationsEnabled;

  @override
  void onInit() {
    super.onInit();
    _talker = Get.find<Talker>();
    _talker.info('SettingsController initialized');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _talker.debug('Loading settings from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings.value = Settings.fromJson(settingsMap);
        _talker.info('Settings loaded successfully');
      } else {
        _talker.info('No saved settings found, using defaults');
      }
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to load settings, using defaults');
      _settings.value = const Settings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      _talker.debug('Saving settings to SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.value.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      _talker.info('Settings saved successfully');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to save settings');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _talker.info('Setting notifications enabled: $enabled');
      _settings.value = _settings.value.copyWith(notificationsEnabled: enabled);
      await _saveSettings();
      _talker.info('Notifications setting updated successfully');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to update notifications setting');
    }
  }
}
