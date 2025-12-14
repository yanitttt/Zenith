import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/db/app_db.dart';
import '../../services/admin_service.dart';
import '../../core/prefs/app_prefs.dart';
import '../../services/notification_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService;
  final AppPrefs _prefs;
  final AppDb
  db; // Exposed for navigation to edit page if needed, or internal use

  // State
  bool _isLoading = true;
  List<AppUserData> _users = [];
  StreamSubscription<List<AppUserData>>? _subscription;

  // Getters
  bool get isLoading => _isLoading;
  List<AppUserData> get users => _users;
  bool get hasUsers => _users.isNotEmpty;
  AppPrefs get prefs => _prefs;

  AdminViewModel(this.db, this._prefs) : _adminService = AdminService(db) {
    _init();
  }

  void _init() {
    _subscription = _adminService.watchAllUsers().listen(
      (userList) {
        _users = userList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[ADMIN VM] Error watching users: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _adminService.deleteUser(userId);

      await NotificationService().showNotification(
        id: 0,
        title: "Profil Supprimé",
        body: "Le profil a été supprimé avec succès.",
      );

      // We only reset prefs if the deleted user was the current one, ideally.
      // But adhering to strict existing logic:
      await _prefs.setCurrentUserId(-1);
      await _prefs.setOnboarded(false);

      // Navigation is handled by the UI based on success.
    } catch (e) {
      debugPrint('[ADMIN VM] Error deleting user: $e');
      rethrow;
    }
  }

  Future<List<int>> getTrainingDays(int userId) {
    return _adminService.getUserTrainingDays(userId);
  }

  Future<void> updateTrainingDays(int userId, List<int> days) async {
    await _adminService.updateUserTrainingDays(userId, days);
    notifyListeners(); // Force refresh if needed, though stream might not update for this specific change unless we listen to it.
    // Training days are not in the user stream (users list).
    // So UI components validating training days might need a local refresh or future re-fetch.
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
