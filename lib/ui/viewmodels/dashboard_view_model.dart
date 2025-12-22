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

  // États observables
  bool _isLoading = true;
  String _userName = "...";
  String _todayDate = "";
  Stream<DashboardData>? _dashboardStream;
  String? _errorMessage;

  // Getters
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

  /// Initialisation unique (Date + Chargement données)
  Future<void> _init() async {
    try {
      // 1. Initialiser la locale FR pour les dates
      // On le fait ici pour s'assurer que c'est prêt avant d'afficher
      await initializeDateFormatting('fr_FR', null);
      Intl.defaultLocale = 'fr_FR';

      final now = DateTime.now();
      final formatter = DateFormat('d MMM', 'fr_FR');
      _todayDate = formatter.format(now);

      // 2. Charger les données utilisateur
      await _loadUserData();
    } catch (e) {
      debugPrint('[DASHBOARD_VM] Erreur init: $e');
      _setError("Erreur d'initialisation");
    }
  }

  /// Charge l'utilisateur et initialise le stream de données
  Future<void> _loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepo.current();

      // Mise à jour de l'état
      _userName = user?.prenom?.trim() ?? "Athlète";
      final userId = user?.id;

      if (userId != null) {
        _dashboardStream = _dashboardService.watchDashboardData(userId);
      } else {
        // Optionnel: Gérer le cas sans ID utilisateur (nouveau user ?)
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

  /// Helper pour gérer les erreurs
  void _setError(String msg) {
    _isLoading = false;
    _errorMessage = msg;
    notifyListeners();
  }

  /// Formatte les heures pour l'affichage (ex: 1.5 -> 1 h 30 min)
  /// Méthode utilitaire pure, pourrait être statique ou dans un Utils
  String formatHeures(double h) {
    int hours = h.floor();
    int minutes = ((h - hours) * 60).round();
    return "$hours h ${minutes.toString().padLeft(2, '0')} min";
  }
}
