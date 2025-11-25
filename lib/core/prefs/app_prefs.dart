import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kOnboarded = 'onboarded';
  static const _kCurrentUserId = 'current_user_id';
  final SharedPreferences _sp;
  AppPrefs(this._sp);

  bool get onboarded => _sp.getBool(_kOnboarded) ?? false;
  Future<bool> setOnboarded(bool v) => _sp.setBool(_kOnboarded, v);

  int? get currentUserId => _sp.getInt(_kCurrentUserId);
  Future<bool> setCurrentUserId(int id) => _sp.setInt(_kCurrentUserId, id);
  Future<bool> clearCurrentUserId() => _sp.remove(_kCurrentUserId);
}

