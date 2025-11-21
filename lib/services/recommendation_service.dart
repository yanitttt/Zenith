import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class RecommendedExercise {
  final int id;
  final String name;
  final String type;
  final int difficulty;
  final double cardio;
  final double objectiveAffinity;

  RecommendedExercise({
    required this.id,
    required this.name,
    required this.type,
    required this.difficulty,
    required this.cardio,
    required this.objectiveAffinity,
  });

  double get score {
    // Score basé sur l'affinité avec l'objectif
    // On peut ajuster cette formule selon les besoins
    double baseScore = objectiveAffinity;

    // Bonus pour la difficulté adaptée (difficulté moyenne = meilleure)
    double difficultyBonus = 1.0 - ((difficulty - 3).abs() / 5.0) * 0.2;

    return baseScore * difficultyBonus;
  }
}

class RecommendationService {
  final AppDb db;

  RecommendationService(this.db);

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

      return results.map((row) {
        return RecommendedExercise(
          id: row.read<int>('id'),
          name: row.read<String>('name'),
          type: row.read<String>('type'),
          difficulty: row.read<int>('difficulty'),
          cardio: row.read<double>('cardio'),
          objectiveAffinity: row.read<double>('objective_affinity'),
        );
      }).toList();
    } catch (e) {
      print('[RECOMMENDATION] Erreur: $e');
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

    // Créer une séance équilibrée (60% poly, 40% iso)
    final List<RecommendedExercise> workout = [];
    final int polyCount = (totalExercises * 0.6).round();
    final int isoCount = totalExercises - polyCount;

    // Ajouter les exercices poly
    for (int i = 0; i < polyCount && i < polyExercises.length; i++) {
      workout.add(polyExercises[i]);
    }

    // Ajouter les exercices iso
    for (int i = 0; i < isoCount && i < isoExercises.length; i++) {
      workout.add(isoExercises[i]);
    }

    // Si on n'a pas assez d'exercices d'un type, compléter avec l'autre
    while (workout.length < totalExercises && workout.length < exercises.length) {
      final remaining = exercises.where((e) => !workout.contains(e)).toList();
      if (remaining.isEmpty) break;
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
}
