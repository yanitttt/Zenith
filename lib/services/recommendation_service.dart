import 'dart:math';
import 'package:drift/drift.dart';
import '../data/db/app_db.dart';
import 'package:flutter/foundation.dart';
import '../core/perf/perf_service.dart';

class RecommendedExercise {
  final int id;
  final String name;
  final String type;
  final int difficulty;
  final double cardio;
  final double objectiveAffinity;

  double performanceAdjustment;
  double feedbackAdjustment;

  RecommendedExercise({
    required this.id,
    required this.name,
    required this.type,
    required this.difficulty,
    required this.cardio,
    required this.objectiveAffinity,
    this.performanceAdjustment = 0.0,
    this.feedbackAdjustment = 0.0,
  });

  double get score {
    double baseScore = objectiveAffinity;

    double difficultyBonus = 1.0 - ((difficulty - 3).abs() / 5.0) * 0.2;

    double performanceMultiplier = 1.0 + performanceAdjustment;

    double feedbackMultiplier = 1.0 + feedbackAdjustment;

    return baseScore *
        difficultyBonus *
        performanceMultiplier *
        feedbackMultiplier;
  }
}

enum MuscleGroup { upper, lower, full }

class RecommendationService {
  final AppDb db;

  RecommendationService(this.db);

  static const Map<String, MuscleGroup> _muscleGroupMapping = {
    // Haut du corps
    'pectoraux': MuscleGroup.upper,
    'pectoral': MuscleGroup.upper,
    'chest': MuscleGroup.upper,
    'épaules': MuscleGroup.upper,
    'epaules': MuscleGroup.upper,
    'shoulders': MuscleGroup.upper,
    'deltoïdes': MuscleGroup.upper,
    'deltoides': MuscleGroup.upper,
    'triceps': MuscleGroup.upper,
    'biceps': MuscleGroup.upper,
    'avant-bras': MuscleGroup.upper,
    'forearms': MuscleGroup.upper,
    'dos': MuscleGroup.upper,
    'back': MuscleGroup.upper,
    'dorsaux': MuscleGroup.upper,
    'lats': MuscleGroup.upper,
    'trapèzes': MuscleGroup.upper,
    'trapezes': MuscleGroup.upper,
    'traps': MuscleGroup.upper,
    'rhomboïdes': MuscleGroup.upper,
    'abdominaux': MuscleGroup.upper,
    'abdos': MuscleGroup.upper,
    'abs': MuscleGroup.upper,
    'core': MuscleGroup.upper,

    // Bas du corps
    'quadriceps': MuscleGroup.lower,
    'quads': MuscleGroup.lower,
    'ischio-jambiers': MuscleGroup.lower,
    'ischio': MuscleGroup.lower,
    'hamstrings': MuscleGroup.lower,
    'mollets': MuscleGroup.lower,
    'calves': MuscleGroup.lower,
    'fessiers': MuscleGroup.lower,
    'glutes': MuscleGroup.lower,
    'adducteurs': MuscleGroup.lower,
    'abducteurs': MuscleGroup.lower,
    'jambes': MuscleGroup.lower,
    'legs': MuscleGroup.lower,
  };

  MuscleGroup _getMuscleGroup(String muscleName) {
    final normalized = muscleName.toLowerCase().trim();
    return _muscleGroupMapping[normalized] ?? MuscleGroup.upper;
  }

  Future<List<RecommendedExercise>> getRecommendedExercises({
    required int userId,
    int? specificObjectiveId,
    int limit = 10,
  }) async {
    try {
      int objectiveId;
      if (specificObjectiveId != null) {
        objectiveId = specificObjectiveId;
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
        objectiveId = userGoals.first.objectiveId;
      }

      final query = '''
        WITH user_eq AS (
          SELECT equipment_id FROM user_equipment WHERE user_id = ?
        ),
        ex_ok_eq AS (
          SELECT e.id
          FROM exercise e
          LEFT JOIN exercise_equipment ee ON ee.exercise_id = e.id
          LEFT JOIN user_eq ue ON ue.equipment_id = ee.equipment_id
          GROUP BY e.id
          HAVING COUNT(ee.equipment_id) = COUNT(ue.equipment_id)
        ),
        ex_obj AS (
          SELECT eo.exercise_id, eo.weight AS obj_weight
          FROM exercise_objective eo
          WHERE eo.objective_id = ?
        )
        SELECT e.id, e.name, e.type, e.difficulty, e.cardio,
               COALESCE(ex_obj.obj_weight, 0) AS objective_affinity
        FROM exercise e
        JOIN ex_ok_eq k ON k.id = e.id
        LEFT JOIN ex_obj ON ex_obj.exercise_id = e.id
        ORDER BY objective_affinity DESC, e.difficulty ASC
        LIMIT ?;
      ''';

      final results =
          await db
              .customSelect(
                query,
                variables: [
                  Variable.withInt(userId),
                  Variable.withInt(objectiveId),
                  Variable.withInt(limit),
                ],
                readsFrom: {
                  db.exercise,
                  db.userEquipment,
                  db.exerciseEquipment,
                  db.exerciseObjective,
                },
              )
              .get();

      final exercises =
          results.map((row) {
            return RecommendedExercise(
              id: row.read<int>('id'),
              name: row.read<String>('name'),
              type: row.read<String>('type'),
              difficulty: row.read<int>('difficulty'),
              cardio: row.read<double>('cardio'),
              objectiveAffinity: row.read<double>('objective_affinity'),
            );
          }).toList();

      return await _applyAdaptiveAdjustments(
        userId: userId,
        exercises: exercises,
      );
    } catch (e) {
      print('[RECOMMENDATION] Erreur: $e');
      rethrow;
    }
  }

