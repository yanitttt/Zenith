import 'package:flutter/foundation.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../../services/program_generator_service.dart';
import '../../services/session_tracking_service.dart';
import '../../services/home_widget_service.dart'; 
import '../../services/gamification_service.dart';
import 'package:drift/drift.dart' as drift;

// Enums pour la fonctionnalité Smart Swap
enum SwapReason { noEquipment, pain }

enum SwapState { initial, loading, success, error }

class WorkoutProgramViewModel extends ChangeNotifier {
  final AppDb _db;
  final AppPrefs _prefs;
  final HomeWidgetService _homeWidgetService; 

  late final ProgramGeneratorService _programService;
  late final SessionTrackingService _sessionService;
  late final UserTrainingDayDao _trainingDayDao;

  // État
  WorkoutProgramData? _currentProgram;
  List<ProgramDaySession> _programDays = [];
  Map<int, SessionData> _completedSessions = {};
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  bool _generating = false;
  String? _error;

  // État pour Smart Swap
  SwapState _swapState = SwapState.initial;
  List<ExerciseData> _swapAlternatives = [];
  String? _swapError;
  int? _exerciseToSwapId;

  WorkoutProgramViewModel({
    required AppDb db,
    required AppPrefs prefs,
    required HomeWidgetService homeWidgetService,
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

  // Getters pour Smart Swap
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
        throw Exception('Utilisateur non connecté');
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
      if (userId == null) throw Exception('Utilisateur non connecté');
      final programId = await _programService.generateUserProgram(
        userId: userId,
        startToday: startToday,
      );
      await loadProgram();
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
      await loadProgram();
      await _homeWidgetService.updateHomeWidget();
    } finally {
      _generating = false;
      notifyListeners();
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
      final originalExercise = await (_db.select(_db.exercise)
            ..where((e) => e.id.equals(originalExerciseId))).getSingle();

      List<String> targetNames = [];
      final nameLower = originalExercise.name.toLowerCase();

      // LOGIQUE DE SUBSTITUTION MANUELLE (Strict 18 Exercises Mapping)
      if (nameLower.contains('back squat')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Squat au poids du corps', 'Fentes'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Presse à cuisses', 'Squat au poids du corps'];
        }
      } else if (nameLower.contains('fentes')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Squat au poids du corps', 'Montées sur chaise'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Presse à cuisses', 'Soulevé de terre'];
        }
      } else if (nameLower.contains('presse à cuisse')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Squat au poids du corps', 'Fentes'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Squat au poids du corps', 'Fentes'];
        }
      } else if (nameLower.contains('squat au poids du corps')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Fentes', 'La Chaise'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Soulevé de terre', 'Gainage planche'];
        }
      } else if (nameLower.contains('soulevé de terre')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Superman', 'Pont fessier au sol'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Presse à cuisses', 'Gainage planche'];
        }
      } else if (nameLower.contains('développé couché')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Pompes', 'Dips sur banc'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Pompes', 'Développé couché haltères prise neutre'];
        }
      } else if (nameLower.contains('dips sur banc')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Pompes', 'Pompes diamant'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Développé couché', 'Pompes sur les genoux'];
        }
      } else if (nameLower.contains('pompe')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Dips sur banc', 'Pompes sur les genoux'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Développé couché', 'Gainage planche'];
        }
      } else if (nameLower.contains('rowing haltère')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Tractions', 'Rowing inversé'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Tirage vertical (Lat Pulldown)', 'Tractions'];
        }
      } else if (nameLower.contains('tirage vertical') || nameLower.contains('lat pulldown')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Tractions', 'Superman'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Rowing haltère', 'Tractions assistées'];
        }
      } else if (nameLower.contains('traction')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Rowing inversé', 'Superman'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Tirage vertical (Lat Pulldown)', 'Rowing haltère'];
        }
      } else if (nameLower.contains('curl biceps')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Tractions', 'Curl avec sac à dos'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Tractions', 'Rowing haltère'];
        }
      } else if (nameLower.contains('corde à sauter')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Jumping Jacks', 'Mountain Climbers'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Course tapis', 'Squat au poids du corps'];
        }
      } else if (nameLower.contains('course tapis')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Mountain Climbers', 'Jumping Jacks'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Marche rapide', 'Gainage planche'];
        }
      } else if (nameLower.contains('jumping jacks')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Mountain Climbers', 'Burpees'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Squat au poids du corps', 'Step touch'];
        }
      } else if (nameLower.contains('mountain climber')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Jumping Jacks', 'Montées de genoux sur place'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Course tapis', 'Corde à sauter'];
        }
      } else if (nameLower.contains('gainage planche')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Superman', 'Mountain Climbers'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Gainage sur les genoux', 'Superman'];
        }
      } else if (nameLower.contains('superman')) {
        if (reason == SwapReason.noEquipment) {
          targetNames = ['Gainage planche', 'Pont fessier'];
        } else if (reason == SwapReason.pain) {
          targetNames = ['Gainage planche', 'Soulevé de terre'];
        }
      }

      if (targetNames.isNotEmpty) {
        final results = await (_db.select(_db.exercise)
              ..where((e) => e.name.isIn(targetNames)))
            .get();

        if (results.isNotEmpty) {
          // Tri pour respecter l'ordre défini
          results.sort((a, b) {
            int indexA = targetNames.indexWhere((name) => a.name.contains(name) || name.contains(a.name));
            int indexB = targetNames.indexWhere((name) => b.name.contains(name) || name.contains(b.name));
            return indexA.compareTo(indexB);
          });
          
          _swapAlternatives = results;
          _swapState = SwapState.success;
          notifyListeners();
          return;
        }
      }

      // FALLBACK : Logique générale par groupe musculaire si le mapping manuel échoue
      final primaryMuscleRow = await (_db.select(_db.exerciseMuscle).join([
        drift.innerJoin(_db.muscle, _db.muscle.id.equalsExp(_db.exerciseMuscle.muscleId)),
      ])..where(_db.exerciseMuscle.exerciseId.equals(originalExerciseId))
        ..orderBy([drift.OrderingTerm.desc(_db.exerciseMuscle.weight)])
        ..limit(1)).getSingleOrNull();

      if (primaryMuscleRow != null) {
        final muscleId = primaryMuscleRow.readTable(_db.exerciseMuscle).muscleId;
        var query = _db.select(_db.exercise).join([
          drift.innerJoin(_db.exerciseMuscle, _db.exerciseMuscle.exerciseId.equalsExp(_db.exercise.id)),
        ])..where(_db.exerciseMuscle.muscleId.equals(muscleId))
          ..where(_db.exercise.id.isNotValue(originalExerciseId));

        if (reason == SwapReason.noEquipment) {
          final equipmentQuery = _db.selectOnly(_db.exerciseEquipment)..addColumns([_db.exerciseEquipment.exerciseId]);
          query.where(_db.exercise.id.isNotInQuery(equipmentQuery));
        }

        final fallbackResults = await query.map((row) => row.readTable(_db.exercise)).get();
        if (fallbackResults.isNotEmpty) {
          fallbackResults.shuffle();
          _swapAlternatives = fallbackResults.take(2).toList();
          _swapState = SwapState.success;
          notifyListeners();
          return;
        }
      }

      _swapState = SwapState.success;
      _swapAlternatives = [];
    } catch (e) {
      _swapState = SwapState.error;
      _swapError = "Erreur lors de la recherche : $e";
    } finally {
      notifyListeners();
    }
  }

  void applySwap(int dayIndex, ExerciseData newExercise) {
    if (_exerciseToSwapId == null ||
        dayIndex < 0 ||
        dayIndex >= _programDays.length) {
      return;
    }

    final day = _programDays[dayIndex];
    final exercises = List<ProgramExerciseDetail>.from(day.exercises);
    final exerciseIndex = exercises.indexWhere(
      (ex) => ex.exerciseId == _exerciseToSwapId,
    );

    if (exerciseIndex == -1) return;

    final old = exercises[exerciseIndex];
    exercises[exerciseIndex] = ProgramExerciseDetail(
      exerciseId: newExercise.id,
      exerciseName: newExercise.name,
      exerciseType: newExercise.type,
      difficulty: newExercise.difficulty,
      position: old.position,
      setsSuggestion: old.setsSuggestion,
      repsSuggestion: old.repsSuggestion,
      restSuggestionSec: old.restSuggestionSec,
      modality: old.modality,
      scheduledDate: old.scheduledDate,
      previousSetsSuggestion: old.previousSetsSuggestion,
      previousRepsSuggestion: old.previousRepsSuggestion,
      previousRestSuggestion: old.previousRestSuggestion,
    );

    _programDays[dayIndex] = day.copyWith(exercises: exercises);

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
