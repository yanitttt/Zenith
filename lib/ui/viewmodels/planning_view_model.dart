import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../services/planning_service.dart';

class PlanningViewModel extends ChangeNotifier {
  final AppDb db;
  late final PlanningService _service;

  // State
  DateTime _selectedDate = DateTime.now();
  DateTime _startOfWeek = DateTime.now();
  List<PlanningItem> _sessionsDuJour = [];
  Set<int> _joursAvecActivite = {};
  bool _isLoading = true;
  int? _currentUserId;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;
  DateTime get startOfWeek => _startOfWeek;
  List<PlanningItem> get sessionsDuJour => _sessionsDuJour;
  Set<int> get joursAvecActivite => _joursAvecActivite;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _sessionsDuJour.isNotEmpty;

  PlanningViewModel(this.db) {
    _service = PlanningService(db);
    // Start week on Monday
    final now = DateTime.now();
    _startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _startOfWeek = DateTime(
      _startOfWeek.year,
      _startOfWeek.month,
      _startOfWeek.day,
    );
  }

  /// Get User ID & Load Data
  Future<void> init() async {
    try {
      final user = await db.select(db.appUser).getSingleOrNull();
      if (user != null) {
        _currentUserId = user.id;
      } else {
        _currentUserId = 1; // Fallback par défaut comme dans l'original
      }
      await loadData();
    } catch (e) {
      _setError("Erreur init: $e");
    }
  }

  /// Load weekly & daily data (Parallel fetch)
  Future<void> loadData() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel fetching for performance
      final results = await Future.wait([
        _service.getDaysWithActivity(_currentUserId!, _startOfWeek),
        _service.getSessionsForDate(_currentUserId!, _selectedDate),
      ]);

      _joursAvecActivite = results[0] as Set<int>;
      _sessionsDuJour = results[1] as List<PlanningItem>;

      // Sync load month data (could be fire-and-forget if optimized)
      await loadMonthData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError("Erreur chargement: $e");
    }
  }

  /// Change de semaine de N semaines (offset)
  void changeWeek(int offset) {
    _startOfWeek = _startOfWeek.add(Duration(days: 7 * offset));
    // Keep week synced without changing selected date unless needed
    loadData();
  }

  /// Change de mois de N mois (offset)
  void changeMonth(int offset) {
    // Move to 1st of target month
    final newDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + offset,
      1,
    );
    selectDate(newDate, updateWeek: true);
  }

  /// Sélectionne un jour précis (depuis la liste ou le calendrier)
  void selectDate(DateTime date, {bool updateWeek = false}) {
    _selectedDate = date;

    if (updateWeek) {
      // Sync week view if date picked from calendar
      _startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      _startOfWeek = DateTime(
        _startOfWeek.year,
        _startOfWeek.month,
        _startOfWeek.day,
      );
    }

    loadData();
  }

  /// Ajoute une séance libre
  Future<void> addSession(int duration, String name) async {
    if (_currentUserId == null) return;

    try {
      final ts =
          DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          ).millisecondsSinceEpoch ~/
          1000;

      await db
          .into(db.session)
          .insert(
            SessionCompanion.insert(
              userId: _currentUserId!,
              programDayId: const drift.Value(null),
              dateTs: ts,
              durationMin: drift.Value(duration),
              name: drift.Value(name),
            ),
          );

      await loadData();
    } catch (e) {
      // Error handling delegated to UI callbacks or global handler
      print("Erreur ajout session: $e");
    }
  }

  /// Modifie une séance existante
  Future<void> updateSession(int sessionId, int duration, String name) async {
    try {
      await (db.update(db.session)..where((t) => t.id.equals(sessionId))).write(
        SessionCompanion(
          durationMin: drift.Value(duration),
          name: drift.Value(name),
        ),
      );
      await loadData();
    } catch (e) {
      print("Erreur modification session: $e");
    }
  }

  /// Supprime une séance
  Future<void> deleteSession(int sessionId) async {
    try {
      await (db.delete(db.session)..where((t) => t.id.equals(sessionId))).go();
      await loadData();
    } catch (e) {
      print("Erreur suppression session: $e");
    }
  }

  // --- Month Logic ---
  Set<int> _daysWithActivityMonth = {};
  Set<int> get daysWithActivityMonth => _daysWithActivityMonth;

  List<PlanningItem> _sessionsDuMois = [];
  List<PlanningItem> get sessionsDuMois => _sessionsDuMois;

  Future<void> loadMonthData() async {
    if (_currentUserId == null) return;

    // Full month range
    final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));

    try {
      final results = await Future.wait([
        _service.getDaysWithActivityForRange(_currentUserId!, start, end),
        _service.getSessionsForRange(_currentUserId!, start, end),
      ]);

      _daysWithActivityMonth = results[0] as Set<int>;
      _sessionsDuMois = results[1] as List<PlanningItem>;

      notifyListeners();
    } catch (e) {
      print("Erreur loadMonthData: $e");
    }
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    notifyListeners();
    print(msg);
  }
}