  Future<List<RecommendedExercise>> getRecommendedExercisesByMuscleGroup({
    required int userId,
    required MuscleGroup muscleGroup,
    int? specificObjectiveId,
    int limit = 10,
  }) async {
    try {
      int objectiveId;
      if (specificObjectiveId != null) {
        objectiveId = specificObjectiveId;
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
        objectiveId = userGoals.first.objectiveId;
      }

      final query = '''
        WITH user_eq AS (
          SELECT equipment_id FROM user_equipment WHERE user_id = ?
        ),
        ex_ok_eq AS (
          SELECT e.id
          FROM exercise e
          LEFT JOIN exercise_equipment ee ON ee.exercise_id = e.id
          LEFT JOIN user_eq ue ON ue.equipment_id = ee.equipment_id
          GROUP BY e.id
          HAVING COUNT(ee.equipment_id) = COUNT(ue.equipment_id)
        ),
        ex_obj AS (
          SELECT eo.exercise_id, eo.weight AS obj_weight
          FROM exercise_objective eo
          WHERE eo.objective_id = ?
        ),
        ex_main_muscle AS (
          SELECT em.exercise_id, m.name AS muscle_name
          FROM exercise_muscle em
          JOIN muscle m ON m.id = em.muscle_id
          WHERE em.weight = (
            SELECT MAX(em2.weight)
            FROM exercise_muscle em2
            WHERE em2.exercise_id = em.exercise_id
          )
        )
        SELECT e.id, e.name, e.type, e.difficulty, e.cardio,
               COALESCE(ex_obj.obj_weight, 0) AS objective_affinity,
               emm.muscle_name
        FROM exercise e
        JOIN ex_ok_eq k ON k.id = e.id
        LEFT JOIN ex_obj ON ex_obj.exercise_id = e.id
        LEFT JOIN ex_main_muscle emm ON emm.exercise_id = e.id
        ORDER BY objective_affinity DESC, e.difficulty ASC;
      ''';

      final results =
          await db
              .customSelect(
                query,
                variables: [
                  Variable.withInt(userId),
                  Variable.withInt(objectiveId),
                ],
                readsFrom: {
                  db.exercise,
                  db.userEquipment,
                  db.exerciseEquipment,
                  db.exerciseObjective,
                  db.exerciseMuscle,
                  db.muscle,
                },
              )
              .get();

      final filteredResults = results
          .where((row) {
            final muscleName = row.readNullable<String>('muscle_name');
            if (muscleName == null) return muscleGroup == MuscleGroup.full;

            final exerciseMuscleGroup = _getMuscleGroup(muscleName);

            if (muscleGroup == MuscleGroup.full) {
              return true;
            }
            return exerciseMuscleGroup == muscleGroup;
          })
          .take(limit);

      final exercises =
          filteredResults.map((row) {
            return RecommendedExercise(
              id: row.read<int>('id'),
              name: row.read<String>('name'),
              type: row.read<String>('type'),
              difficulty: row.read<int>('difficulty'),
              cardio: row.read<double>('cardio'),
              objectiveAffinity: row.read<double>('objective_affinity'),
            );
          }).toList();

      return await _applyAdaptiveAdjustments(
        userId: userId,
        exercises: exercises,
      );
    } catch (e) {
      print('[RECOMMENDATION] Erreur filtrage groupe musculaire: $e');
      rethrow;
    }
  }

