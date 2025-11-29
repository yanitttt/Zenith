import 'dart:math';
import 'package:drift/drift.dart';
import '../data/db/app_db.dart';
import 'package:flutter/foundation.dart';

class RecommendedExercise {
  final int id;
  final String name;
  final String type;
  final int difficulty;
  final double cardio;
  final double objectiveAffinity;

  // Nouvelles propriétés pour l'adaptation
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
    // Score basé sur l'affinité avec l'objectif
    double baseScore = objectiveAffinity;

    // Bonus pour la difficulté adaptée (difficulté moyenne = meilleure)
    double difficultyBonus = 1.0 - ((difficulty - 3).abs() / 5.0) * 0.2;

    // Ajustement basé sur les performances passées
    // performanceAdjustment: -1.0 à +1.0
    // Si trop difficile (RPE élevé): négatif
    // Si trop facile (RPE faible + progression): positif
    double performanceMultiplier = 1.0 + performanceAdjustment;

    // Ajustement basé sur les feedbacks
    // feedbackAdjustment: -1.0 à +1.0
    // Si feedbacks négatifs: réduire le score
    double feedbackMultiplier = 1.0 + feedbackAdjustment;

    return baseScore * difficultyBonus * performanceMultiplier * feedbackMultiplier;
  }
}

enum MuscleGroup { upper, lower, full }

class RecommendationService {
  final AppDb db;

  RecommendationService(this.db);

  // Mapping des muscles vers leur groupe (haut/bas du corps)
  // Les noms doivent correspondre à ceux de votre base de données
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

  /// Détermine le groupe musculaire d'un muscle par son nom
  MuscleGroup _getMuscleGroup(String muscleName) {
    final normalized = muscleName.toLowerCase().trim();
    return _muscleGroupMapping[normalized] ?? MuscleGroup.upper;
  }

  /// Récupère les exercices recommandés pour un utilisateur
  /// en fonction de son objectif principal et de son équipement
  Future<List<RecommendedExercise>> getRecommendedExercises({
    required int userId,
    int? specificObjectiveId,
    int limit = 10,
  }) async {
    try {
      // 1. Récupérer l'objectif principal de l'utilisateur
      int objectiveId;
      if (specificObjectiveId != null) {
        objectiveId = specificObjectiveId;
      } else {
        // Prendre le premier objectif de l'utilisateur avec le poids le plus élevé
        final userGoals = await (db.select(db.userGoal)
              ..where((tbl) => tbl.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.weight)])
              ..limit(1))
            .get();

        if (userGoals.isEmpty) {
          throw Exception('Aucun objectif défini pour cet utilisateur');
        }
        objectiveId = userGoals.first.objectiveId;
      }

      // 2. Exécuter la requête de recommandation
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

      final results = await db.customSelect(
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
      ).get();

      final exercises = results.map((row) {
        return RecommendedExercise(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          type: row.read<String>('type'),
          difficulty: row.read<int>('difficulty'),
          cardio: row.read<double>('cardio'),
          objectiveAffinity: row.read<double>('objective_affinity'),
        );
      }).toList();

