import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/dashboard_service.dart';

/// ViewModel gérant la logique et l'état de la DashboardPage.
class DashboardViewModel extends ChangeNotifier {
  final AppDb _db;
  late final UserRepository _userRepo;
  late final DashboardService _dashboardService;

  // State
  bool _isLoading = true;
  String _userName = "...";
  String _todayDate = "";
  Stream<DashboardData>? _dashboardStream;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get todayDate => _todayDate;
  Stream<DashboardData>? get dashboardStream => _dashboardStream;
  String? get errorMessage => _errorMessage;

  DashboardViewModel(this._db) {
    _userRepo = UserRepository(_db);
    _dashboardService = DashboardService(_db);
    _init();
  }

  /// Init Date & Data
  Future<void> _init() async {
    try {
      // Setup Locale (required before UI build)
      await initializeDateFormatting('fr_FR', null);
      Intl.defaultLocale = 'fr_FR';

      final now = DateTime.now();
      final formatter = DateFormat('d MMM', 'fr_FR');
      _todayDate = formatter.format(now);

      await _loadUserData();
    } catch (e) {
      debugPrint('[DASHBOARD_VM] Erreur init: $e');
      _setError("Erreur d'initialisation");
    }
  }

  /// Load User & Init Stream
  Future<void> _loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepo.current();

      _userName = user?.prenom?.trim() ?? "Athlète";
      final userId = user?.id;

      if (userId != null) {
        _dashboardStream = _dashboardService.watchDashboardData(userId);
      } else {
        // New user or no ID
        _dashboardStream = const Stream.empty();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[DASHBOARD_VM] Erreur loadUserData: $e');
      _userName = "Athlète";
      _setError("Impossible de charger le profil");
    }
  }

  void _setError(String msg) {
    _isLoading = false;
    _errorMessage = msg;
    notifyListeners();
  }

  /// Utils: 1.5 -> 1 h 30 min
  String formatHeures(double h) {
    int hours = h.floor();
    int minutes = ((h - hours) * 60).round();
    return "$hours h ${minutes.toString().padLeft(2, '0')} min";
  }
}