  Future<List<RecommendedExercise>> generateWorkoutSession({
    required int userId,
    int? objectiveId,
    int totalExercises = 6,
  }) async {
    final exercises = await getRecommendedExercises(
      userId: userId,
      specificObjectiveId: objectiveId,
      limit: 20,
    );

    if (exercises.isEmpty) {
      return [];
    }

    final polyExercises = exercises.where((e) => e.type == 'poly').toList();
    final isoExercises = exercises.where((e) => e.type == 'iso').toList();

    final random = Random();
    polyExercises.shuffle(random);
    isoExercises.shuffle(random);

    final List<RecommendedExercise> workout = [];
    final int polyCount = (totalExercises * 0.6).round();
    final int isoCount = totalExercises - polyCount;

    for (int i = 0; i < polyCount && i < polyExercises.length; i++) {
      workout.add(polyExercises[i]);
    }

    for (int i = 0; i < isoCount && i < isoExercises.length; i++) {
      workout.add(isoExercises[i]);
    }

    while (workout.length < totalExercises &&
        workout.length < exercises.length) {
      final remaining = exercises.where((e) => !workout.contains(e)).toList();
      if (remaining.isEmpty) break;
      remaining.shuffle(random);
      workout.add(remaining.first);
    }

    return workout;
  }

  Future<List<ObjectiveData>> getUserObjectives(int userId) async {
    final userGoals =
        await (db.select(db.userGoal)
          ..where((tbl) => tbl.userId.equals(userId))).get();

    if (userGoals.isEmpty) {
      return [];
    }

    final objectiveIds = userGoals.map((g) => g.objectiveId).toList();
    final objectives =
        await (db.select(db.objective)
          ..where((tbl) => tbl.id.isIn(objectiveIds))).get();

    return objectives;
  }

  Future<double> _calculatePerformanceAdjustment({
    required int userId,
    required int exerciseId,
  }) async {
    final query = '''
      SELECT se.sets, se.reps, se.load, se.rpe, s.date_ts,
             pde.sets_suggestion, pde.reps_suggestion,
             pd.id as program_day_id
      FROM session_exercise se
      JOIN session s ON s.id = se.session_id
      LEFT JOIN program_day_exercise pde ON pde.program_day_id = s.program_day_id
                                        AND pde.exercise_id = se.exercise_id
      LEFT JOIN program_day pd ON pd.id = s.program_day_id
      WHERE s.user_id = ? AND se.exercise_id = ?
      ORDER BY s.date_ts DESC
      LIMIT 5
    ''';

    final results =
        await db
            .customSelect(
              query,
              variables: [
                Variable.withInt(userId),
                Variable.withInt(exerciseId),
              ],
              readsFrom: {
                db.session,
                db.sessionExercise,
                db.programDayExercise,
                db.programDay,
              },
            )
            .get();

    if (results.isEmpty) {
      return 0.0;
    }

    double totalRpe = 0;
    int rpeCount = 0;
    double performanceRatio = 0.0;
    int performanceCount = 0;

    for (final row in results) {
      final rpe = row.read<double?>('rpe');
      if (rpe != null) {
        totalRpe += rpe;
        rpeCount++;
      }

      final actualSets = row.read<int?>('sets');
      final actualReps = row.read<int?>('reps');
      final setsSuggestion = row.read<String?>('sets_suggestion');
      final repsSuggestion = row.read<String?>('reps_suggestion');

      if (actualSets != null && setsSuggestion != null) {
        final suggestedSets = int.tryParse(
          setsSuggestion.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        if (suggestedSets != null && suggestedSets > 0) {
          final setsRatio = actualSets / suggestedSets;
          performanceRatio += setsRatio;
          performanceCount++;
        }
      }

      if (actualReps != null && repsSuggestion != null) {
        final repsMatch = RegExp(
          r'(\d+)(?:-(\d+))?',
        ).firstMatch(repsSuggestion);
        if (repsMatch != null) {
          final minReps = int.parse(repsMatch.group(1)!);
          final maxReps =
              repsMatch.group(2) != null
                  ? int.parse(repsMatch.group(2)!)
                  : minReps;
          final suggestedReps = (minReps + maxReps) / 2;

          if (suggestedReps > 0) {
            final repsRatio = actualReps / suggestedReps;
            performanceRatio += repsRatio;
            performanceCount++;
          }
        }
      }
    }

    if (rpeCount == 0) return 0.0;

    final avgRpe = totalRpe / rpeCount;
    final avgPerformanceRatio =
        performanceCount > 0 ? performanceRatio / performanceCount : 1.0;

    double loadTrend = 0.0;
    if (results.length >= 3) {
      final firstLoad = results.last.read<double?>('load') ?? 0;
      final lastLoad = results.first.read<double?>('load') ?? 0;

      if (firstLoad > 0) {
        loadTrend = (lastLoad - firstLoad) / firstLoad;
      }
    }

    double adjustment = 0.0;

    if (avgPerformanceRatio < 0.5) {
      adjustment = -0.8;
      debugPrint(
        '[PERF_ADJ] Exercice $exerciseId: Performance très faible (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.8',
      );
    } else if (avgPerformanceRatio < 0.7) {
      adjustment = -0.5;
      debugPrint(
        '[PERF_ADJ] Exercice $exerciseId: Performance faible (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.5',
      );
    } else if (avgPerformanceRatio < 0.9) {
      adjustment = -0.2;
      debugPrint(
        '[PERF_ADJ] Exercice $exerciseId: Performance acceptable (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.2',
      );
    } else if (avgPerformanceRatio >= 1.0) {
      if (avgRpe > 8.5) {
        adjustment = -0.3;
        debugPrint(
          '[PERF_ADJ] Exercice $exerciseId: Complète mais RPE élevé (${avgRpe.toStringAsFixed(1)}) → -0.3',
        );
      } else if (avgRpe < 5.5) {
        adjustment = 0.5;
        debugPrint(
          '[PERF_ADJ] Exercice $exerciseId: Trop facile (RPE ${avgRpe.toStringAsFixed(1)}) → +0.5',
        );
      } else if (avgRpe < 6.5) {
        adjustment = 0.2;
        debugPrint(
          '[PERF_ADJ] Exercice $exerciseId: Facile (RPE ${avgRpe.toStringAsFixed(1)}) → +0.2',
        );
      } else {
        if (loadTrend > 0.1) {
          adjustment = 0.1;
          debugPrint(
            '[PERF_ADJ] Exercice $exerciseId: Zone optimale avec progression → +0.1',
          );
        } else {
          debugPrint('[PERF_ADJ] Exercice $exerciseId: Zone optimale → neutre');
        }
      }
    }

    if (loadTrend > 0.2 && avgRpe < 8.0 && avgPerformanceRatio >= 0.9) {
      adjustment += 0.2;
      debugPrint(
        '[PERF_ADJ] Exercice $exerciseId: Bonus progression (+${(loadTrend * 100).toStringAsFixed(0)}%) → +0.2',
      );
    }

    if (loadTrend < -0.1) {
      adjustment -= 0.2;
      debugPrint(
        '[PERF_ADJ] Exercice $exerciseId: Régression de charge (${(loadTrend * 100).toStringAsFixed(0)}%) → -0.2',
      );
    }

    final finalAdjustment = adjustment.clamp(-1.0, 1.0);
    debugPrint(
      '[PERF_ADJ] Exercice $exerciseId: Ajustement final = $finalAdjustment',
    );

    return finalAdjustment;
  }

  Future<double> _calculateFeedbackAdjustment({
    required int userId,
    required int exerciseId,
  }) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final thirtyDaysTs = thirtyDaysAgo.millisecondsSinceEpoch ~/ 1000;

    final feedbacks =
        await (db.select(db.userFeedback)..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.ts.isBiggerOrEqualValue(thirtyDaysTs),
        )).get();

