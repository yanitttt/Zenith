import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/recommendation_service.dart';

void main() {
  late AppDb db;
  late RecommendationService recommendationService;

  // IDs
  late int equipmentHaltereId;
  late int equipmentBarreId;
  late int equipmentBancId;
  late int equipmentMachineId;
  late int equipmentCorpsId;

  late int objectiveForceId;
  late int objectiveHypertrophieId;
  late int objectiveEnduranceId;
  late int objectivePertePoidsId;

  late List<int> exerciseIds;

  Future<void> insertCatalogData() async {
    // EQUIPMENT
    equipmentCorpsId = await db
        .into(db.equipment)
        .insert(EquipmentCompanion.insert(name: 'Poids du corps'));
    equipmentHaltereId = await db
        .into(db.equipment)
        .insert(EquipmentCompanion.insert(name: 'Haltères'));
    equipmentBarreId = await db
        .into(db.equipment)
        .insert(EquipmentCompanion.insert(name: 'Barre'));
    equipmentBancId = await db
        .into(db.equipment)
        .insert(EquipmentCompanion.insert(name: 'Banc'));
    equipmentMachineId = await db
        .into(db.equipment)
        .insert(EquipmentCompanion.insert(name: 'Machine guidée'));

    // OBJECTIVES
    objectiveForceId = await db
        .into(db.objective)
        .insert(ObjectiveCompanion.insert(code: 'force', name: 'Force'));
    objectiveHypertrophieId = await db
        .into(db.objective)
        .insert(
          ObjectiveCompanion.insert(code: 'hypertrophie', name: 'Hypertrophie'),
        );
    objectiveEnduranceId = await db
        .into(db.objective)
        .insert(
          ObjectiveCompanion.insert(code: 'endurance', name: 'Endurance'),
        );
    objectivePertePoidsId = await db
        .into(db.objective)
        .insert(
          ObjectiveCompanion.insert(
            code: 'perte_poids',
            name: 'Perte de poids',
          ),
        );

    // EXERCISES
    exerciseIds = [];

    // 1. Pushups
    final pompesId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Pompes',
            type: 'poly',
            difficulty: 2,
            cardio: const Value(0.3),
          ),
        );
    exerciseIds.add(pompesId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: pompesId,
            equipmentId: equipmentCorpsId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: pompesId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.7,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: pompesId,
            objectiveId: objectiveEnduranceId,
            weight: 0.8,
          ),
        );

    // 2. Bench Press
    final developpeId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Développé couché',
            type: 'poly',
            difficulty: 3,
            cardio: const Value(0.1),
          ),
        );
    exerciseIds.add(developpeId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: developpeId,
            equipmentId: equipmentBarreId,
          ),
        );
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: developpeId,
            equipmentId: equipmentBancId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: developpeId,
            objectiveId: objectiveForceId,
            weight: 0.9,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: developpeId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.8,
          ),
        );

    // 3. Bicep Curl
    final curlId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Curl biceps',
            type: 'iso',
            difficulty: 2,
            cardio: const Value(0.0),
          ),
        );
    exerciseIds.add(curlId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: curlId,
            equipmentId: equipmentHaltereId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: curlId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.9,
          ),
        );

    // 4. Squat
    final squatId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Squat',
            type: 'poly',
            difficulty: 4,
            cardio: const Value(0.4),
          ),
        );
    exerciseIds.add(squatId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: squatId,
            equipmentId: equipmentBarreId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: squatId,
            objectiveId: objectiveForceId,
            weight: 1.0,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: squatId,
            objectiveId: objectivePertePoidsId,
            weight: 0.7,
          ),
        );

    // 5. Burpees
    final burpeesId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Burpees',
            type: 'poly',
            difficulty: 4,
            cardio: const Value(0.9),
          ),
        );
    exerciseIds.add(burpeesId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: burpeesId,
            equipmentId: equipmentCorpsId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: burpeesId,
            objectiveId: objectivePertePoidsId,
            weight: 1.0,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: burpeesId,
            objectiveId: objectiveEnduranceId,
            weight: 0.9,
          ),
        );

    // 6. Leg Press
    final legPressId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Leg press',
            type: 'poly',
            difficulty: 2,
            cardio: const Value(0.2),
          ),
        );
    exerciseIds.add(legPressId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: legPressId,
            equipmentId: equipmentMachineId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: legPressId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.8,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: legPressId,
            objectiveId: objectiveForceId,
            weight: 0.6,
          ),
        );

    // 7. Pullups
    final tractionsId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Tractions',
            type: 'poly',
            difficulty: 4,
            cardio: const Value(0.2),
          ),
        );
    exerciseIds.add(tractionsId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: tractionsId,
            equipmentId: equipmentCorpsId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: tractionsId,
            objectiveId: objectiveForceId,
            weight: 0.8,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: tractionsId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.7,
          ),
        );

    // 8. Triceps Ext
    final extensionId = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Extension triceps',
            type: 'iso',
            difficulty: 2,
            cardio: const Value(0.0),
          ),
        );
    exerciseIds.add(extensionId);
    await db
        .into(db.exerciseEquipment)
        .insert(
          ExerciseEquipmentCompanion.insert(
            exerciseId: extensionId,
            equipmentId: equipmentHaltereId,
          ),
        );
    await db
        .into(db.exerciseObjective)
        .insert(
          ExerciseObjectiveCompanion.insert(
            exerciseId: extensionId,
            objectiveId: objectiveHypertrophieId,
            weight: 0.8,
          ),
        );
  }

  setUp(() async {
    // In-memory DB
    db = AppDb.forTesting(NativeDatabase.memory());
    recommendationService = RecommendationService(db);

    // Seed catalog
    await insertCatalogData();
  });

  tearDown(() async {
    await db.close();
  });

  // Helper: Create User Profile
  Future<int> createUserProfile({
    required String nom,
    required String prenom,
    required List<int> equipmentIds,
    required Map<int, double> objectives, // objectiveId -> weight
    String? level,
    int? age,
  }) async {
    final userId = await db
        .into(db.appUser)
        .insert(
          AppUserCompanion.insert(
            nom: Value(nom),
            prenom: Value(prenom),
            level: Value(level),
            age: Value(age),
          ),
        );

    // Ajouter l'équipement
    for (final eqId in equipmentIds) {
      await db
          .into(db.userEquipment)
          .insert(
            UserEquipmentCompanion.insert(userId: userId, equipmentId: eqId),
          );
    }

    // Ajouter les objectifs
    for (final entry in objectives.entries) {
      await db
          .into(db.userGoal)
          .insert(
            UserGoalCompanion.insert(
              userId: userId,
              objectiveId: entry.key,
              weight: entry.value,
            ),
          );
    }

    return userId;
  }

  group('RecommendationService - Tests de scénarios', () {
    test('Scenario 1: Beginner / Bodyweight / Endurance', () async {
      // Créer un utilisateur débutant avec seulement le poids du corps
      final userId = await createUserProfile(
        nom: 'Dupont',
        prenom: 'Jean',
        equipmentIds: [equipmentCorpsId],
        objectives: {objectiveEnduranceId: 1.0},
        level: 'debutant',
        age: 25,
      );

      // Récupérer les recommandations
      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      // Vérifications
      expect(recommendations, isNotEmpty);

      // Tous les exercices doivent nécessiter uniquement le poids du corps
      for (final ex in recommendations) {
        // Check bodyweight equipment
        final equipment =
            await (db.select(db.exerciseEquipment)
              ..where((t) => t.exerciseId.equals(ex.id))).get();

        expect(
          equipment.every((e) => e.equipmentId == equipmentCorpsId),
          isTrue,
          reason:
              'L\'exercice ${ex.name} devrait utiliser uniquement le poids du corps',
        );
      }

      // Les exercices avec meilleure affinité endurance doivent être en premier
      if (recommendations.length >= 2) {
        expect(
          recommendations.first.objectiveAffinity,
          greaterThanOrEqualTo(recommendations.last.objectiveAffinity),
        );
      }
    });

    test('Scenario 2: Intermediate / Mixed / Hypertrophy', () async {
      // Utilisateur avec haltères et poids du corps
      final userId = await createUserProfile(
        nom: 'Martin',
        prenom: 'Sophie',
        equipmentIds: [equipmentCorpsId, equipmentHaltereId],
        objectives: {objectiveHypertrophieId: 1.0},
        level: 'intermediaire',
        age: 30,
      );

      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      expect(recommendations, isNotEmpty);

      // Should include Isolation exercises
      final hasIsolation = recommendations.any((e) => e.type == 'iso');
      expect(
        hasIsolation,
        isTrue,
        reason: 'Devrait inclure des exercices isolation pour hypertrophie',
      );
    });

    test('Scenario 3: Advanced / Full Equip / Strength', () async {
      // Utilisateur avec tout l'équipement
      final userId = await createUserProfile(
        nom: 'Bernard',
        prenom: 'Marc',
        equipmentIds: [
          equipmentCorpsId,
          equipmentHaltereId,
          equipmentBarreId,
          equipmentBancId,
          equipmentMachineId,
        ],
        objectives: {objectiveForceId: 1.0},
        level: 'avance',
        age: 35,
      );

      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      expect(recommendations, isNotEmpty);

      print('\n--- Résumé Scénario 3 ---');
      print('Utilisateur: Avancé, tout équipement, objectif force');
      print('Exercices recommandés:');
      for (final ex in recommendations) {
        print(
          '  - ${ex.name} (affinité: ${ex.objectiveAffinity}, difficulté: ${ex.difficulty})',
        );
      }

      // Les exercices avec haute affinité force doivent être prioritaires
      // Squat et Développé couché ont les meilleures affinités force
      final firstExercise = recommendations.first;
      expect(
        firstExercise.objectiveAffinity,
        greaterThanOrEqualTo(0.8),
        reason: 'Le premier exercice devrait avoir une haute affinité force',
      );
    });

    test('Scenario 4: Weight Loss', () async {
      final userId = await createUserProfile(
        nom: 'Leroy',
        prenom: 'Emma',
        equipmentIds: [equipmentCorpsId, equipmentBarreId],
        objectives: {objectivePertePoidsId: 1.0},
        level: 'debutant',
        age: 28,
      );

      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      expect(recommendations, isNotEmpty);

      print('\n--- Résumé Scénario 4 ---');
      print(
        'Utilisateur: Débutant, poids du corps + barre, objectif perte de poids',
      );
      print('Exercices recommandés:');
      for (final ex in recommendations) {
        print(
          '  - ${ex.name} (affinité: ${ex.objectiveAffinity}, cardio: ${ex.cardio})',
        );
      }

      // Burpees devrait être en tête (meilleure affinité perte de poids)
      expect(
        recommendations.first.name,
        equals('Burpees'),
        reason: 'Burpees devrait être le premier exercice pour perte de poids',
      );
    });

    test('Scenario 5: Multiple Objectives', () async {
      // Utilisateur avec 2 objectifs: force (prioritaire) et hypertrophie
      final userId = await createUserProfile(
        nom: 'Petit',
        prenom: 'Lucas',
        equipmentIds: [equipmentCorpsId, equipmentBarreId, equipmentBancId],
        objectives: {objectiveForceId: 1.0, objectiveHypertrophieId: 0.7},
        level: 'intermediaire',
        age: 32,
      );

      // Test avec objectif principal (force)
      final forceRecommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      // Test avec objectif secondaire spécifié
      final hypertrophieRecommendations = await recommendationService
          .getRecommendedExercises(
            userId: userId,
            specificObjectiveId: objectiveHypertrophieId,
            limit: 10,
          );

      print('\n--- Résumé Scénario 5 ---');
      print(
        'Utilisateur: Intermédiaire, objectifs multiples (force + hypertrophie)',
      );

      print('\nRecommandations pour FORCE (objectif principal):');
      for (final ex in forceRecommendations) {
        print('  - ${ex.name} (affinité: ${ex.objectiveAffinity})');
      }

      print('\nRecommandations pour HYPERTROPHIE (objectif spécifié):');
      for (final ex in hypertrophieRecommendations) {
        print('  - ${ex.name} (affinité: ${ex.objectiveAffinity})');
      }

      // Les recommandations doivent être différentes selon l'objectif
      expect(forceRecommendations, isNotEmpty);
      expect(hypertrophieRecommendations, isNotEmpty);
    });

    test('Scenario 6: No Compatible Equipment', () async {
      // Utilisateur avec uniquement machine guidée mais aucun exercice n'utilise que ça
      final userId = await createUserProfile(
        nom: 'Moreau',
        prenom: 'Julie',
        equipmentIds: [equipmentMachineId],
        objectives: {objectiveForceId: 1.0},
        level: 'debutant',
        age: 22,
      );

      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      // Seul Leg press devrait être disponible
      expect(
        recommendations.length,
        lessThanOrEqualTo(1),
        reason: 'Seul Leg press utilise uniquement la machine guidée',
      );
    });

    test('Scenario 7: Full Session Generation', () async {
      final userId = await createUserProfile(
        nom: 'Dubois',
        prenom: 'Thomas',
        equipmentIds: [
          equipmentCorpsId,
          equipmentHaltereId,
          equipmentBarreId,
          equipmentBancId,
        ],
        objectives: {objectiveHypertrophieId: 1.0},
        level: 'intermediaire',
        age: 27,
      );

      final workout = await recommendationService.generateWorkoutSession(
        userId: userId,
        totalExercises: 6,
      );

      // Check Poly/Iso ratio (~60/40)
      int polyCount = workout.where((e) => e.type == 'poly').length;

      // Vérifier la répartition poly/iso (environ 60/40)
      expect(workout.length, equals(6));
      expect(
        polyCount,
        greaterThanOrEqualTo(3),
        reason: 'Devrait avoir au moins 60% d\'exercices poly',
      );
    });

    test('Scenario 8: Profile Comparison', () async {
      // Créer 3 profils avec le même équipement mais objectifs différents
      final userForce = await createUserProfile(
        nom: 'Force',
        prenom: 'User',
        equipmentIds: [equipmentCorpsId, equipmentBarreId, equipmentBancId],
        objectives: {objectiveForceId: 1.0},
        level: 'avance',
        age: 30,
      );

      final userCardio = await createUserProfile(
        nom: 'Cardio',
        prenom: 'User',
        equipmentIds: [equipmentCorpsId, equipmentBarreId, equipmentBancId],
        objectives: {objectivePertePoidsId: 1.0},
        level: 'avance',
        age: 30,
      );

      final userHypertrophie = await createUserProfile(
        nom: 'Hypertrophie',
        prenom: 'User',
        equipmentIds: [equipmentCorpsId, equipmentBarreId, equipmentBancId],
        objectives: {objectiveHypertrophieId: 1.0},
        level: 'avance',
        age: 30,
      );

      final forceRecs = await recommendationService.getRecommendedExercises(
        userId: userForce,
        limit: 5,
      );
      final cardioRecs = await recommendationService.getRecommendedExercises(
        userId: userCardio,
        limit: 5,
      );
      final hypertrophieRecs = await recommendationService
          .getRecommendedExercises(userId: userHypertrophie, limit: 5);

      // Verify that the first exercises are different depending on the goal
      expect(forceRecs.first.name, isNot(equals(cardioRecs.first.name)));
      expect(hypertrophieRecs, isNotEmpty);
    });

    test('Scenario 9: User without Goal', () async {
      // Créer un utilisateur sans objectif
      final userId = await db
          .into(db.appUser)
          .insert(
            AppUserCompanion.insert(
              nom: const Value('Sans'),
              prenom: const Value('Objectif'),
            ),
          );

      // Ajouter de l'équipement
      await db
          .into(db.userEquipment)
          .insert(
            UserEquipmentCompanion.insert(
              userId: userId,
              equipmentId: equipmentCorpsId,
            ),
          );

      // Tenter de récupérer des recommandations
      expect(
        () => recommendationService.getRecommendedExercises(userId: userId),
        throwsException,
      );
    });

    test('Scenario 10: Score Analysis', () async {
      final userId = await createUserProfile(
        nom: 'Score',
        prenom: 'Test',
        equipmentIds: [equipmentCorpsId, equipmentHaltereId],
        objectives: {objectiveHypertrophieId: 1.0},
        level: 'intermediaire',
        age: 25,
      );

      final recommendations = await recommendationService
          .getRecommendedExercises(userId: userId, limit: 10);

      // Check score correctness

      // Vérifier que le score est calculé correctement
      for (final ex in recommendations) {
        expect(ex.score, isPositive);
        expect(ex.score, lessThanOrEqualTo(ex.objectiveAffinity));
      }
    });
  });

  group('RecommendationService - Get Objectives', () {
    test('Retrieves user objectives correctly', () async {
      final userId = await createUserProfile(
        nom: 'Test',
        prenom: 'Objectifs',
        equipmentIds: [equipmentCorpsId],
        objectives: {objectiveForceId: 1.0, objectiveHypertrophieId: 0.5},
        level: 'debutant',
        age: 20,
      );

      final objectives = await recommendationService.getUserObjectives(userId);

      expect(objectives.length, equals(2));
      expect(
        objectives.map((o) => o.id).toList(),
        containsAll([objectiveForceId, objectiveHypertrophieId]),
      );
    });
  });
}
