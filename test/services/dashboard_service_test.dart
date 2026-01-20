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
    // In-memory DB
    db = AppDb.forTesting(NativeDatabase.memory());
    service = DashboardService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Test COMPLET de toutes les fonctions du DashboardService', () async {
    // 1. Data Seeding

    // User (ID 1)
    await db
        .into(db.appUser)
        .insert(
          AppUserCompanion.insert(
            singleton: const d.Value(1),
            nom: const d.Value('Alan'),
          ),
        );

    // Muscles & Exercises
    // Muscle: Pectoraux (ID 1)
    final idPecs = await db
        .into(db.muscle)
        .insert(MuscleCompanion.insert(name: 'Pectoraux'));
    // Exercise: Bench Press (ID 1)
    final idBench = await db
        .into(db.exercise)
        .insert(
          ExerciseCompanion.insert(
            name: 'Bench Press',
            type: 'poly',
            difficulty: 3,
          ),
        );
    // Link
    await db
        .into(db.exerciseMuscle)
        .insert(
          ExerciseMuscleCompanion.insert(
            exerciseId: idBench,
            muscleId: idPecs,
            weight: 1.0,
          ),
        );

    // Program Setup
    final idProg = await db
        .into(db.workoutProgram)
        .insert(WorkoutProgramCompanion.insert(name: 'PPL Force'));
    // Enroll user (Active)
    await db
        .into(db.userProgram)
        .insert(
          UserProgramCompanion.insert(
            userId: 1,
            programId: idProg,
            startDateTs: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            isActive: const d.Value(1), // ACTIF
          ),
        );

    // Session History
    final nowTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Session 1: Today (60min)
    final idSession1 = await db
        .into(db.session)
        .insert(
          SessionCompanion.insert(
            userId: 1,
            dateTs: nowTs,
            durationMin: const d.Value(60),
          ),
        );
    // 3 sets x 10 reps @ 100kg = 3000kg
    await db
        .into(db.sessionExercise)
        .insert(
          SessionExerciseCompanion.insert(
            sessionId: idSession1,
            exerciseId: idBench,
            position: 1,
            sets: const d.Value(3),
            reps: const d.Value(10),
            load: const d.Value(100.0),
          ),
        );

    // Session 2: Yesterday (30min)
    final idSession2 = await db
        .into(db.session)
        .insert(
          SessionCompanion.insert(
            userId: 1,
            dateTs: nowTs - 86400, // Hier (-24h)
            durationMin: const d.Value(30),
          ),
        );
    // 1 set x 1 rep @ 120kg (PR) = 120kg
    await db
        .into(db.sessionExercise)
        .insert(
          SessionExerciseCompanion.insert(
            sessionId: idSession2,
            exerciseId: idBench,
            position: 1,
            sets: const d.Value(1),
            reps: const d.Value(1),
            load: const d.Value(120.0),
          ),
        );

    // User Feedback (5/5 Fun, 3/5 Diff)
    await db
        .into(db.userFeedback)
        .insert(
          UserFeedbackCompanion.insert(
            userId: 1,
            exerciseId: idBench,
            liked: 1,
            pleasant: const d.Value(5),
            difficult: const d.Value(3),
            ts: nowTs,
          ),
        );

    // 2. Assertions

    // 1. getSessionsRealiseesSemaine (Expected: 2)
    expect(await service.getSessionsRealiseesSemaine(1), 2);

    // 2. getDureeTotaleSemaine (60+30 = 90)
    expect(await service.getDureeTotaleSemaine(1), 90);

    // 3. getVolumeTotalSemaine (3000 + 120 = 3120)
    expect(await service.getVolumeTotalSemaine(1), 3120.0);

    // 4. getNbProgrammesSuivis
    expect(await service.getNbProgrammesSuivis(1), 1);

    // 5. getProgrammeActifNom
    expect(await service.getProgrammeActifNom(1), "PPL Force");

    // 6. getTotalTonnageAllTime
    expect(await service.getTotalTonnageAllTime(1), 3120.0);

    // 7. getTotalHeuresEntrainement (90min = 1.5h)
    expect(await service.getTotalHeuresEntrainement(1), 1.5);

    // 8. getTotalSeances
    expect(await service.getTotalSeances(1), 2);

    // 9. getRepartitionMusculaire (Expect: Pectoraux x2)
    final muscles = await service.getRepartitionMusculaire(1);
    expect(muscles.isNotEmpty, true);
    expect(muscles.first.muscleName, "Pectoraux");
    expect(muscles.first.count, 2);

    // 10. getAssiduiteSemaine (Sum = 2)
    final graph = await service.getAssiduiteSemaine(1);
    expect(graph.values.reduce((a, b) => a + b), 2);

    // 11. getMoyennePlaisir
    expect(await service.getMoyennePlaisir(1), 5.0);

    // 12. getMoyenneDifficulte
    expect(await service.getMoyenneDifficulte(1), 3.0);

    // 13. getPersonalRecord (120kg)
    expect(await service.getPersonalRecord(1, idBench), 120.0);
  });
}