    if (feedbacks.isEmpty) {
      return 0.0;
    }

    double adjustment = 0.0;
    int totalFeedbacks = feedbacks.length;

    for (final feedback in feedbacks) {
      if (feedback.liked == 1) {
        adjustment += 0.3;
      } else if (feedback.liked == 0) {
        adjustment -= 0.2;
      }

      if (feedback.difficult == 1) {
        adjustment -= 0.2;
      }
      if (feedback.useless == 1) {
        adjustment -= 0.4;
      }

      if (feedback.pleasant == 1) {
        adjustment += 0.1;
      }
    }

    adjustment /= totalFeedbacks;

    return adjustment.clamp(-1.0, 0.5);
  }

  Future<List<RecommendedExercise>> _applyAdaptiveAdjustments({
    required int userId,
    required List<RecommendedExercise> exercises,
  }) async {
    return await PerfService().measure('apply_adaptive_adjustments', () async {
      int dbCalls = 0;

      for (var exercise in exercises) {
        // Mesure individuelle pour prouver le coût par item (facultatif mais parlant)
        final performanceAdj = await _calculatePerformanceAdjustment(
          userId: userId,
          exerciseId: exercise.id,
        );
        dbCalls += 1; // Estimation min (en réalité c'est plus complexe)

        final feedbackAdj = await _calculateFeedbackAdjustment(
          userId: userId,
          exerciseId: exercise.id,
        );
        dbCalls += 1;

        exercise.performanceAdjustment = performanceAdj;
        exercise.feedbackAdjustment = feedbackAdj;
      }

      // Log du nombre d'appels DB simulé pour le rapport "Complexité"
      if (PerfService.isPerfMode) {
        PerfService().logAlgoMetric({
          'name': 'adaptive_scan_complexity',
          'n_items': exercises.length,
          'approx_db_calls': dbCalls, // Pour montrer le N*2
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      exercises.sort((a, b) => b.score.compareTo(a.score));

      return exercises;
    }, tags: {'count': exercises.length});
  }
}
