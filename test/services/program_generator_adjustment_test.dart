import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/program_generator_service.dart';
import 'package:recommandation_mobile/services/recommendation_service.dart';

void main() {
  // Services & DB
  late AppDb db;
  late ProgramGeneratorService serviceGenerateurProgramme;
  late RecommendationService serviceRecommandation;

  // Setup
  setUp(() async {
    // In-memory DB
    db = AppDb.forTesting(NativeDatabase.memory());
    serviceGenerateurProgramme = ProgramGeneratorService(db);
    serviceRecommandation = RecommendationService(db);
  });

  // Cleanup
  tearDown(() async {
    await db.close();
  });

  test(
    'Program generator adapts suggestions based on poor performance',
    () async {
      // 1. Setup User & Goal
      final idObjectif = await db
          .into(db.objective)
          .insert(ObjectiveCompanion.insert(code: 'force', name: 'Force'));

      final idUtilisateur = await db
          .into(db.appUser)
          .insert(
            AppUserCompanion.insert(
              nom: const Value('Test'),
              prenom: const Value('Utilisateur'),
              level: const Value('debutant'),
            ),
          );

      await db
          .into(db.userGoal)
          .insert(
            UserGoalCompanion.insert(
              userId: idUtilisateur,
              objectiveId: idObjectif,
              weight: 1.0,
            ),
          );

      // 2. Setup Exercise (Poly)
      final idExercice = await db
          .into(db.exercise)
          .insert(
            ExerciseCompanion.insert(
              name: 'Développé Couché', // Bench Press
              type: 'poly',
              difficulty: 3,
              cardio: const Value(0.0),
            ),
          );

      // Add Equipment
      final idEquipement = await db
          .into(db.equipment)
          .insert(
            EquipmentCompanion.insert(name: 'Barre'), // Barbell
          );
      await db
          .into(db.exerciseEquipment)
          .insert(
            ExerciseEquipmentCompanion.insert(
              exerciseId: idExercice,
              equipmentId: idEquipement,
            ),
          );
      await db
          .into(db.userEquipment)
          .insert(
            UserEquipmentCompanion.insert(
              userId: idUtilisateur,
              equipmentId: idEquipement,
            ),
          );

      // Link Affirmation
      await db
          .into(db.exerciseObjective)
          .insert(
            ExerciseObjectiveCompanion.insert(
              exerciseId: idExercice,
              objectiveId: idObjectif,
              weight: 1.0,
            ),
          );

      // 3. Create Past Program/Day
      final idProgrammePasse = await db
          .into(db.workoutProgram)
          .insert(
            WorkoutProgramCompanion.insert(
              name: 'Programme Passé',
              objectiveId: Value(idObjectif),
            ),
          );

      final idJourPasse = await db
          .into(db.programDay)
          .insert(
            ProgramDayCompanion.insert(
              programId: idProgrammePasse,
              name: 'Jour 1',
              dayOrder: 1,
            ),
          );

      // 4. Insert Past Suggestion (3 sets, 10 reps)
      await db
          .into(db.programDayExercise)
          .insert(
            ProgramDayExerciseCompanion.insert(
              programDayId: idJourPasse,
              exerciseId: idExercice,
              position: 1,
              setsSuggestion: const Value('3 séries'),
              repsSuggestion: const Value('10 reps'),
            ),
          );

      // 5. Insert Past Session (Poor performance: 1 set, 1 rep)
      final idSession = await db
          .into(db.session)
          .insert(
            SessionCompanion.insert(
              userId: idUtilisateur,
              programDayId: Value(idJourPasse),
              // Date: 2 days ago
              dateTs:
                  DateTime.now()
                      .subtract(const Duration(days: 2))
                      .millisecondsSinceEpoch ~/
                  1000,
            ),
          );

      await db
          .into(db.sessionExercise)
          .insert(
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

      // 6. Generate NEW Program (Should trigger adaptation logic)
      final idNouveauProgramme = await serviceGenerateurProgramme
          .generateUserProgram(
            userId: idUtilisateur,
            objectiveId: idObjectif,
            daysPerWeek: 1, // Programme simple d'un jour
            programName: 'Nouveau Programme Adaptatif',
          );

      // 7. Verify Suggestions
      final nouveauxJours =
          await (db.select(db.programDay)
            ..where((t) => t.programId.equals(idNouveauProgramme))).get();

      expect(nouveauxJours, isNotEmpty);
      final idNouveauJour = nouveauxJours.first.id;

      final nouveauxExercices =
          await (db.select(db.programDayExercise)
            ..where((t) => t.programDayId.equals(idNouveauJour))).get();

      expect(nouveauxExercices, isNotEmpty);
      final nouvelExercice = nouveauxExercices.firstWhere(
        (e) => e.exerciseId == idExercice,
      );

      // Expectation:
      // Default (Beginner Poly) = 3 sets, 8-10 reps.
      // Adjusted (Perf < 0.5 => -0.8 adj) -> Reduced sets/reps & "Reduce Load" note.

      expect(nouvelExercice.setsSuggestion, contains('2')); // Reduced from 3
      // Reps should be < 8-10
      expect(nouvelExercice.repsSuggestion, contains('6-8'));
      expect(nouvelExercice.notes, contains('Réduire charge'));
    },
  );
}
