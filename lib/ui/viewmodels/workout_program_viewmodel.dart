import 'package:flutter/foundation.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../../services/program_generator_service.dart';
import '../../services/session_tracking_service.dart';

class WorkoutProgramViewModel extends ChangeNotifier {
  final AppDb _db;
  final AppPrefs _prefs;

  late final ProgramGeneratorService _programService;
  late final SessionTrackingService _sessionService;
  late final UserTrainingDayDao _trainingDayDao;
  // TODO: PerformanceMonitorService demandé mais introuvable dans le projet.

  // État
  WorkoutProgramData? _currentProgram;
  List<ProgramDaySession> _programDays = [];
  Map<int, SessionData> _completedSessions = {};
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  bool _generating = false;
  String? _error;

  WorkoutProgramViewModel({required AppDb db, required AppPrefs prefs})
    : _db = db,
      _prefs = prefs {
    _programService = ProgramGeneratorService(_db);
    _sessionService = SessionTrackingService(_db);
    _trainingDayDao = UserTrainingDayDao(_db);
  }

  // Getters
  WorkoutProgramData? get currentProgram => _currentProgram;
  List<ProgramDaySession> get programDays => _programDays;
  Map<int, SessionData> get completedSessions => _completedSessions;
  int get selectedDayIndex => _selectedDayIndex;
  bool get isLoading => _isLoading;
  bool get isGenerating => _generating;
  String? get error => _error;
  int? get currentUserId => _prefs.currentUserId;
  AppDb get db => _db;

  // Setter pour la sélection du jour
  void selectDay(int index) {
    if (index >= 0 && index < _programDays.length) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  /// Charge le programme de l'utilisateur
  Future<void> loadProgram() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _prefs.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final program = await _programService.getActiveUserProgram(userId);
      final trainingDays = await _trainingDayDao.getDayNumbersForUser(userId);

      // Cas où un programme existe mais plus de jours d'entraînement définis
      if (program != null && trainingDays.isEmpty) {
        debugPrint(
          '[WORKOUT_VM] Programme détecté sans jours définis -> Suppression pour forcer l\'état vide',
        );
        await (_db.delete(_db.userProgram)
          ..where((tbl) => tbl.userId.equals(userId))).go();

        _currentProgram = null;
        _programDays = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (program == null) {
        _currentProgram = null;
        _programDays = [];
      } else {
        final days = await _programService.getProgramDays(program.id);
        final dayIds = days.map((d) => d.programDayId).toList();
        final completedSessions = await _sessionService
            .getCompletedSessionsForDays(dayIds);

        _currentProgram = program;
        _programDays = days;
        _completedSessions = completedSessions;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[WORKOUT_VM] Erreur: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Génère un nouveau programme pour l'utilisateur
  Future<void> generateNewProgram() async {
    _generating = true;
    notifyListeners();

    try {
      final userId = _prefs.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final programId = await _programService.generateUserProgram(
        userId: userId,
      );

      final program =
          await (_db.select(_db.workoutProgram)
            ..where((tbl) => tbl.id.equals(programId))).getSingle();

      final days = await _programService.getProgramDays(programId);

      _currentProgram = program;
      _programDays = days;
      _generating = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[WORKOUT_VM] Erreur génération: $e');
      _error = e.toString();
      _generating = false;
      _isLoading = false;
      notifyListeners();
      // On propage l'erreur pour que l'UI puisse afficher un SnackBar
      rethrow;
    }
  }

  /// Régénère le programme existant
  Future<void> regenerateProgram() async {
    _generating = true;
    notifyListeners();

    try {
      final userId = _prefs.currentUserId;
      if (userId == null) return;

      await _programService.regenerateUserProgram(userId: userId);
      await loadProgram();
    } catch (e) {
      debugPrint('[WORKOUT_VM] Erreur régénération: $e');
      _generating =
          false; // loadProgram le met déjà à jour mais en cas d'erreur avant loadProgram
      notifyListeners();
      rethrow;
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  /// Vérifie si l'utilisateur a défini des jours d'entraînement
  Future<bool> checkHasTrainingDays() async {
    final userId = _prefs.currentUserId;
    if (userId == null) return false;
    final days = await _trainingDayDao.getDayNumbersForUser(userId);
    return days.isNotEmpty;
  }

  /// Sauvegarde les jours d'entraînement
  Future<void> saveTrainingDays(List<int> days) async {
    final userId = _prefs.currentUserId;
    if (userId == null) return;
    await _trainingDayDao.replace(userId, days);
  }

  /// Met à jour les données après une séance
  Future<void> updateAfterSession() async {
    debugPrint('[WORKOUT_VM] Retour de session, rechargement du programme...');
    await loadProgram();

    // Logique optionnelle pour vérifier le prochain jour (debugging)
    if (_programDays.length > 1) {
      final nextDay = _programDays.firstWhere(
        (d) => !_completedSessions.containsKey(d.programDayId),
        orElse: () => _programDays.last,
      );
      if (nextDay.exercises.isNotEmpty) {
        final firstEx = nextDay.exercises.first;
        debugPrint(
          '[WORKOUT_VM] Vérification jour ${nextDay.dayOrder}: ${firstEx.exerciseName} -> ${firstEx.setsSuggestion} (was ${firstEx.previousSetsSuggestion}) / ${firstEx.repsSuggestion}',
        );
      }
    }
  }
}
