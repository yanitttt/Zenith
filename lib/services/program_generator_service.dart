import 'package:drift/drift.dart';
import '../data/db/app_db.dart';
import 'recommendation_service.dart';

class ProgramDaySession {
  final int programDayId;
  final int dayOrder;
  final String dayName;
  final List<ProgramExerciseDetail> exercises;

  ProgramDaySession({
    required this.programDayId,
    required this.dayOrder,
    required this.dayName,
    required this.exercises,
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
  });
}

class ProgramGeneratorService {
  final AppDb db;
  final RecommendationService recommendationService;

  ProgramGeneratorService(this.db)
      : recommendationService = RecommendationService(db);

  /// Génère un programme complet pour l'utilisateur
  /// Retourne l'ID du programme créé
  Future<int> generateUserProgram({
    required int userId,
    int? objectiveId,
    int daysPerWeek = 3,
    String? programName,
  }) async {
    // 1. Déterminer l'objectif et le niveau de l'utilisateur
    final user = await (db.select(db.appUser)
          ..where((tbl) => tbl.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      throw Exception('Utilisateur non trouvé');
    }

    // 2. Récupérer l'objectif
    int targetObjectiveId;
    if (objectiveId != null) {
      targetObjectiveId = objectiveId;
    } else {
      final userGoals = await (db.select(db.userGoal)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.weight)])
            ..limit(1))
          .get();