      // Appliquer les ajustements adaptatifs basés sur les performances et feedbacks
      return await _applyAdaptiveAdjustments(
        userId: userId,
        exercises: exercises,
      );
    } catch (e) {
      print('[RECOMMENDATION] Erreur: $e');
      rethrow;
    }
  }

  /// Récupère les exercices recommandés filtrés par groupe musculaire
  Future<List<RecommendedExercise>> getRecommendedExercisesByMuscleGroup({
    required int userId,
    required MuscleGroup muscleGroup,
    int? specificObjectiveId,
    int limit = 10,
  }) async {
    try {
      // 1. Récupérer l'objectif principal de l'utilisateur
      int objectiveId;
      if (specificObjectiveId != null) {
        objectiveId = specificObjectiveId;
      } else {
        final userGoals = await (db.select(db.userGoal)
              ..where((tbl) => tbl.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.weight)])
              ..limit(1))
            .get();

        if (userGoals.isEmpty) {
          throw Exception('Aucun objectif défini pour cet utilisateur');
        }
        objectiveId = userGoals.first.objectiveId;
      }

      // 2. Exécuter la requête de recommandation avec filtre par groupe musculaire
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

      final results = await db.customSelect(
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
      ).get();

      // 3. Filtrer par groupe musculaire
      final filteredResults = results.where((row) {
        final muscleName = row.readNullable<String>('muscle_name');
        if (muscleName == null) return muscleGroup == MuscleGroup.full;

        final exerciseMuscleGroup = _getMuscleGroup(muscleName);

        if (muscleGroup == MuscleGroup.full) {
          return true; // Full body inclut tous les exercices
        }
        return exerciseMuscleGroup == muscleGroup;
      }).take(limit);

      final exercises = filteredResults.map((row) {
        return RecommendedExercise(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          type: row.read<String>('type'),
          difficulty: row.read<int>('difficulty'),
          cardio: row.read<double>('cardio'),
          objectiveAffinity: row.read<double>('objective_affinity'),
        );
      }).toList();

      // Appliquer les ajustements adaptatifs basés sur les performances et feedbacks
      return await _applyAdaptiveAdjustments(
        userId: userId,
        exercises: exercises,
      );
    } catch (e) {
      print('[RECOMMENDATION] Erreur filtrage groupe musculaire: $e');
      rethrow;
    }
  }

  /// Génère une séance complète avec un mix d'exercices poly/iso
  Future<List<RecommendedExercise>> generateWorkoutSession({
    required int userId,
    int? objectiveId,
    int totalExercises = 6,
  }) async {
    final exercises = await getRecommendedExercises(
      userId: userId,
      specificObjectiveId: objectiveId,
      limit: 20, // Récupérer plus d'exercices pour pouvoir mixer
    );

    if (exercises.isEmpty) {
      return [];
    }

    // Séparer les exercices poly et iso
    final polyExercises = exercises.where((e) => e.type == 'poly').toList();
    final isoExercises = exercises.where((e) => e.type == 'iso').toList();

    // Mélanger les listes pour varier les séances
    final random = Random();
    polyExercises.shuffle(random);
    isoExercises.shuffle(random);

    // Créer une séance équilibrée (60% poly, 40% iso)
    final List<RecommendedExercise> workout = [];
    final int polyCount = (totalExercises * 0.6).round();
    final int isoCount = totalExercises - polyCount;

    // Ajouter les exercices poly (maintenant mélangés)
    for (int i = 0; i < polyCount && i < polyExercises.length; i++) {
      workout.add(polyExercises[i]);
    }

    // Ajouter les exercices iso (maintenant mélangés)
    for (int i = 0; i < isoCount && i < isoExercises.length; i++) {
      workout.add(isoExercises[i]);
    }

    // Si on n'a pas assez d'exercices d'un type, compléter avec l'autre
    while (workout.length < totalExercises && workout.length < exercises.length) {
      final remaining = exercises.where((e) => !workout.contains(e)).toList();
      if (remaining.isEmpty) break;
      remaining.shuffle(random); // Mélanger aussi les exercices restants
      workout.add(remaining.first);
    }

    return workout;
  }

  /// Récupère les objectifs de l'utilisateur
  Future<List<ObjectiveData>> getUserObjectives(int userId) async {
    final userGoals = await (db.select(db.userGoal)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();

    if (userGoals.isEmpty) {
      return [];
    }

    final objectiveIds = userGoals.map((g) => g.objectiveId).toList();
    final objectives = await (db.select(db.objective)
          ..where((tbl) => tbl.id.isIn(objectiveIds)))
        .get();

    return objectives;
  }

  /// Analyse les performances passées pour un exercice et calcule un ajustement
  /// Retourne une valeur entre -1.0 (trop difficile) et +1.0 (trop facile)
  Future<double> _calculatePerformanceAdjustment({
    required int userId,
    required int exerciseId,
  }) async {
    // Récupérer les 5 dernières sessions avec cet exercice ET leurs suggestions
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

    final results = await db.customSelect(
      query,
      variables: [
        Variable.withInt(userId),
        Variable.withInt(exerciseId),
      ],
      readsFrom: {db.session, db.sessionExercise, db.programDayExercise, db.programDay},
    ).get();

    if (results.isEmpty) {
      return 0.0; // Pas d'historique = neutre
    }

    // Calculer le RPE moyen et analyser les performances vs suggestions
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

      // Comparer les performances réelles vs suggérées
      final actualSets = row.read<int?>('sets');
      final actualReps = row.read<int?>('reps');
      final setsSuggestion = row.read<String?>('sets_suggestion');
      final repsSuggestion = row.read<String?>('reps_suggestion');

      if (actualSets != null && setsSuggestion != null) {
        // Parser "3 séries" → 3
        final suggestedSets = int.tryParse(setsSuggestion.replaceAll(RegExp(r'[^0-9]'), ''));
        if (suggestedSets != null && suggestedSets > 0) {
          final setsRatio = actualSets / suggestedSets;
          performanceRatio += setsRatio;
          performanceCount++;
        }
      }

      if (actualReps != null && repsSuggestion != null) {
        // Parser "10-12 reps" ou "10 reps" → prendre la moyenne ou valeur unique
        final repsMatch = RegExp(r'(\d+)(?:-(\d+))?').firstMatch(repsSuggestion);
        if (repsMatch != null) {
          final minReps = int.parse(repsMatch.group(1)!);
          final maxReps = repsMatch.group(2) != null ? int.parse(repsMatch.group(2)!) : minReps;
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
    final avgPerformanceRatio = performanceCount > 0 ? performanceRatio / performanceCount : 1.0;

    // Analyser la tendance de la charge (progression)
    double loadTrend = 0.0;
    if (results.length >= 3) {
      final firstLoad = results.last.read<double?>('load') ?? 0;
      final lastLoad = results.first.read<double?>('load') ?? 0;

      if (firstLoad > 0) {
        loadTrend = (lastLoad - firstLoad) / firstLoad;
      }
    }

    // Calcul de l'ajustement basé sur le RPE ET les performances réelles
    double adjustment = 0.0;

    // 1. Pénalité FORTE si l'utilisateur n'arrive pas à compléter les séries/reps suggérées
    if (avgPerformanceRatio < 0.5) {
      // L'utilisateur fait moins de 50% de ce qui est suggéré → TROP DIFFICILE
      adjustment = -0.8;
      debugPrint('[PERF_ADJ] Exercice $exerciseId: Performance très faible (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.8');
    } else if (avgPerformanceRatio < 0.7) {
      // L'utilisateur fait 50-70% de ce qui est suggéré → Difficile
      adjustment = -0.5;
      debugPrint('[PERF_ADJ] Exercice $exerciseId: Performance faible (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.5');
    } else if (avgPerformanceRatio < 0.9) {
      // L'utilisateur fait 70-90% → Légèrement difficile
      adjustment = -0.2;
      debugPrint('[PERF_ADJ] Exercice $exerciseId: Performance acceptable (${(avgPerformanceRatio * 100).toStringAsFixed(0)}% des suggestions) → -0.2');
    } else if (avgPerformanceRatio >= 1.0) {
      // L'utilisateur fait 100%+ des suggestions → Regarder le RPE pour affiner
      if (avgRpe > 8.5) {
        // Complète les suggestions mais RPE trop élevé → Encore trop dur
        adjustment = -0.3;
        debugPrint('[PERF_ADJ] Exercice $exerciseId: Complète mais RPE élevé (${avgRpe.toStringAsFixed(1)}) → -0.3');
      } else if (avgRpe < 5.5) {
        // Complète facilement → Trop facile
        adjustment = 0.5;
        debugPrint('[PERF_ADJ] Exercice $exerciseId: Trop facile (RPE ${avgRpe.toStringAsFixed(1)}) → +0.5');
      } else if (avgRpe < 6.5) {
        // Complète avec RPE faible → Facile
        adjustment = 0.2;
        debugPrint('[PERF_ADJ] Exercice $exerciseId: Facile (RPE ${avgRpe.toStringAsFixed(1)}) → +0.2');
      } else {
        // RPE dans la zone optimale (6.5-7.5)
        if (loadTrend > 0.1) {
          adjustment = 0.1;
          debugPrint('[PERF_ADJ] Exercice $exerciseId: Zone optimale avec progression → +0.1');
        } else {
          debugPrint('[PERF_ADJ] Exercice $exerciseId: Zone optimale → neutre');
        }
      }
    }

    // 2. Ajustement bonus si bonne progression de charge ET RPE contrôlé
    if (loadTrend > 0.2 && avgRpe < 8.0 && avgPerformanceRatio >= 0.9) {
      adjustment += 0.2;
      debugPrint('[PERF_ADJ] Exercice $exerciseId: Bonus progression (+${(loadTrend * 100).toStringAsFixed(0)}%) → +0.2');
    }

    // 3. Pénalité supplémentaire si régression de charge
    if (loadTrend < -0.1) {
      adjustment -= 0.2;
      debugPrint('[PERF_ADJ] Exercice $exerciseId: Régression de charge (${(loadTrend * 100).toStringAsFixed(0)}%) → -0.2');
    }

    final finalAdjustment = adjustment.clamp(-1.0, 1.0);
    debugPrint('[PERF_ADJ] Exercice $exerciseId: Ajustement final = $finalAdjustment');

    return finalAdjustment;
  }

  /// Analyse les feedbacks pour un exercice et calcule un ajustement
  /// Retourne une valeur entre -1.0 (feedbacks très négatifs) et +0.5 (feedbacks positifs)
  Future<double> _calculateFeedbackAdjustment({
    required int userId,
    required int exerciseId,
  }) async {
    // Récupérer les feedbacks récents (derniers 30 jours)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final thirtyDaysTs = thirtyDaysAgo.millisecondsSinceEpoch ~/ 1000;

    final feedbacks = await (db.select(db.userFeedback)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.exerciseId.equals(exerciseId) &
              tbl.ts.isBiggerOrEqualValue(thirtyDaysTs)))
        .get();

    if (feedbacks.isEmpty) {
      return 0.0; // Pas de feedback = neutre
    }

    double adjustment = 0.0;
    int totalFeedbacks = feedbacks.length;

    for (final feedback in feedbacks) {
      // Si l'utilisateur a aimé l'exercice : bonus
      if (feedback.liked == 1) {
        adjustment += 0.3;
      } else if (feedback.liked == 0) {
        adjustment -= 0.2;
      }

      // Pénalités pour les feedbacks négatifs
      if (feedback.difficult == 1) {
        adjustment -= 0.2;
      }
      if (feedback.useless == 1) {
        adjustment -= 0.4; // Forte pénalité si jugé inutile
      }

      // Bonus si plaisant
      if (feedback.pleasant == 1) {
        adjustment += 0.1;
      }
    }

    // Moyenne par feedback
    adjustment /= totalFeedbacks;

    return adjustment.clamp(-1.0, 0.5);
  }

  /// Applique les ajustements de performance et feedback aux exercices recommandés
  Future<List<RecommendedExercise>> _applyAdaptiveAdjustments({
    required int userId,
    required List<RecommendedExercise> exercises,
  }) async {
    for (var exercise in exercises) {
      // Calculer les ajustements pour chaque exercice
      final performanceAdj = await _calculatePerformanceAdjustment(
        userId: userId,
        exerciseId: exercise.id,
      );

      final feedbackAdj = await _calculateFeedbackAdjustment(
        userId: userId,
        exerciseId: exercise.id,
      );

      // Appliquer les ajustements
      exercise.performanceAdjustment = performanceAdj;
      exercise.feedbackAdjustment = feedbackAdj;
    }

    // Re-trier selon les nouveaux scores
    exercises.sort((a, b) => b.score.compareTo(a.score));

    return exercises;
  }
}
