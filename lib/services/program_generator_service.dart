import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../data/db/app_db.dart';
import '../data/db/daos/user_training_day_dao.dart';
import 'recommendation_service.dart';
import '../core/perf/perf_service.dart';

class ProgramDaySession {
  final int programDayId;
  final int dayOrder;
  final String dayName;
  final List<ProgramExerciseDetail> exercises;
  final DateTime? scheduledDate;

  ProgramDaySession({
    required this.programDayId,
    required this.dayOrder,
    required this.dayName,
    required this.exercises,
    this.scheduledDate,
  });
}

class ProgramExerciseDetail {
  final int exerciseId;
  final String exerciseName;
  final String exerciseType;
  final int difficulty;
  final int position;
  final String? setsSuggestion;
  final String? repsSuggestion;
  final int? restSuggestionSec;
  final TrainingModalityData? modality;
  final DateTime? scheduledDate;

  final String? previousSetsSuggestion;
  final String? previousRepsSuggestion;
  final int? previousRestSuggestion;

  ProgramExerciseDetail({
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseType,
    required this.difficulty,
    required this.position,
    this.setsSuggestion,
    this.repsSuggestion,
    this.restSuggestionSec,
    this.modality,
    this.scheduledDate,
    this.previousSetsSuggestion,
    this.previousRepsSuggestion,
    this.previousRestSuggestion,
  });
}

class ProgramGeneratorService {
  final AppDb db;
  final RecommendationService recommendationService;
  final UserTrainingDayDao trainingDayDao;

  ProgramGeneratorService(this.db)
    : recommendationService = RecommendationService(db),
      trainingDayDao = UserTrainingDayDao(db);

  Future<List<DateTime>> _calculateTrainingDates({
    required int userId,
    required int numberOfDays,
    DateTime? startFromDate,
    bool startToday = false,
  }) async {
    final List<DateTime> scheduledDates = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate =
        startFromDate != null
            ? DateTime(
              startFromDate.year,
              startFromDate.month,
              startFromDate.day,
            )
            : today;

    final userTrainingDays = await trainingDayDao.getDayNumbersForUser(userId);

    if (userTrainingDays.isEmpty) {
      for (int i = 0; i < numberOfDays; i++) {
        scheduledDates.add(startDate.add(Duration(days: (i * 2) + 1)));
      }
      return scheduledDates;
    }

    final sortedDays = List<int>.from(userTrainingDays)..sort();

    DateTime currentDate = startDate;

    // Si on veut commencer aujourd'hui et qu'aujourd'hui est un jour d'entrainement
    if (startToday && sortedDays.contains(currentDate.weekday)) {
      scheduledDates.add(currentDate);
    }

    while (scheduledDates.length < numberOfDays) {
      currentDate = currentDate.add(const Duration(days: 1));

      final currentWeekday = currentDate.weekday;

      if (sortedDays.contains(currentWeekday)) {
        scheduledDates.add(currentDate);
      }
    }

    return scheduledDates;
  }

