import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../services/planning_service.dart';

class PlanningViewModel extends ChangeNotifier {
  final AppDb db;
  late final PlanningService _service;

  // État
  DateTime _selectedDate = DateTime.now();
  DateTime _startOfWeek = DateTime.now();
  List<PlanningItem> _sessionsDuJour = [];
  Set<int> _joursAvecActivite = {};
  bool _isLoading = true;
  int? _currentUserId;
  String? _errorMessage;

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get startOfWeek => _startOfWeek;
  List<PlanningItem> get sessionsDuJour => _sessionsDuJour;
  Set<int> get joursAvecActivite => _joursAvecActivite;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _sessionsDuJour.isNotEmpty;

  PlanningViewModel(this.db) {
    _service = PlanningService(db);
    // Initialisation de startOfWeek (Lundi de la semaine actuelle ou jour même si on veut simplifier,
    // mais ici on garde la logique existante : 7 jours glissants ou calés sur semaine ?)
    // Logique originale : startOfWeek = now minus weekday-1 (donc Lundi)
    final now = DateTime.now();
    _startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _startOfWeek = DateTime(
      _startOfWeek.year,
      _startOfWeek.month,
      _startOfWeek.day,
    );
  }

  /// Initialise les données (récupère user ID puis charge le planning)
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

  /// Charge les données pour la semaine et le jour sélectionné
  /// Optimisation : Appels parallèles via Future.wait
  Future<void> loadData() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lancement en parallèle pour gain de perf
      final results = await Future.wait([
        _service.getDaysWithActivity(_currentUserId!, _startOfWeek),
        _service.getSessionsForDate(_currentUserId!, _selectedDate),
      ]);

      _joursAvecActivite = results[0] as Set<int>;
      _sessionsDuJour = results[1] as List<PlanningItem>;

      // On charge aussi les données du mois en parallèle "fire and forget" ou await
      // Pour l'instant on await pour être sûr de l'UI
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
    // On ne re-sélectionne pas forcément la date, mais on garde la semaine synchronisée
    loadData();
  }

  /// Change de mois de N mois (offset)
  void changeMonth(int offset) {
    // On se déplace au 1er jour du mois cible
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
      // Si on vient du calendrier, on met aussi à jour la semaine affichée
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

      // Recharger pour mettre à jour l'UI
      await loadData();
    } catch (e) {
      // On log ou on notifie l'UI via un état d'erreur temporaire si besoin,
      // mais ici on laisse l'UI gérer le SnackBar de succès/erreur via callback si souhaité
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

    // On prend du 1er au dernier jour du mois de _selectedDate
    final start = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    final end = nextMonth.subtract(const Duration(seconds: 1));

    try {
      // Fetch parallèle : jours d'activité + liste complète des séances
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
