import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../data/db/app_db.dart';
import '../data/db/daos/user_training_day_dao.dart';
import 'recommendation_service.dart';

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

  /// Calcule les prochaines dates d'entraînement pour l'utilisateur
  /// Retourne une liste de dates futures basée sur les jours d'entraînement définis
  Future<List<DateTime>> _calculateTrainingDates({
    required int userId,
    required int numberOfDays,
  }) async {
    final List<DateTime> scheduledDates = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Récupérer les jours d'entraînement de l'utilisateur (1-7, où 1=Lundi)
    final userTrainingDays = await trainingDayDao.getDayNumbersForUser(userId);

    if (userTrainingDays.isEmpty) {
      // Si aucun jour défini, générer tous les 2 jours
      for (int i = 0; i < numberOfDays; i++) {
        scheduledDates.add(today.add(Duration(days: (i * 2) + 1)));
      }
      return scheduledDates;
    }

    // Trier les jours d'entraînement
    final sortedDays = List<int>.from(userTrainingDays)..sort();

    // Générer les dates futures
    DateTime currentDate = today;

    while (scheduledDates.length < numberOfDays) {
      currentDate = currentDate.add(const Duration(days: 1));

      // weekday retourne 1=Lundi, 7=Dimanche (comme notre système)
      final currentWeekday = currentDate.weekday;

      if (sortedDays.contains(currentWeekday)) {
        scheduledDates.add(currentDate);
      }
    }

    return scheduledDates;
  }

  /// Génère un programme complet pour l'utilisateur
  /// Retourne l'ID du programme créé
  Future<int> generateUserProgram({
    required int userId,
    int? objectiveId,
    int daysPerWeek = 3,
    String? programName,
  }) async {
    // 1. Déterminer l'objectif et le niveau de l'utilisateur
    final user =
        await (db.select(db.appUser)
          ..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();

    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    // 2. Récupérer l'objectif
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

    // 3. Créer le programme
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

    // 4. Générer les jours du programme
    await _generateProgramDays(
      programId: programId,
      userId: userId,
      objectiveId: targetObjectiveId,
      userLevel: user.level ?? 'intermediaire',
      daysPerWeek: daysPerWeek,
    );

    // 5. Associer le programme à l'utilisateur
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
  }

  Future<void> _generateProgramDays({
    required int programId,
    required int userId,
    required int objectiveId,
    required String userLevel,
    required int daysPerWeek,
  }) async {
    // Configuration des séances selon le nombre de jours par semaine
    final List<Map<String, dynamic>> dayConfigs = _getDayConfigurations(
      daysPerWeek,
    );

    // Calculer les dates futures pour chaque séance
    final scheduledDates = await _calculateTrainingDates(
      userId: userId,
      numberOfDays: daysPerWeek,
    );

    for (int day = 0; day < daysPerWeek; day++) {
      final config = dayConfigs[day];
      final MuscleGroup muscleGroup = config['muscleGroup'];
      final String dayName = config['name'];
      final DateTime scheduledDate = scheduledDates[day];

      // Récupérer les exercices pour ce groupe musculaire
      var exercises = await recommendationService
          .getRecommendedExercisesByMuscleGroup(
            userId: userId,
            muscleGroup: muscleGroup,
            specificObjectiveId: objectiveId,
            limit: 30, // Augmenté pour avoir plus de choix
          );

      // Si pas assez d'exercices (moins de 10), compléter avec des exercices généraux
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

        // Ajouter les exercices généraux qui ne sont pas déjà dans la liste
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

  /// Retourne la configuration des jours selon le nombre de jours par semaine
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

  /// Crée un jour de programme avec ses exercices
  Future<void> _createProgramDay({
    required int programId,
    required int dayId,
    required String dayName,
    required List<RecommendedExercise> exercises,
    required String userLevel,
    required int objectiveId,
    required DateTime scheduledDate,
  }) async {
    // Créer le jour
    final programDayId = await db
        .into(db.programDay)
        .insert(
          ProgramDayCompanion(
            programId: Value(programId),
            name: Value(dayName),
            dayOrder: Value(dayId + 1),
          ),
        );

    // Séparer par type
    final polyExercises = exercises.where((e) => e.type == 'poly').toList();
    final isoExercises = exercises.where((e) => e.type == 'iso').toList();

    // Mélanger les listes pour varier les programmes à chaque génération
    final random = Random();
    polyExercises.shuffle(random);
    isoExercises.shuffle(random);

    // Sélectionner 6 exercices pour ce jour (4 poly, 2 iso)
    final dayExercises = <RecommendedExercise>[];

    // Ajouter jusqu'à 4 exercices poly (maintenant mélangés)
    for (int i = 0; i < 4 && i < polyExercises.length; i++) {
      dayExercises.add(polyExercises[i]);
    }

    // Ajouter jusqu'à 2 exercices iso (maintenant mélangés)
    for (int i = 0; i < 2 && i < isoExercises.length; i++) {
      dayExercises.add(isoExercises[i]);
    }

    // Si on n'a pas assez d'exercices, compléter avec les exercices restants
    if (dayExercises.length < 6) {
      final remaining =
          exercises.where((e) => !dayExercises.contains(e)).toList();
      remaining.shuffle(random); // Mélanger aussi les exercices restants
      for (int i = 0; dayExercises.length < 6 && i < remaining.length; i++) {
        dayExercises.add(remaining[i]);
      }
    }

    // Ajouter les exercices au jour avec leurs suggestions
    for (int position = 0; position < dayExercises.length; position++) {
      final exercise = dayExercises[position];
      final suggestions = _getSuggestionsForExercise(
        exercise: exercise,
        userLevel: userLevel,
        position: position,
      );

      // Récupérer la modalité appropriée
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
    // Suggestions basées sur le type d'exercice et le niveau
    int sets;
    String reps;
    int rest;
    String? notes;

    if (exercise.type == 'poly') {
      // Exercices polyarticulaires
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
      // Exercices d'isolation
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

    // Premier exercice : poids plus lourd
    if (position == 0) {
      notes = 'Exercice principal - charge maximale';
    }

    // Ajustements adaptatifs basés sur l'historique
    if (exercise.performanceAdjustment <= -0.5) {
      // Difficulté élevée (échec significatif) : réduire le volume
      sets = max(1, sets - 1);
      reps = _adjustReps(reps, -2);
      if (notes == null)
        notes = "Réduire la charge si nécessaire";
      else
        notes = "$notes - Réduire charge";
    } else if (exercise.performanceAdjustment <= -0.2) {
      // Difficulté modérée : réduire légèrement les reps
      reps = _adjustReps(reps, -1);
    } else if (exercise.performanceAdjustment >= 0.5) {
      // Trop facile : augmenter légèrement le volume
      reps = _adjustReps(reps, 2);
    }

    return {
      'sets': '$sets séries',
      'reps': '$reps reps',
      'rest': rest,
      'notes': notes,
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

  /// Récupère le programme actif de l'utilisateur
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

  /// Récupère tous les jours d'un programme avec leurs exercices
  Future<List<ProgramDaySession>> getProgramDays(int programId) async {
    final days =
        await (db.select(db.programDay)
              ..where((tbl) => tbl.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
            .get();

    final List<ProgramDaySession> sessions = [];

    for (final day in days) {
      final exercises = await _getProgramDayExercises(day.id);
      // Prendre la date du premier exercice (tous les exercices d'un jour ont la même date)
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

  /// Désactive tous les programmes précédents et crée un nouveau
  Future<int> regenerateUserProgram({
    required int userId,
    int? objectiveId,
    int daysPerWeek = 3,
  }) async {
    // Désactiver tous les programmes existants
    await (db.update(db.userProgram)..where(
      (tbl) => tbl.userId.equals(userId),
    )).write(const UserProgramCompanion(isActive: Value(0)));

    // Générer un nouveau programme
    return await generateUserProgram(
      userId: userId,
      objectiveId: objectiveId,
      daysPerWeek: daysPerWeek,
    );
  }

  /// Régénère uniquement les jours futurs du programme (non complétés)
  /// en prenant en compte les nouvelles performances de l'utilisateur
  Future<void> regenerateFutureDays({
    required int userId,
    required int programId,
  }) async {
    debugPrint(
      '[PROGRAM_REGEN] Début régénération des jours futurs pour programme $programId',
    );

    // 1. Récupérer tous les jours du programme
    final allDays =
        await (db.select(db.programDay)
              ..where((tbl) => tbl.programId.equals(programId))
              ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
            .get();

    if (allDays.isEmpty) {
      debugPrint('[PROGRAM_REGEN] Aucun jour trouvé pour ce programme');
      return;
    }

    // 2. Identifier les jours complétés (ceux qui ont une session complétée)
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

    // 3. Identifier les jours futurs (non complétés)
    final futureDays =
        allDays.where((d) => !completedDayIds.contains(d.id)).toList();

    if (futureDays.isEmpty) {
      debugPrint(
        '[PROGRAM_REGEN] Tous les jours sont complétés, rien à régénérer',
      );
      return;
    }

    debugPrint('[PROGRAM_REGEN] ${futureDays.length} jours à régénérer');

    // 4. Récupérer les infos du programme et de l'utilisateur
    final program =
        await (db.select(db.workoutProgram)
          ..where((tbl) => tbl.id.equals(programId))).getSingle();

    final user =
        await (db.select(db.appUser)
          ..where((tbl) => tbl.id.equals(userId))).getSingle();

    final objectiveId = program.objectiveId ?? 1;
    final userLevel = user.level ?? 'intermediaire';

    // 5. Calculer les nouvelles dates pour les jours futurs
    final scheduledDates = await _calculateTrainingDates(
      userId: userId,
      numberOfDays: futureDays.length,
    );

    // 6. Régénérer chaque jour futur
    for (int i = 0; i < futureDays.length; i++) {
      final day = futureDays[i];
      final scheduledDate = scheduledDates[i];

      debugPrint(
        '[PROGRAM_REGEN] Régénération jour ${day.dayOrder} (${day.name})',
      );

      // Récupérer les exercices existants pour ce jour avant suppression
      final existingExercises =
          await (db.select(db.programDayExercise)
            ..where((tbl) => tbl.programDayId.equals(day.id))).get();

      final Map<int, ProgramDayExerciseData> previousData = {
        for (var e in existingExercises) e.exerciseId: e,
      };

      // Supprimer les exercices existants pour ce jour
      await (db.delete(db.programDayExercise)
        ..where((tbl) => tbl.programDayId.equals(day.id))).go();

      // Déterminer le groupe musculaire pour ce jour
      MuscleGroup muscleGroup;
      if (day.name.toLowerCase().contains('haut')) {
        muscleGroup = MuscleGroup.upper;
      } else if (day.name.toLowerCase().contains('bas')) {
        muscleGroup = MuscleGroup.lower;
      } else {
        muscleGroup = MuscleGroup.full;
      }

      // Récupérer les exercices recommandés AVEC les ajustements adaptatifs
      var exercises = await recommendationService
          .getRecommendedExercisesByMuscleGroup(
            userId: userId,
            muscleGroup: muscleGroup,
            specificObjectiveId: objectiveId,
            limit: 30,
          );

      // Si pas assez d'exercices, compléter avec des exercices généraux
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

      // Séparer par type
      final polyExercises = exercises.where((e) => e.type == 'poly').toList();
      final isoExercises = exercises.where((e) => e.type == 'iso').toList();

      // Mélanger les listes
      final random = Random();
      polyExercises.shuffle(random);
      isoExercises.shuffle(random);

      // Sélectionner 6 exercices pour ce jour (4 poly, 2 iso)
      final dayExercises = <RecommendedExercise>[];

      for (int j = 0; j < 4 && j < polyExercises.length; j++) {
        dayExercises.add(polyExercises[j]);
      }

      for (int j = 0; j < 2 && j < isoExercises.length; j++) {
        dayExercises.add(isoExercises[j]);
      }

      // Compléter si nécessaire
      if (dayExercises.length < 6) {
        final remaining =
            exercises.where((e) => !dayExercises.contains(e)).toList();
        remaining.shuffle(random);
        for (int j = 0; dayExercises.length < 6 && j < remaining.length; j++) {
          dayExercises.add(remaining[j]);
        }
      }

      // Ajouter les exercices au jour
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

        // Vérifier si l'exercice existait déjà et s'il y a des changements
        String? prevSets;
        String? prevReps;
        int? prevRest;

        if (previousData.containsKey(exercise.id)) {
          final old = previousData[exercise.id]!;
          final newSets = suggestions['sets'] as String;
          final newReps = suggestions['reps'] as String;
          final newRest = suggestions['rest'] as int;

          // On ne stocke l'ancienne valeur que si elle est différente
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
