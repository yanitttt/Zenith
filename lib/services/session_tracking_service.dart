import 'package:drift/drift.dart';
import '../data/db/app_db.dart';
import 'program_generator_service.dart';

class ActiveSessionExercise {
  final int exerciseId;
  final String exerciseName;
  final String exerciseType;
  final int difficulty;
  final int position;
  final String? setsSuggestion;
  final String? repsSuggestion;
  final int? restSuggestionSec;

  // Données réelles enregistrées par l'utilisateur
  int? actualSets;
  int? actualReps;
  double? actualLoad;
  double? actualRpe;
  bool isCompleted;

  ActiveSessionExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseType,
    required this.difficulty,
    required this.position,
    this.setsSuggestion,
    this.repsSuggestion,
    this.restSuggestionSec,
    this.actualSets,
    this.actualReps,
    this.actualLoad,
    this.actualRpe,
    this.isCompleted = false,
  });

  ActiveSessionExercise copyWith({
    int? actualSets,
    int? actualReps,
    double? actualLoad,
    double? actualRpe,
    bool? isCompleted,
  }) {
    return ActiveSessionExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseType: exerciseType,
      difficulty: difficulty,
      position: position,
      setsSuggestion: setsSuggestion,
      repsSuggestion: repsSuggestion,
      restSuggestionSec: restSuggestionSec,
      actualSets: actualSets ?? this.actualSets,
      actualReps: actualReps ?? this.actualReps,
      actualLoad: actualLoad ?? this.actualLoad,
      actualRpe: actualRpe ?? this.actualRpe,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SessionTrackingService {
  final AppDb db;

  SessionTrackingService(this.db);

  /// Démarre une nouvelle session pour un jour de programme donné
  Future<int> startSession({
    required int userId,
    required int programDayId,
  }) async {
    final now = DateTime.now();

    // Créer la session avec le lien vers le jour du programme
    final sessionId = await db.into(db.session).insert(
          SessionCompanion(
            userId: Value(userId),
            programDayId: Value(programDayId),
            dateTs: Value(now.millisecondsSinceEpoch ~/ 1000),
            durationMin: const Value.absent(),
          ),
        );

    return sessionId;
  }

  /// Récupère les exercices d'un jour de programme pour la session
  Future<List<ActiveSessionExercise>> getSessionExercises(
      int programDayId) async {
    final programExercises = await (db.select(db.programDayExercise)
          ..where((tbl) => tbl.programDayId.equals(programDayId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();

    final List<ActiveSessionExercise> exercises = [];

    for (final programEx in programExercises) {
      final exercise = await (db.select(db.exercise)
            ..where((tbl) => tbl.id.equals(programEx.exerciseId)))
          .getSingle();

      exercises.add(ActiveSessionExercise(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        exerciseType: exercise.type,
        difficulty: exercise.difficulty,
        position: programEx.position,
        setsSuggestion: programEx.setsSuggestion,
        repsSuggestion: programEx.repsSuggestion,
        restSuggestionSec: programEx.restSuggestionSec,
      ));
    }

    return exercises;
  }

  /// Enregistre les performances d'un exercice dans la session
  Future<void> saveExercisePerformance({
    required int sessionId,
    required ActiveSessionExercise exercise,
  }) async {
    await db.into(db.sessionExercise).insert(
          SessionExerciseCompanion(
            sessionId: Value(sessionId),
            exerciseId: Value(exercise.exerciseId),
            position: Value(exercise.position),
            sets: Value(exercise.actualSets),
            reps: Value(exercise.actualReps),
            load: Value(exercise.actualLoad),
            rpe: Value(exercise.actualRpe),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Finalise la session en calculant la durée totale
  Future<void> completeSession({
    required int sessionId,
    required DateTime startTime,
  }) async {
    final now = DateTime.now();
    final durationMin = now.difference(startTime).inMinutes;

    await (db.update(db.session)..where((tbl) => tbl.id.equals(sessionId)))
        .write(SessionCompanion(durationMin: Value(durationMin)));
  }

  /// Récupère l'historique des sessions d'un utilisateur
  Future<List<SessionData>> getUserSessions(int userId) async {
    return await (db.select(db.session)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.dateTs)]))
        .get();
  }

  /// Récupère les détails d'une session spécifique
  Future<List<SessionExerciseData>> getSessionDetails(int sessionId) async {
    return await (db.select(db.sessionExercise)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
  }

  /// Analyse les performances pour ajuster les recommandations futures
  Future<Map<String, dynamic>> analyzePerformance({
    required int exerciseId,
    required int userId,
  }) async {
    // Récupérer les 5 dernières sessions avec cet exercice
    final query = '''
      SELECT se.sets, se.reps, se.load, se.rpe, se.position, s.date_ts
      FROM session_exercise se
      JOIN session s ON s.id = se.session_id
      WHERE s.user_id = ? AND se.exercise_id = ?
      ORDER BY s.date_ts DESC
      LIMIT 5
    ''';

    final results = await db.customSelect(
      query,
      variables: [
        Variable.withInt(userId),
        Variable.withInt(exerciseId),
      ],
      readsFrom: {db.session, db.sessionExercise},
    ).get();

    if (results.isEmpty) {
      return {
        'hasHistory': false,
        'averageSets': null,
        'averageReps': null,
        'averageLoad': null,
        'averageRpe': null,
        'trend': 'neutral',
      };
    }

    // Calculer les moyennes
    double totalSets = 0;
    double totalReps = 0;
    double totalLoad = 0;
    double totalRpe = 0;
    int count = 0;

    for (final row in results) {
      final sets = row.read<int?>('sets');
      final reps = row.read<int?>('reps');
      final load = row.read<double?>('load');
      final rpe = row.read<double?>('rpe');

      if (sets != null) {
        totalSets += sets;
        count++;
      }
      if (reps != null) totalReps += reps;
      if (load != null) totalLoad += load;
      if (rpe != null) totalRpe += rpe;
    }

    final avgSets = count > 0 ? totalSets / count : 0;
    final avgReps = count > 0 ? totalReps / count : 0;
    final avgLoad = count > 0 ? totalLoad / count : 0;
    final avgRpe = count > 0 ? totalRpe / count : 0;

    // Déterminer la tendance (si la charge augmente = progression)
    String trend = 'neutral';
    if (results.length >= 3) {
      final firstLoad = results.last.read<double?>('load') ?? 0;
      final lastLoad = results.first.read<double?>('load') ?? 0;
      if (lastLoad > firstLoad * 1.1) {
        trend = 'improving';
      } else if (lastLoad < firstLoad * 0.9) {
        trend = 'declining';
      }
    }

    return {
      'hasHistory': true,
      'averageSets': avgSets,
      'averageReps': avgReps,
      'averageLoad': avgLoad,
      'averageRpe': avgRpe,
      'trend': trend,
      'sessionCount': results.length,
    };
  }

  /// Suggère des ajustements basés sur les performances passées
  Future<Map<String, dynamic>> getSuggestedAdjustments({
    required int exerciseId,
    required int userId,
  }) async {
    final performance = await analyzePerformance(
      exerciseId: exerciseId,
      userId: userId,
    );

    if (!performance['hasHistory']) {
      return {
        'shouldIncrease': false,
        'shouldDecrease': false,
        'message': 'Première fois - utilise les suggestions de base',
      };
    }

    final avgRpe = performance['averageRpe'] as double;
    final trend = performance['trend'] as String;

    // Si RPE moyen > 8.5 : trop difficile, diminuer
    if (avgRpe > 8.5) {
      return {
        'shouldIncrease': false,
        'shouldDecrease': true,
        'message': 'Exercice trop difficile - réduis la charge de 10%',
        'loadAdjustment': -0.10,
      };
    }

    // Si RPE moyen < 6.5 et tendance improving : trop facile, augmenter
    if (avgRpe < 6.5 && trend == 'improving') {
      return {
        'shouldIncrease': true,
        'shouldDecrease': false,
        'message': 'Tu progresses bien - augmente la charge de 5%',
        'loadAdjustment': 0.05,
      };
    }

    return {
      'shouldIncrease': false,
      'shouldDecrease': false,
      'message': 'Continue comme ça, bon rythme !',
      'loadAdjustment': 0.0,
    };
  }

  /// Supprime une session (si erreur ou annulation)
  Future<void> deleteSession(int sessionId) async {
    // Les SessionExercise seront supprimés en cascade
    await (db.delete(db.session)..where((tbl) => tbl.id.equals(sessionId)))
        .go();
  }

  /// Vérifie si un jour de programme a déjà été complété
  Future<bool> isDayCompleted(int programDayId) async {
    final sessions = await (db.select(db.session)
          ..where((tbl) =>
              tbl.programDayId.equals(programDayId) &
              tbl.durationMin.isNotNull())
          ..limit(1))
        .get();

    return sessions.isNotEmpty;
  }

  /// Récupère la dernière session complétée pour un jour
  Future<SessionData?> getLastCompletedSession(int programDayId) async {
    return await (db.select(db.session)
          ..where((tbl) =>
              tbl.programDayId.equals(programDayId) &
              tbl.durationMin.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.dateTs)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Récupère toutes les sessions complétées pour plusieurs jours
  Future<Map<int, SessionData>> getCompletedSessionsForDays(
      List<int> programDayIds) async {
    if (programDayIds.isEmpty) return {};

    final sessions = await (db.select(db.session)
          ..where((tbl) =>
              tbl.programDayId.isIn(programDayIds) &
              tbl.durationMin.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.dateTs)]))
        .get();

    // Créer une map avec seulement la session la plus récente par jour
    final Map<int, SessionData> result = {};
    for (final session in sessions) {
      final dayId = session.programDayId;
      if (dayId != null && !result.containsKey(dayId)) {
        result[dayId] = session;
      }
    }

    return result;
  }
}
