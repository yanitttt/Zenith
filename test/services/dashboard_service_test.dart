import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;

// Adapte ces imports à ton projet
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/dashboard_service.dart';

void main() {
  late AppDb db;
  late DashboardService service;

  setUp(() {
    // DB en mémoire, vide à chaque lancement
    db = AppDb.forTesting(NativeDatabase.memory());
    service = DashboardService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Test COMPLET de toutes les fonctions du DashboardService', () async {
    // ==============================================================================
    // 1. MISE EN PLACE DES DONNÉES (SEEDING)
    // ==============================================================================

    // --- A. Création de l'utilisateur (ID 1) ---
    await db.into(db.appUser).insert(
      AppUserCompanion.insert(
        singleton: const d.Value(1),
        nom: const d.Value('Alan'),
      ),
    );

    // --- B. Création des Muscles et Exercices ---
    // Muscle ID 1 : Pectoraux
    final idPecs = await db.into(db.muscle).insert(
      MuscleCompanion.insert(name: 'Pectoraux'),
    );
    // Exercice ID 1 : Bench Press (lié aux Pecs)
    final idBench = await db.into(db.exercise).insert(
      ExerciseCompanion.insert(name: 'Bench Press', type: 'poly', difficulty: 3),
    );
    // Liaison Exercice <-> Muscle
    await db.into(db.exerciseMuscle).insert(
      ExerciseMuscleCompanion.insert(exerciseId: idBench, muscleId: idPecs, weight: 1.0),
    );

    // --- C. Création d'un Programme ---
    final idProg = await db.into(db.workoutProgram).insert(
      WorkoutProgramCompanion.insert(name: 'PPL Force'),
    );
    // L'utilisateur suit ce programme (Actif)
    await db.into(db.userProgram).insert(
      UserProgramCompanion.insert(
        userId: 1,
        programId: idProg,
        startDateTs: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        isActive: const d.Value(1), // ACTIF
      ),
    );

    // --- D. Simulation de Séances (Historique) ---
    final nowTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // SÉANCE 1 : Aujourd'hui (Durée 60min)
    final idSession1 = await db.into(db.session).insert(
      SessionCompanion.insert(
        userId: 1,
        dateTs: nowTs,
        durationMin: const d.Value(60),
      ),
    );
    // Perf : 3 séries de 10 reps à 100kg (= 3000kg)
    await db.into(db.sessionExercise).insert(
      SessionExerciseCompanion.insert(
        sessionId: idSession1,
        exerciseId: idBench,
        position: 1,
        sets: const d.Value(3), reps: const d.Value(10), load: const d.Value(100.0),
      ),
    );

    // SÉANCE 2 : Hier (Durée 30min) -> Pour tester l'assiduité et le cumul
    final idSession2 = await db.into(db.session).insert(
      SessionCompanion.insert(
        userId: 1,
        dateTs: nowTs - 86400, // Hier (-24h)
        durationMin: const d.Value(30),
      ),
    );
    // Perf : 1 série de 1 rep à 120kg (PR !) (= 120kg)
    await db.into(db.sessionExercise).insert(
      SessionExerciseCompanion.insert(
        sessionId: idSession2,
        exerciseId: idBench,
        position: 1,
        sets: const d.Value(1), reps: const d.Value(1), load: const d.Value(120.0),
      ),
    );

    // --- E. Feedback (Notes) ---
    // User donne 5/5 en plaisir et 3/5 en difficulté
    await db.into(db.userFeedback).insert(
      UserFeedbackCompanion.insert(
        userId: 1,
        exerciseId: idBench,
        liked: 1,
        pleasant: const d.Value(5),
        difficult: const d.Value(3),
        ts: nowTs,
      ),
    );


    // ==============================================================================
    // 2. VÉRIFICATION DES FONCTIONS (ASSERTIONS)
    // ==============================================================================

    // 1. getSessionsRealiseesSemaine
    // Attendu : 2 séances (aujourd'hui et hier)
    expect(await service.getSessionsRealiseesSemaine(1), 2, reason: "Devrait trouver 2 séances cette semaine");

    // 2. getDureeTotaleSemaine
    // Attendu : 60 + 30 = 90 min
    expect(await service.getDureeTotaleSemaine(1), 90, reason: "60+30 = 90min");

    // 3. getVolumeTotalSemaine
    // Attendu : (3*10*100) + (1*1*120) = 3000 + 120 = 3120 kg
    expect(await service.getVolumeTotalSemaine(1), 3120.0, reason: "Volume total incorrect");

    // 4. getNbProgrammesSuivis
    // Attendu : 1
    expect(await service.getNbProgrammesSuivis(1), 1);

    // 5. getProgrammeActifNom
    // Attendu : "PPL Force"
    expect(await service.getProgrammeActifNom(1), "PPL Force");

    // 6. getTotalTonnageAllTime
    // Attendu : 3120.0 (car c'est la même chose que la semaine ici)
    expect(await service.getTotalTonnageAllTime(1), 3120.0);

    // 7. getTotalHeuresEntrainement
    // Attendu : 90 min = "1.5 h"
    expect(await service.getTotalHeuresEntrainement(1), "1.5 h");

    // 8. getTotalSeances
    // Attendu : 2
    expect(await service.getTotalSeances(1), 2);

    // 9. getRepartitionMusculaire
    // Attendu : Liste contenant au moins "Pectoraux" avec count = 2 (car 2 séances de Bench)
    final muscles = await service.getRepartitionMusculaire(1);
    expect(muscles.isNotEmpty, true);
    expect(muscles.first.muscleName, "Pectoraux");
    expect(muscles.first.count, 2);

    // 10. getAssiduiteSemaine
    // Attendu : Map non vide, doit contenir des valeurs > 0 pour les jours récents
    final graph = await service.getAssiduiteSemaine(1);
    expect(graph.values.reduce((a, b) => a + b), 2, reason: "La somme des barres du graphe doit faire 2");

    // 11. getMoyennePlaisir
    // Attendu : 5.0
    expect(await service.getMoyennePlaisir(1), 5.0);

    // 12. getMoyenneDifficulte
    // Attendu : 3.0
    expect(await service.getMoyenneDifficulte(1), 3.0);

    // 13. getPersonalRecord (PR)
    // Attendu : 120.0 (C'est la max load soulevée lors de la séance 2)
    expect(await service.getPersonalRecord(1, idBench), 120.0, reason: "Le record devrait être 120kg");

  });
}