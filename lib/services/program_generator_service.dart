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
    final dayNames = [
      'Jour 1 - Haut du corps',
      'Jour 2 - Bas du corps',
      'Jour 3 - Full Body',
      'Jour 4 - Push',
      'Jour 5 - Pull',
      'Jour 6 - Legs',
    ];

    // Récupérer tous les exercices recommandés
    final allExercises = await recommendationService.getRecommendedExercises(
      userId: userId,
      specificObjectiveId: objectiveId,
      limit: 30,
    );

    if (allExercises.isEmpty) {
      throw Exception('Aucun exercice disponible pour générer un programme');
    }

    // Séparer par type
    final polyExercises = allExercises.where((e) => e.type == 'poly').toList();
    final isoExercises = allExercises.where((e) => e.type == 'iso').toList();

    for (int day = 0; day < daysPerWeek; day++) {
      // Créer le jour
      final dayId = await db.into(db.programDay).insert(
            ProgramDayCompanion(
              programId: Value(programId),
              name: Value(dayNames[day % dayNames.length]),
              dayOrder: Value(day + 1),
            ),
          );

      // Sélectionner 6 exercices pour ce jour (4 poly, 2 iso)
      final dayExercises = <RecommendedExercise>[];

      // Ajouter 4 exercices poly
      final startPolyIndex = (day * 4) % polyExercises.length;
      for (int i = 0; i < 4 && polyExercises.isNotEmpty; i++) {
        final index = (startPolyIndex + i) % polyExercises.length;
        dayExercises.add(polyExercises[index]);
      }

      // Ajouter 2 exercices iso
      final startIsoIndex = (day * 2) % isoExercises.length;
      for (int i = 0; i < 2 && isoExercises.isNotEmpty; i++) {
        final index = (startIsoIndex + i) % isoExercises.length;
        dayExercises.add(isoExercises[index]);
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
                programDayId: Value(dayId),
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
