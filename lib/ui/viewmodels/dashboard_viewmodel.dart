import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardService _dashboardService;
  final UserRepository _userRepo;

  // State
  String _userName = "...";
  bool _isLoading = true;
  String _todayDate = "";
  DashboardData? _data;
  
  StreamSubscription<DashboardData>? _subscription;

  // Getters
  String get userName => _userName;
  bool get isLoading => _isLoading;
  String get todayDate => _todayDate;
  DashboardData? get data => _data;

  // Computed Properties (View Logic)
  
  String get totalTimeFormatted {
    final h = _data?.totalHeures ?? 0.0;
    int hours = h.floor();
    int minutes = ((h - hours) * 60).round();
    return "$hours h ${minutes.toString().padLeft(2, '0')} min";
  }

  String get streakText => "${_data?.streakWeeks ?? 0} sem.";
  
  String get totalSessionsText => "${_data?.totalSeances ?? 0}";
  
  String get focusMuscleName => (_data?.muscleStats.isNotEmpty ?? false) 
      ? _data!.muscleStats.first.muscleName 
      : "--";

  bool get hasWeeklyData => _data?.weeklyAttendance.isNotEmpty ?? false;
  Map<String, int> get weeklyData => _data?.weeklyAttendance ?? {};
  
  bool get hasMuscleData => _data?.muscleStats.isNotEmpty ?? false;
  List<MuscleStat> get muscleStats => _data?.muscleStats ?? [];

  DashboardViewModel(AppDb db)
      : _dashboardService = DashboardService(db),
        _userRepo = UserRepository(db) {
    _init();
  }

  Future<void> _init() async {
    // 1. Initialize Date
    await initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = 'fr_FR';
    final now = DateTime.now();
    final formatter = DateFormat('d MMM', 'fr_FR');
    _todayDate = formatter.format(now);
    
    // 2. Load User & Subscribe
    try {
      final user = await _userRepo.current();
      _userName = user?.prenom?.trim() ?? "Athlète";
      final userId = user?.id;

      if (userId != null) {
        // Subscribe to stream
        _subscription = _dashboardService.watchDashboardData(userId).listen((newData) {
          _data = newData;
          _isLoading = false;
          notifyListeners();
        }, onError: (e) {
          debugPrint('[DASHBOARD VM] Error stream: $e');
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DASHBOARD VM] Error init: $e');
      _userName = "Athlète";
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