      if (userGoals.isEmpty) {
        throw Exception('Aucun objectif défini pour cet utilisateur');
      }
      targetObjectiveId = userGoals.first.objectiveId;
    }

    final objective = await (db.select(db.objective)
          ..where((tbl) => tbl.id.equals(targetObjectiveId)))
        .getSingle();

    // 3. Créer le programme
    final programId = await db.into(db.workoutProgram).insert(
          WorkoutProgramCompanion(
            name: Value(programName ?? 'Programme ${objective.name}'),
            description: Value(
                'Programme personnalisé pour ${objective.name.toLowerCase()}'),
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
    await db.into(db.userProgram).insert(
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
    final List<Map<String, dynamic>> dayConfigs = _getDayConfigurations(daysPerWeek);

    for (int day = 0; day < daysPerWeek; day++) {
      final config = dayConfigs[day];
      final MuscleGroup muscleGroup = config['muscleGroup'];
      final String dayName = config['name'];

      // Récupérer les exercices pour ce groupe musculaire
      final exercises = await recommendationService.getRecommendedExercisesByMuscleGroup(
        userId: userId,
        muscleGroup: muscleGroup,
        specificObjectiveId: objectiveId,
        limit: 20,
      );

      if (exercises.isEmpty) {
        print('[PROGRAM] Aucun exercice trouvé pour $dayName, utilisation du fallback');
        // Fallback: récupérer tous les exercices
        final fallbackExercises = await recommendationService.getRecommendedExercises(
          userId: userId,
          specificObjectiveId: objectiveId,
          limit: 20,
        );
        if (fallbackExercises.isEmpty) {
          throw Exception('Aucun exercice disponible pour générer un programme');
        }
        await _createProgramDay(
          programId: programId,
          dayId: day,
          dayName: dayName,
          exercises: fallbackExercises,
          userLevel: userLevel,
          objectiveId: objectiveId,
        );
        continue;
      }

      await _createProgramDay(
        programId: programId,
        dayId: day,
        dayName: dayName,
        exercises: exercises,
        userLevel: userLevel,
        objectiveId: objectiveId,
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
  }) async {
    // Créer le jour
    final programDayId = await db.into(db.programDay).insert(
          ProgramDayCompanion(
            programId: Value(programId),
            name: Value(dayName),
            dayOrder: Value(dayId + 1),
          ),
        );

    // Séparer par type
    final polyExercises = exercises.where((e) => e.type == 'poly').toList();
    final isoExercises = exercises.where((e) => e.type == 'iso').toList();

    // Sélectionner 6 exercices pour ce jour (4 poly, 2 iso)
    final dayExercises = <RecommendedExercise>[];

    // Ajouter jusqu'à 4 exercices poly
    for (int i = 0; i < 4 && i < polyExercises.length; i++) {
      dayExercises.add(polyExercises[i]);
    }

    // Ajouter jusqu'à 2 exercices iso
    for (int i = 0; i < 2 && i < isoExercises.length; i++) {
      dayExercises.add(isoExercises[i]);
    }

    // Si on n'a pas assez d'exercices, compléter avec les exercices restants
    if (dayExercises.length < 6) {
      final remaining = exercises.where((e) => !dayExercises.contains(e)).toList();
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

      await db.into(db.programDayExercise).insert(
            ProgramDayExerciseCompanion(
              programDayId: Value(programDayId),
              exerciseId: Value(exercise.id),
              position: Value(position + 1),
              modalityId: Value(modality?.id),
              setsSuggestion: Value(suggestions['sets']),
              repsSuggestion: Value(suggestions['reps']),
              restSuggestionSec: Value(suggestions['rest']),
              notes: Value(suggestions['notes']),
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

    return {
      'sets': '$sets séries',
      'reps': '$reps reps',
      'rest': rest,
      'notes': notes,
    };
  }

  Future<TrainingModalityData?> _getModalityForExercise({
    required int objectiveId,
    required String userLevel,
  }) async {
    final modality = await (db.select(db.trainingModality)
          ..where((tbl) =>
              tbl.objectiveId.equals(objectiveId) &
              tbl.level.equals(userLevel))
          ..limit(1))
        .getSingleOrNull();

    return modality;
  }

  /// Récupère le programme actif de l'utilisateur
  Future<WorkoutProgramData?> getActiveUserProgram(int userId) async {
    final userProgram = await (db.select(db.userProgram)
          ..where((tbl) =>
              tbl.userId.equals(userId) & tbl.isActive.equals(1))
          ..orderBy([(t) => OrderingTerm.desc(t.startDateTs)])
          ..limit(1))
        .getSingleOrNull();

    if (userProgram == null) return null;

    return await (db.select(db.workoutProgram)
          ..where((tbl) => tbl.id.equals(userProgram.programId)))
        .getSingle();
  }

  /// Récupère tous les jours d'un programme avec leurs exercices
  Future<List<ProgramDaySession>> getProgramDays(int programId) async {
    final days = await (db.select(db.programDay)
          ..where((tbl) => tbl.programId.equals(programId))
          ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
        .get();

    final List<ProgramDaySession> sessions = [];

    for (final day in days) {
      final exercises = await _getProgramDayExercises(day.id);
      sessions.add(ProgramDaySession(
        programDayId: day.id,
        dayOrder: day.dayOrder,
        dayName: day.name,
        exercises: exercises,
      ));
    }

    return sessions;
  }

  Future<List<ProgramExerciseDetail>> _getProgramDayExercises(
      int programDayId) async {
    final programExercises = await (db.select(db.programDayExercise)
          ..where((tbl) => tbl.programDayId.equals(programDayId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    final List<ProgramExerciseDetail> exercises = [];

    for (final programEx in programExercises) {
      final exercise = await (db.select(db.exercise)
            ..where((tbl) => tbl.id.equals(programEx.exerciseId)))
          .getSingle();

      TrainingModalityData? modality;
      if (programEx.modalityId != null) {
        modality = await (db.select(db.trainingModality)
              ..where((tbl) => tbl.id.equals(programEx.modalityId!)))
            .getSingleOrNull();
      }

      exercises.add(ProgramExerciseDetail(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        exerciseType: exercise.type,
        difficulty: exercise.difficulty,
        position: programEx.position,
        setsSuggestion: programEx.setsSuggestion,
        repsSuggestion: programEx.repsSuggestion,
        restSuggestionSec: programEx.restSuggestionSec,
        modality: modality,
      ));
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
    await (db.update(db.userProgram)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(const UserProgramCompanion(isActive: Value(0)));

    // Générer un nouveau programme
    return await generateUserProgram(
      userId: userId,
      objectiveId: objectiveId,
      daysPerWeek: daysPerWeek,
    );
  }
}