  Future<int> generateUserProgram({
    required int userId,
    int? objectiveId,
    int? daysPerWeek,
    String? programName,
    bool startToday = false,
  }) async {
    return await PerfService().measure('generate_full_program', () async {
      final user =
          await (db.select(db.appUser)
            ..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();

      if (user == null) {
        throw Exception('Utilisateur non trouvé');
      }

      int targetDaysPerWeek;
      if (daysPerWeek != null) {
        targetDaysPerWeek = daysPerWeek;
      } else {
        final userTrainingDays = await trainingDayDao.getDayNumbersForUser(
          userId,
        );
        if (userTrainingDays.isEmpty) {
          debugPrint(
            '[PROGRAM_GEN] Aucun jour d\'entraînement défini, utilisation de 3 jours par défaut',
          );
          targetDaysPerWeek = 3;
        } else {
          targetDaysPerWeek = userTrainingDays.length;
          debugPrint(
            '[PROGRAM_GEN] $targetDaysPerWeek jours d\'entraînement récupérés depuis UserTrainingDay',
          );
        }
      }

      int targetObjectiveId;
      if (objectiveId != null) {
        targetObjectiveId = objectiveId;
      } else {
        final userGoals =
            await (db.select(db.userGoal)
                  ..where((tbl) => tbl.userId.equals(userId))
                  ..orderBy([(t) => OrderingTerm.desc(t.weight)])
                  ..limit(1))
                .get();

        if (userGoals.isEmpty) {
          throw Exception('Aucun objectif défini pour cet utilisateur');
        }
        targetObjectiveId = userGoals.first.objectiveId;
      }

      final objective =
          await (db.select(db.objective)
            ..where((tbl) => tbl.id.equals(targetObjectiveId))).getSingle();

      final programId = await db
          .into(db.workoutProgram)
          .insert(
            WorkoutProgramCompanion(
              name: Value(programName ?? 'Programme ${objective.name}'),
              description: Value(
                'Programme personnalisé pour ${objective.name.toLowerCase()}',
              ),
              objectiveId: Value(targetObjectiveId),
              level: Value(user.level),
              durationWeeks: const Value(4),
            ),
          );

      await _generateProgramDays(
        programId: programId,
        userId: userId,
        objectiveId: targetObjectiveId,
        userLevel: user.level ?? 'intermediaire',
        daysPerWeek: targetDaysPerWeek,
        startToday: startToday,
      );

      await db
          .into(db.userProgram)
          .insert(
            UserProgramCompanion(
              userId: Value(userId),
              programId: Value(programId),
              startDateTs: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
              isActive: const Value(1),
            ),
          );

      return programId;
    });
  }

  Future<void> _generateProgramDays({
    required int programId,
    required int userId,
    required int objectiveId,
    required String userLevel,
    required int daysPerWeek,
    bool startToday = false,
  }) async {
    final List<Map<String, dynamic>> dayConfigs = _getDayConfigurations(
      daysPerWeek,
    );

    final scheduledDates = await _calculateTrainingDates(
      userId: userId,
      numberOfDays: daysPerWeek,
      startToday: startToday,
    );

    for (int day = 0; day < daysPerWeek; day++) {
      final config = dayConfigs[day];
      final MuscleGroup muscleGroup = config['muscleGroup'];
      final String dayName = config['name'];
      final DateTime scheduledDate = scheduledDates[day];

      var exercises = await recommendationService
          .getRecommendedExercisesByMuscleGroup(
            userId: userId,
            muscleGroup: muscleGroup,
            specificObjectiveId: objectiveId,
            limit: 30,
          );

      if (exercises.length < 10) {
        print(
          '[PROGRAM] Seulement ${exercises.length} exercices pour $dayName, complément avec exercices généraux',
        );
        final generalExercises = await recommendationService
            .getRecommendedExercises(
              userId: userId,
              specificObjectiveId: objectiveId,
              limit: 30,
            );

        final exerciseIds = exercises.map((e) => e.id).toSet();
        final additionalExercises =
            generalExercises.where((e) => !exerciseIds.contains(e.id)).toList();

        exercises = [...exercises, ...additionalExercises];
      }

      if (exercises.isEmpty) {
        throw Exception('Aucun exercice disponible pour générer un programme');
      }

      await _createProgramDay(
        programId: programId,
        dayId: day,
        dayName: dayName,
        exercises: exercises,
        userLevel: userLevel,
        objectiveId: objectiveId,
        scheduledDate: scheduledDate,
      );
    }
  }

  List<Map<String, dynamic>> _getDayConfigurations(int daysPerWeek) {
    switch (daysPerWeek) {
      case 1:
        return [
          {'name': 'Full Body', 'muscleGroup': MuscleGroup.full},
        ];
      case 2:
        return [
          {'name': 'Haut du corps', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps', 'muscleGroup': MuscleGroup.lower},
        ];
      case 3:
        return [
          {'name': 'Haut du corps', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps', 'muscleGroup': MuscleGroup.lower},
          {'name': 'Full Body', 'muscleGroup': MuscleGroup.full},
        ];
      case 4:
        return [
          {'name': 'Haut du corps 1', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 1', 'muscleGroup': MuscleGroup.lower},
          {'name': 'Haut du corps 2', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 2', 'muscleGroup': MuscleGroup.lower},
        ];
      case 5:
        return [
          {'name': 'Haut du corps 1', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 1', 'muscleGroup': MuscleGroup.lower},
          {'name': 'Full Body', 'muscleGroup': MuscleGroup.full},
          {'name': 'Haut du corps 2', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 2', 'muscleGroup': MuscleGroup.lower},
        ];
      case 6:
      default:
        return [
          {'name': 'Haut du corps 1', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 1', 'muscleGroup': MuscleGroup.lower},
          {'name': 'Full Body 1', 'muscleGroup': MuscleGroup.full},
          {'name': 'Haut du corps 2', 'muscleGroup': MuscleGroup.upper},
          {'name': 'Bas du corps 2', 'muscleGroup': MuscleGroup.lower},
          {'name': 'Full Body 2', 'muscleGroup': MuscleGroup.full},
        ];
    }
  }

  Future<void> _createProgramDay({
    required int programId,
    required int dayId,
    required String dayName,
    required List<RecommendedExercise> exercises,
    required String userLevel,
    required int objectiveId,
    required DateTime scheduledDate,
  }) async {
    final programDayId = await db
        .into(db.programDay)
        .insert(
          ProgramDayCompanion(
            programId: Value(programId),
            name: Value(dayName),
            dayOrder: Value(dayId + 1),
          ),
        );

    final polyExercises = exercises.where((e) => e.type == 'poly').toList();
    final isoExercises = exercises.where((e) => e.type == 'iso').toList();

    final random = Random();
    polyExercises.shuffle(random);
    isoExercises.shuffle(random);

    final dayExercises = <RecommendedExercise>[];

    for (int i = 0; i < 4 && i < polyExercises.length; i++) {
      dayExercises.add(polyExercises[i]);
    }

    for (int i = 0; i < 2 && i < isoExercises.length; i++) {
      dayExercises.add(isoExercises[i]);
    }

    if (dayExercises.length < 6) {
      final remaining =
          exercises.where((e) => !dayExercises.contains(e)).toList();
      remaining.shuffle(random);
      for (int i = 0; dayExercises.length < 6 && i < remaining.length; i++) {
        dayExercises.add(remaining[i]);
      }
    }

    for (int position = 0; position < dayExercises.length; position++) {
      final exercise = dayExercises[position];
      final suggestions = _getSuggestionsForExercise(
        exercise: exercise,
        userLevel: userLevel,
        position: position,
      );

      final modality = await _getModalityForExercise(
        objectiveId: objectiveId,
        userLevel: userLevel,
      );

      await db
          .into(db.programDayExercise)
          .insert(
            ProgramDayExerciseCompanion(
              programDayId: Value(programDayId),
              exerciseId: Value(exercise.id),
              position: Value(position + 1),
              modalityId: Value(modality?.id),
              setsSuggestion: Value(suggestions['sets']),
              repsSuggestion: Value(suggestions['reps']),
              restSuggestionSec: Value(suggestions['rest']),
              previousSetsSuggestion: Value(suggestions['previousSets']), // New
              previousRepsSuggestion: Value(suggestions['previousReps']), // New
              notes: Value(suggestions['notes']),
              scheduledDate: Value(scheduledDate),
            ),
          );
    }
  }

  Map<String, dynamic> _getSuggestionsForExercise({
    required RecommendedExercise exercise,
    required String userLevel,
    required int position,
  }) {
    int sets;
    String reps;
    int rest;
    String? notes;

    if (exercise.type == 'poly') {
      switch (userLevel) {
        case 'debutant':
          sets = 3;
          reps = '8-10';
          rest = 90;
          break;
        case 'intermediaire':
          sets = 4;
          reps = '8-12';
          rest = 90;
          break;
        case 'avance':
          sets = 4;
          reps = '6-10';
          rest = 120;
          break;
        default:
          sets = 3;
          reps = '8-12';
          rest = 90;
      }
    } else {
      switch (userLevel) {
        case 'debutant':
          sets = 2;
          reps = '10-12';
          rest = 60;
          break;
        case 'intermediaire':
          sets = 3;
          reps = '10-15';
          rest = 60;
          break;
        case 'avance':
          sets = 3;
          reps = '12-15';
          rest = 60;
          break;
        default:
          sets = 3;
          reps = '10-15';
          rest = 60;
      }
    }

    if (position == 0) {
      notes = 'Exercice principal - charge maximale';
    }

    String? previousSets;
    String? previousReps;

    // Capture initial values for comparison
    final initialSets = sets;
    final initialReps = reps;

    if (exercise.performanceAdjustment <= -0.5) {
      sets = max(1, sets - 1);
      reps = _adjustReps(reps, -2);
      if (notes == null)
        notes = "Réduire la charge si nécessaire";
      else
        notes = "$notes - Réduire charge";
    } else if (exercise.performanceAdjustment <= -0.2) {
      reps = _adjustReps(reps, -1);
    } else if (exercise.performanceAdjustment >= 0.5) {
      reps = _adjustReps(reps, 2);
    }

    // Check for changes
    if (sets != initialSets) {
      previousSets = '$initialSets séries';
    }
    if (reps != initialReps) {
      previousReps = '$initialReps reps';
    }

    return {
      'sets': '$sets séries',
      'reps': '$reps reps',
      'rest': rest,
      'notes': notes,
      'previousSets': previousSets,
      'previousReps': previousReps,
    };
  }

  String _adjustReps(String repsStr, int delta) {
    final match = RegExp(r'(\d+)(?:-(\d+))?').firstMatch(repsStr);
    if (match != null) {
      int min = int.parse(match.group(1)!);
      int? maxVal = match.group(2) != null ? int.parse(match.group(2)!) : null;

      min = (min + delta).clamp(1, 100);
      if (maxVal != null) {
        maxVal = (maxVal + delta).clamp(min, 100);
        return '$min-$maxVal';
      } else {
        return '$min';
      }
    }
    return repsStr;
  }

  Future<TrainingModalityData?> _getModalityForExercise({
    required int objectiveId,
    required String userLevel,
  }) async {
    final modality =
        await (db.select(db.trainingModality)
              ..where(
                (tbl) =>
                    tbl.objectiveId.equals(objectiveId) &
                    tbl.level.equals(userLevel),
              )
              ..limit(1))
            .getSingleOrNull();

    return modality;
  }

  Future<WorkoutProgramData?> getActiveUserProgram(int userId) async {
    final userProgram =
        await (db.select(db.userProgram)
              ..where(
                (tbl) => tbl.userId.equals(userId) & tbl.isActive.equals(1),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.startDateTs)])
              ..limit(1))
            .getSingleOrNull();

    if (userProgram == null) return null;

    return await (db.select(db.workoutProgram)
      ..where((tbl) => tbl.id.equals(userProgram.programId))).getSingle();
  }

  Future<List<ProgramDaySession>> getProgramDays(int programId) async {
    final days =
        await (db.select(db.programDay)
              ..where((tbl) => tbl.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
            .get();

    final List<ProgramDaySession> sessions = [];

    for (final day in days) {
      final exercises = await _getProgramDayExercises(day.id);

      final scheduledDate =
          exercises.isNotEmpty ? exercises.first.scheduledDate : null;
      sessions.add(
        ProgramDaySession(
          programDayId: day.id,
          dayOrder: day.dayOrder,
          dayName: day.name,
          exercises: exercises,
          scheduledDate: scheduledDate,
        ),
      );
    }

    return sessions;
  }

  Future<List<ProgramExerciseDetail>> _getProgramDayExercises(
    int programDayId,
  ) async {
    final programExercises =
        await (db.select(db.programDayExercise)
              ..where((tbl) => tbl.programDayId.equals(programDayId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    final List<ProgramExerciseDetail> exercises = [];

    for (final programEx in programExercises) {
      final exercise =
          await (db.select(db.exercise)
            ..where((tbl) => tbl.id.equals(programEx.exerciseId))).getSingle();

      TrainingModalityData? modality;
      if (programEx.modalityId != null) {
        modality =
            await (db.select(db.trainingModality)..where(
              (tbl) => tbl.id.equals(programEx.modalityId!),
            )).getSingleOrNull();
      }

      exercises.add(
        ProgramExerciseDetail(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          exerciseType: exercise.type,
          difficulty: exercise.difficulty,
          position: programEx.position,
          setsSuggestion: programEx.setsSuggestion,
          repsSuggestion: programEx.repsSuggestion,
          restSuggestionSec: programEx.restSuggestionSec,
          modality: modality,
          scheduledDate: programEx.scheduledDate,
          previousSetsSuggestion: programEx.previousSetsSuggestion,
          previousRepsSuggestion: programEx.previousRepsSuggestion,
          previousRestSuggestion: programEx.previousRestSuggestion,
        ),
      );
    }

    return exercises;
  }

  Future<int> regenerateUserProgram({
    required int userId,
    int? objectiveId,
    int? daysPerWeek,
  }) async {
    await (db.update(db.userProgram)..where(
      (tbl) => tbl.userId.equals(userId),
    )).write(const UserProgramCompanion(isActive: Value(0)));

    return await generateUserProgram(
      userId: userId,
      objectiveId: objectiveId,
      daysPerWeek: daysPerWeek,
      startToday: true, // Start immediately to show new session today
    );
  }

  Future<void> regenerateFutureDays({
    required int userId,
    required int programId,
  }) async {
    debugPrint(
      '[PROGRAM_REGEN] Début régénération des jours futurs pour programme $programId',
    );

    final allDays =
        await (db.select(db.programDay)
              ..where((tbl) => tbl.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
            .get();

    if (allDays.isEmpty) {
      debugPrint('[PROGRAM_REGEN] Aucun jour trouvé pour ce programme');
      return;
    }

    final completedDayIds = <int>[];
    for (final day in allDays) {
      final session =
          await (db.select(db.session)
                ..where(
                  (tbl) =>
                      tbl.programDayId.equals(day.id) &
                      tbl.durationMin.isNotNull(),
                )
                ..limit(1))
              .getSingleOrNull();

      if (session != null) {
        completedDayIds.add(day.id);
        debugPrint(
          '[PROGRAM_REGEN] Jour ${day.dayOrder} (${day.name}) est complété',
        );
      }
    }

    final futureDays =
        allDays.where((d) => !completedDayIds.contains(d.id)).toList();

    if (futureDays.isEmpty) {
      debugPrint(
        '[PROGRAM_REGEN] Tous les jours sont complétés, rien à régénérer',
      );
      return;
    }

    debugPrint('[PROGRAM_REGEN] ${futureDays.length} jours à régénérer');

    final program =
        await (db.select(db.workoutProgram)
          ..where((tbl) => tbl.id.equals(programId))).getSingle();

    final user =
        await (db.select(db.appUser)
          ..where((tbl) => tbl.id.equals(userId))).getSingle();

    final objectiveId = program.objectiveId ?? 1;
    final userLevel = user.level ?? 'intermediaire';

    DateTime? lastCompletedDate;
    for (final completedDayId in completedDayIds) {
      final exercises =
          await (db.select(db.programDayExercise)
                ..where((tbl) => tbl.programDayId.equals(completedDayId))
                ..limit(1))
              .get();

      if (exercises.isNotEmpty && exercises.first.scheduledDate != null) {
        final date = exercises.first.scheduledDate!;
        if (lastCompletedDate == null || date.isAfter(lastCompletedDate)) {
          lastCompletedDate = date;
        }
      }
    }

    debugPrint('[PROGRAM_REGEN] Dernière date complétée: $lastCompletedDate');

    final scheduledDates = await _calculateTrainingDates(
      userId: userId,
      numberOfDays: futureDays.length,
      startFromDate: lastCompletedDate,
    );

    for (int i = 0; i < futureDays.length; i++) {
      final day = futureDays[i];
      final scheduledDate = scheduledDates[i];

      debugPrint(
        '[PROGRAM_REGEN] Régénération jour ${day.dayOrder} (${day.name})',
      );

      final existingExercises =
          await (db.select(db.programDayExercise)
            ..where((tbl) => tbl.programDayId.equals(day.id))).get();

      final Map<int, ProgramDayExerciseData> previousData = {
        for (var e in existingExercises) e.exerciseId: e,
      };

      await (db.delete(db.programDayExercise)
        ..where((tbl) => tbl.programDayId.equals(day.id))).go();

      MuscleGroup muscleGroup;
      if (day.name.toLowerCase().contains('haut')) {
        muscleGroup = MuscleGroup.upper;
      } else if (day.name.toLowerCase().contains('bas')) {
        muscleGroup = MuscleGroup.lower;
      } else {
        muscleGroup = MuscleGroup.full;
      }

      var exercises = await recommendationService
          .getRecommendedExercisesByMuscleGroup(
            userId: userId,
            muscleGroup: muscleGroup,
            specificObjectiveId: objectiveId,
            limit: 30,
          );

      if (exercises.length < 10) {
        debugPrint('[PROGRAM_REGEN] Complément avec exercices généraux');
        final generalExercises = await recommendationService
            .getRecommendedExercises(
              userId: userId,
              specificObjectiveId: objectiveId,
              limit: 30,
            );

        final exerciseIds = exercises.map((e) => e.id).toSet();
        final additionalExercises =
            generalExercises.where((e) => !exerciseIds.contains(e.id)).toList();

        exercises = [...exercises, ...additionalExercises];
      }

      if (exercises.isEmpty) {
        debugPrint('[PROGRAM_REGEN] ERREUR: Aucun exercice disponible');
        continue;
      }

      final polyExercises = exercises.where((e) => e.type == 'poly').toList();
      final isoExercises = exercises.where((e) => e.type == 'iso').toList();

      final random = Random();
      polyExercises.shuffle(random);
      isoExercises.shuffle(random);

      final dayExercises = <RecommendedExercise>[];

      for (int j = 0; j < 4 && j < polyExercises.length; j++) {
        dayExercises.add(polyExercises[j]);
      }

      for (int j = 0; j < 2 && j < isoExercises.length; j++) {
        dayExercises.add(isoExercises[j]);
      }

      if (dayExercises.length < 6) {
        final remaining =
            exercises.where((e) => !dayExercises.contains(e)).toList();
        remaining.shuffle(random);
        for (int j = 0; dayExercises.length < 6 && j < remaining.length; j++) {
          dayExercises.add(remaining[j]);
        }
      }

      for (int position = 0; position < dayExercises.length; position++) {
        final exercise = dayExercises[position];
        final suggestions = _getSuggestionsForExercise(
          exercise: exercise,
          userLevel: userLevel,
          position: position,
        );

        final modality = await _getModalityForExercise(
          objectiveId: objectiveId,
          userLevel: userLevel,
        );

        String? prevSets;
        String? prevReps;
        int? prevRest;

        if (previousData.containsKey(exercise.id)) {
          final old = previousData[exercise.id]!;
          final newSets = suggestions['sets'] as String;
          final newReps = suggestions['reps'] as String;
          final newRest = suggestions['rest'] as int;

          if (old.setsSuggestion != newSets) prevSets = old.setsSuggestion;
          if (old.repsSuggestion != newReps) prevReps = old.repsSuggestion;
          if (old.restSuggestionSec != newRest)
            prevRest = old.restSuggestionSec;
        }

        await db
            .into(db.programDayExercise)
            .insert(
              ProgramDayExerciseCompanion(
                programDayId: Value(day.id),
                exerciseId: Value(exercise.id),
                position: Value(position + 1),
                modalityId: Value(modality?.id),
                setsSuggestion: Value(suggestions['sets'] as String),
                repsSuggestion: Value(suggestions['reps'] as String),
                restSuggestionSec: Value(suggestions['rest'] as int),
                notes: Value(suggestions['notes'] as String?),
                scheduledDate: Value(scheduledDate),
                previousSetsSuggestion: Value(prevSets),
                previousRepsSuggestion: Value(prevReps),
                previousRestSuggestion: Value(prevRest),
              ),
            );
      }

      debugPrint(
        '[PROGRAM_REGEN] Jour ${day.dayOrder} régénéré avec ${dayExercises.length} exercices',
      );
    }

    debugPrint('[PROGRAM_REGEN] Régénération terminée avec succès');
  }
}
