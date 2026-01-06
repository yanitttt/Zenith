import 'package:flutter/foundation.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../../services/program_generator_service.dart';
import '../../services/session_tracking_service.dart';
import '../../services/home_widget_service.dart'; // Added
import '../../services/gamification_service.dart';
import 'package:drift/drift.dart' as drift;

// Enums for Smart Swap feature
enum SwapReason { noEquipment, pain }

enum SwapState { initial, loading, success, error }

class WorkoutProgramViewModel extends ChangeNotifier {
  final AppDb _db;
  final AppPrefs _prefs;
  final HomeWidgetService _homeWidgetService; // Added

  late final ProgramGeneratorService _programService;
  late final SessionTrackingService _sessionService;
  late final UserTrainingDayDao _trainingDayDao;

  // State
  WorkoutProgramData? _currentProgram;
  List<ProgramDaySession> _programDays = [];
  Map<int, SessionData> _completedSessions = {};
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  bool _generating = false;
  String? _error;

  // State for Smart Swap
  SwapState _swapState = SwapState.initial;
  List<ExerciseData> _swapAlternatives = [];
  String? _swapError;
  int? _exerciseToSwapId;

  WorkoutProgramViewModel({
    required AppDb db,
    required AppPrefs prefs,
    required HomeWidgetService homeWidgetService, // Added argument
  }) : _db = db,
       _prefs = prefs,
       _homeWidgetService = homeWidgetService {
    _programService = ProgramGeneratorService(_db);
    _sessionService = SessionTrackingService(_db, GamificationService(_db));
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

  // Getters for Smart Swap
  SwapState get swapState => _swapState;
  List<ExerciseData> get swapAlternatives => _swapAlternatives;
  String? get swapError => _swapError;
  int? get exerciseToSwapId => _exerciseToSwapId;

  void selectDay(int index) {
    if (index >= 0 && index < _programDays.length) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadProgram() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _prefs.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final program = await _programService.getActiveUserProgram(userId);
      if (program == null) {
        _currentProgram = null;
        _programDays = [];
      } else {
        final days = await _programService.getProgramDays(program.id);
        final dayIds = days.map((d) => d.programDayId).toList();
        final completed = await _sessionService.getCompletedSessionsForDays(
          dayIds,
        );

        _currentProgram = program;
        _programDays = days;
        _completedSessions = completed;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateNewProgram({bool startToday = false}) async {
    _generating = true;
    notifyListeners();
    try {
      final userId = _prefs.currentUserId;
      if (userId == null) throw Exception('User not logged in');
      final programId = await _programService.generateUserProgram(
        userId: userId,
        startToday: startToday,
      );
      final program =
          await (_db.select(_db.workoutProgram)
            ..where((tbl) => tbl.id.equals(programId))).getSingle();
      final days = await _programService.getProgramDays(programId);
      _currentProgram = program;
      _programDays = days;

      // Update Widget Logic
      await _homeWidgetService.updateHomeWidget();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _generating = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateProgram() async {
    _generating = true;
    notifyListeners();
    try {
      final userId = _prefs.currentUserId;
      if (userId == null) return;
      await _programService.regenerateUserProgram(userId: userId);
      // Update Widget Logic
      await _homeWidgetService.updateHomeWidget();
    } finally {
      _generating = false;
      await loadProgram();
    }
  }

  Future<bool> checkHasTrainingDays() async {
    final userId = _prefs.currentUserId;
    if (userId == null) return false;
    return (await _trainingDayDao.getDayNumbersForUser(userId)).isNotEmpty;
  }

  Future<List<int>> getUserTrainingDays() async {
    final userId = _prefs.currentUserId;
    if (userId == null) return [];
    return await _trainingDayDao.getDayNumbersForUser(userId);
  }

  Future<void> saveTrainingDays(List<int> days) async {
    final userId = _prefs.currentUserId;
    if (userId == null) return;
    await _trainingDayDao.replace(userId, days);
  }

  Future<void> updateAfterSession() async {
    await loadProgram();
    // Update Widget Logic
    await _homeWidgetService.updateHomeWidget();
  }

  Future<void> getSmartAlternatives({
    required int originalExerciseId,
    required SwapReason reason,
  }) async {
    _exerciseToSwapId = originalExerciseId;
    _swapState = SwapState.loading;
    _swapAlternatives = [];
    notifyListeners();

    try {
      final primaryMuscleGroupQuery =
          _db.select(_db.exerciseMuscle, distinct: true)
            ..where((em) => em.exerciseId.equals(originalExerciseId))
            ..orderBy([
              (em) => drift.OrderingTerm(
                expression: em.weight.abs(),
                mode: drift.OrderingMode.desc,
              ),
            ])
            ..limit(1);
      final primaryMuscle = await primaryMuscleGroupQuery.getSingleOrNull();

      if (primaryMuscle == null) {
        throw Exception("Cannot determine primary muscle for the exercise.");
      }

      final exercisesWithSameMuscle =
          _db.select(_db.exercise).join([
              drift.innerJoin(
                _db.exerciseMuscle,
                _db.exerciseMuscle.exerciseId.equalsExp(_db.exercise.id),
              ),
            ])
            ..where(_db.exerciseMuscle.muscleId.equals(primaryMuscle.muscleId))
            ..where(_db.exercise.id.isNotValue(originalExerciseId));

      switch (reason) {
        case SwapReason.noEquipment:
          final bodyweightExercises = exercisesWithSameMuscle.join([
            drift.leftOuterJoin(
              _db.exerciseEquipment,
              _db.exerciseEquipment.exerciseId.equalsExp(_db.exercise.id),
            ),
          ])..where(_db.exerciseEquipment.equipmentId.isNull());
          _swapAlternatives =
              (await bodyweightExercises.get())
                  .map((row) => row.readTable(_db.exercise))
                  .toList();

          break;
        case SwapReason.pain:
          final originalExercise =
              await (_db.select(_db.exercise)
                ..where((e) => e.id.equals(originalExerciseId))).getSingle();
          exercisesWithSameMuscle.where(
            _db.exercise.type.isNotValue(originalExercise.type),
          );
          _swapAlternatives =
              (await exercisesWithSameMuscle.get())
                  .map((row) => row.readTable(_db.exercise))
                  .toList();
          break;
      }

      _swapAlternatives.shuffle();
      if (_swapAlternatives.length > 2) {
        _swapAlternatives = _swapAlternatives.sublist(0, 2);
      }

      _swapState = SwapState.success;
    } catch (e) {
      _swapState = SwapState.error;
      _swapError = "Failed to find alternatives: $e";
    } finally {
      notifyListeners();
    }
  }

  void applySwap(int dayIndex, ExerciseData newExercise) {
    if (_exerciseToSwapId == null ||
        dayIndex < 0 ||
        dayIndex >= _programDays.length)
      return;

    final day = _programDays[dayIndex];
    final exercises = day.exercises;
    final exerciseIndex = exercises.indexWhere(
      (ex) => ex.exerciseId == _exerciseToSwapId,
    );

    if (exerciseIndex == -1) return;

    final originalProgramExercise = exercises[exerciseIndex];
    final newProgramExercise = ProgramExerciseDetail(
      position: originalProgramExercise.position,
      exerciseId: newExercise.id,
      exerciseName: newExercise.name,
      exerciseType: newExercise.type,
      difficulty: newExercise.difficulty,
      setsSuggestion: originalProgramExercise.setsSuggestion,
      repsSuggestion: originalProgramExercise.repsSuggestion,
      restSuggestionSec: originalProgramExercise.restSuggestionSec,
      modality: originalProgramExercise.modality,
      scheduledDate: originalProgramExercise.scheduledDate,
      previousSetsSuggestion: originalProgramExercise.previousSetsSuggestion,
      previousRepsSuggestion: originalProgramExercise.previousRepsSuggestion,
      previousRestSuggestion: originalProgramExercise.previousRestSuggestion,
    );

    final updatedExercises = List<ProgramExerciseDetail>.from(exercises);
    updatedExercises[exerciseIndex] = newProgramExercise;
    _programDays[dayIndex] = day.copyWith(exercises: updatedExercises);

    resetSwapState();
    notifyListeners();
  }

  void resetSwapState() {
    _swapState = SwapState.initial;
    _swapAlternatives = [];
    _swapError = null;
    _exerciseToSwapId = null;
    notifyListeners();
  }
}

extension on ProgramDaySession {
  ProgramDaySession copyWith({List<ProgramExerciseDetail>? exercises}) {
    return ProgramDaySession(
      programDayId: programDayId,
      dayOrder: dayOrder,
      dayName: dayName,
      exercises: exercises ?? this.exercises,
      scheduledDate: scheduledDate,
    );
  }
}
