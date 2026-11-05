import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String _keyPinEnabled = 'pin_enabled';
  static const String _keyPinCode = 'pin_code';
  static const String _keyBiometrics = 'biometrics_enabled';
  static const String _keyAutoLockDuration = 'autolock_duration_sec';
  static const String _keyMaxChars = 'max_journal_chars';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyDarkMode = 'dark_mode';

  final SharedPreferences _prefs;

  PreferenceHelper(this._prefs);

  static Future<PreferenceHelper> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceHelper(prefs);
  }

  bool get isPinEnabled => _prefs.getBool(_keyPinEnabled) ?? false;
  Future<void> setPinEnabled(bool value) => _prefs.setBool(_keyPinEnabled, value);

  String? get pinCode => _prefs.getString(_keyPinCode);
  Future<void> setPinCode(String pin) => _prefs.setString(_keyPinCode, pin);
  Future<void> removePin() => _prefs.remove(_keyPinCode);

  bool get isBiometricsEnabled => _prefs.getBool(_keyBiometrics) ?? false;
  Future<void> setBiometricsEnabled(bool value) => _prefs.setBool(_keyBiometrics, value);

  int get autoLockDurationSeconds => _prefs.getInt(_keyAutoLockDuration) ?? 60; // default 1 min
  Future<void> setAutoLockDurationSeconds(int seconds) =>
      _prefs.setInt(_keyAutoLockDuration, seconds);

  int get maxJournalChars => _prefs.getInt(_keyMaxChars) ?? 280;
  Future<void> setMaxJournalChars(int chars) => _prefs.setInt(_keyMaxChars, chars);

  bool get isReminderEnabled => _prefs.getBool(_keyReminderEnabled) ?? true;
  Future<void> setReminderEnabled(bool value) =>
      _prefs.setBool(_keyReminderEnabled, value);

  int get reminderHour => _prefs.getInt(_keyReminderHour) ?? 21; // 9:00 PM
  int get reminderMinute => _prefs.getInt(_keyReminderMinute) ?? 0;
  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(_keyReminderHour, hour);
    await _prefs.setInt(_keyReminderMinute, minute);
  }

  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? true; // Dark default for modern Gen-Z aesthetic
  Future<void> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);
}

