import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/db/app_db.dart';
import '../../services/planning_service.dart';
import '../../services/performance_monitor_service.dart';

class PlanningViewModel extends ChangeNotifier {
  final AppDb db;
  late final PlanningService _service;
  final PerformanceMonitorService _perfService = PerformanceMonitorService();

  // State
  DateTime _selectedDate = DateTime.now();
  DateTime _startOfWeek = DateTime.now();
  int? _currentUserId;

  List<PlanningItem> _sessionsDuJour = [];
  Set<int> _joursAvecActivite = {};
  bool _isLoading = true;
  String? _error;

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get startOfWeek => _startOfWeek;
  List<PlanningItem> get sessionsDuJour => _sessionsDuJour;
  Set<int> get joursAvecActivite => _joursAvecActivite;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlanningViewModel(this.db) {
    _service = PlanningService(db);
    _init();
  }

  void _init() {
    final now = DateTime.now();
    _startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _startOfWeek = DateTime(
      _startOfWeek.year,
      _startOfWeek.month,
      _startOfWeek.day,
    );
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    _perfService.startMetric('planning_init');
    try {
      final user = await (db.select(db.appUser)..limit(1)).getSingleOrNull();
      if (user != null) {
        _currentUserId = user.id;
      } else {
        // Create default user if none exists to avoid FK violations
        final id = await db
            .into(db.appUser)
            .insert(
              AppUserCompanion.insert(
                nom: const drift.Value("User"),
                singleton: const drift.Value(1),
              ),
            );
        _currentUserId = id;
      }
      await loadData();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    } finally {
      _perfService.stopMetric('planning_init');
    }
  }

  Future<void> loadData() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _perfService.startMetric('planning_load_data');

    try {
      final activites = await _service.getDaysWithActivity(
        _currentUserId!,
        _startOfWeek,
      );
      final sessions = await _service.getSessionsForDate(
        _currentUserId!,
        _selectedDate,
      );

      _joursAvecActivite = activites;
      _sessionsDuJour = sessions;
    } catch (e) {
      _error = e.toString();
      debugPrint("PV: Error loading data: $e");
    } finally {
      _isLoading = false;
      _perfService.stopMetric('planning_load_data');
      notifyListeners();
    }
  }

  void changeWeek(int offset) {
    _startOfWeek = _startOfWeek.add(Duration(days: 7 * offset));
    notifyListeners();
    loadData();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    // Update start of week if selected date is in another week?
    // Usually standard behavior is just selecting that date.
    // If the date is far, we might want to center the week around it, but usually the calendar picker does that.
    // For now, let's just select the date.

    // Check if we need to update startOfWeek to match the selected date's week
    final startOfSelectedWeek = date.subtract(Duration(days: date.weekday - 1));
    final cleanStart = DateTime(
      startOfSelectedWeek.year,
      startOfSelectedWeek.month,
      startOfSelectedWeek.day,
    );

    if (cleanStart != _startOfWeek) {
      _startOfWeek = cleanStart;
    }

    notifyListeners();
    loadData();
  }

  Future<void> addFreeSession(int duration, String name) async {
    if (_currentUserId == null) return;

    _perfService.startMetric('planning_add_session');

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
      _error = e.toString();
      notifyListeners();
    } finally {
      _perfService.stopMetric('planning_add_session');
    }
  }

  Future<void> updateFreeSession(
    int sessionId,
    int duration,
    String name,
  ) async {
    _perfService.startMetric('planning_update_session');

    try {
      await (db.update(db.session)..where((t) => t.id.equals(sessionId))).write(
        SessionCompanion(
          durationMin: drift.Value(duration),
          name: drift.Value(name),
        ),
      );
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _perfService.stopMetric('planning_update_session');
    }
  }

  Future<void> deleteSession(int sessionId) async {
    _perfService.startMetric('planning_delete_session');

    try {
      await (db.delete(db.session)..where((t) => t.id.equals(sessionId))).go();
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _perfService.stopMetric('planning_delete_session');
    }
  }

  void showPerformanceReport() {
    // Just triggers a save of the report
    _perfService.saveReport('planning_performance');
  }
}
