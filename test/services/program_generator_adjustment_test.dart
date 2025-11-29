import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/program_generator_service.dart';
import 'package:recommandation_mobile/services/recommendation_service.dart';

void main() {
  // Déclaration des services et de la base de données
  late AppDb db;
  late ProgramGeneratorService serviceGenerateurProgramme;
  late RecommendationService serviceRecommandation;

  // Configuration avant chaque test
  setUp(() async {
    // Initialisation de la base de données en mémoire pour les tests
    db = AppDb.forTesting(NativeDatabase.memory());
    serviceGenerateurProgramme = ProgramGeneratorService(db);
    serviceRecommandation = RecommendationService(db);
  });

  // Nettoyage après chaque test
  tearDown(() async {
    await db.close();
  });

  test('Le générateur de programme ajuste les suggestions en fonction d\'une mauvaise performance', () async {
    // 1. Configuration de l'Utilisateur et de l'Objectif
    final idObjectif = await db.into(db.objective).insert(
      ObjectiveCompanion.insert(code: 'force', name: 'Force'),
    );

    final idUtilisateur = await db.into(db.appUser).insert(
      AppUserCompanion.insert(
        nom: const Value('Test'),
        prenom: const Value('Utilisateur'),
        level: const Value('debutant'),
      ),
    );

    await db.into(db.userGoal).insert(
      UserGoalCompanion.insert(
        userId: idUtilisateur,
        objectiveId: idObjectif,
        weight: 1.0,
      ),
    );

    // 2. Configuration de l'Exercice (Polyarticulaire)
    final idExercice = await db.into(db.exercise).insert(
      ExerciseCompanion.insert(
        name: 'Développé Couché', // Bench Press
        type: 'poly',
        difficulty: 3,
        cardio: const Value(0.0),
      ),
    );

    // Ajout de l'équipement
    final idEquipement = await db.into(db.equipment).insert(
      EquipmentCompanion.insert(name: 'Barre'), // Barbell
    );
    await db.into(db.exerciseEquipment).insert(
      ExerciseEquipmentCompanion.insert(
        exerciseId: idExercice,
        equipmentId: idEquipement,
      ),
    );
    await db.into(db.userEquipment).insert(
      UserEquipmentCompanion.insert(
        userId: idUtilisateur,
        equipmentId: idEquipement,
      ),
    );

    // Ajout de l'affinité exercice-objectif
    await db.into(db.exerciseObjective).insert(
      ExerciseObjectiveCompanion.insert(
        exerciseId: idExercice,
        objectiveId: idObjectif,
        weight: 1.0,
      ),
    );

    // 3. Création d'un Programme et d'un Jour PASSÉS
    final idProgrammePasse = await db.into(db.workoutProgram).insert(
      WorkoutProgramCompanion.insert(
        name: 'Programme Passé',
        objectiveId: Value(idObjectif),
      ),
    );

    final idJourPasse = await db.into(db.programDay).insert(
      ProgramDayCompanion.insert(
        programId: idProgrammePasse,
        name: 'Jour 1',
        dayOrder: 1,
      ),
    );

    // 4. Insertion de la Suggestion Passée (3 séries, 10 répétitions)
    await db.into(db.programDayExercise).insert(
      ProgramDayExerciseCompanion.insert(
        programDayId: idJourPasse,
        exerciseId: idExercice,
        position: 1,
        setsSuggestion: const Value('3 séries'),
        repsSuggestion: const Value('10 reps'),
      ),
    );

    // 5. Insertion de la Session Passée (Mauvaise performance : 1 série, 1 répétition)
    final idSession = await db.into(db.session).insert(
      SessionCompanion.insert(
        userId: idUtilisateur,
        programDayId: Value(idJourPasse),
        // Date de la session il y a 2 jours
        dateTs: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000,
      ),
    );

    await db.into(db.sessionExercise).insert(
      SessionExerciseCompanion.insert(
        sessionId: idSession,
        exerciseId: idExercice,
        position: 1,
        sets: const Value(1), // 1 série réalisée
        reps: const Value(1), // 1 répétition réalisée
        load: const Value(1.0),
        rpe: const Value(9.0), // RPE élevé pour confirmer la difficulté
      ),
    );

    // 6. Génération du NOUVEAU Programme
    // Cela devrait déclencher la logique de recommandation qui détecte la mauvaise performance
    final idNouveauProgramme = await serviceGenerateurProgramme.generateUserProgram(
      userId: idUtilisateur,
      objectiveId: idObjectif,
      daysPerWeek: 1, // Programme simple d'un jour
      programName: 'Nouveau Programme Adaptatif',
    );

    // 7. Vérification des nouvelles suggestions
    final nouveauxJours = await (db.select(db.programDay)
      ..where((t) => t.programId.equals(idNouveauProgramme)))
        .get();

    expect(nouveauxJours, isNotEmpty);
    final idNouveauJour = nouveauxJours.first.id;

    final nouveauxExercices = await (db.select(db.programDayExercise)
      ..where((t) => t.programDayId.equals(idNouveauJour)))
        .get();

    expect(nouveauxExercices, isNotEmpty);
    final nouvelExercice = nouveauxExercices.firstWhere((e) => e.exerciseId == idExercice);

    print('Nouvelle Suggestion Séries: ${nouvelExercice.setsSuggestion}');
    print('Nouvelle Suggestion Répétitions: ${nouvelExercice.repsSuggestion}');
    print('Nouvelles Notes: ${nouvelExercice.notes}');

    // Par défaut pour un polyarticulaire débutant : 3 séries, 8-10 répétitions.
    // Avec ajustement (performanceRatio < 0.5 -> ajustement de -0.8) :
    // Les séries devraient être réduites de 1 -> 2 séries.
    // Les répétitions devraient être réduites de 2 -> 6-8 répétitions.

    expect(nouvelExercice.setsSuggestion, contains('2')); // Devrait être réduit par rapport à 3
    // La chaîne de répétitions doit être inférieure à 8-10
    expect(nouvelExercice.repsSuggestion, contains('6-8'));
    expect(nouvelExercice.notes, contains('Réduire charge'));
  });
}