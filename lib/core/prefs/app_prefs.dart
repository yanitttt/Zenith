import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kOnboarded = 'onboarded';
  static const _kCurrentUserId = 'current_user_id';
  static const _reminderEnabledKey = 'reminder_enabled';
  static const _reminderDaysKey = 'reminder_days';
  final SharedPreferences _sp;
  AppPrefs(this._sp);

  bool get onboarded => _sp.getBool(_kOnboarded) ?? false;
  Future<bool> setOnboarded(bool v) => _sp.setBool(_kOnboarded, v);

  int? get currentUserId => _sp.getInt(_kCurrentUserId);
  Future<bool> setCurrentUserId(int id) => _sp.setInt(_kCurrentUserId, id);
  Future<bool> clearCurrentUserId() => _sp.remove(_kCurrentUserId);

  bool get reminderEnabled =>
    _sp.getBool(_reminderEnabledKey) ?? false;

  int get reminderDays =>
    _sp.getInt(_reminderDaysKey) ?? 5;

  Future<void> setReminderEnabled(bool value) async {
    await _sp.setBool(_reminderEnabledKey, value);
  }

  Future<void> setReminderDays(int days) async {
    await _sp.setInt(_reminderDaysKey, days);
  }
}

