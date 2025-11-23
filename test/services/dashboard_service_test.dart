import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart'; 
import 'package:drift/drift.dart' as d; 

// --- CORRECTION DES IMPORTS SELON TON IMAGE ---
// 1. Import de la Database (dans lib/data/db/app_db.dart)
import 'package:recommandation_mobile/data/db/app_db.dart'; 

// 2. Import du Service (Doit être dans lib/services/dashboard_service.dart)
// Vérifie bien que tu as mis le fichier dashboard_service.dart dans le dossier "services" jaune !
import 'package:recommandation_mobile/services/dashboard_service.dart';

void main() {
  late AppDb db;
  late DashboardService service;

  setUp(() {
    // Création de la BDD en mémoire pour le test
    db = AppDb.forTesting(NativeDatabase.memory());
    service = DashboardService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Tests du DashboardService', () {
    
    test('Calcul du Tonnage et des Séances', () async {
      // --- 1. SETUP DES DONNÉES ---
      
      // Création de l'utilisateur (Singleton ID 1)
      await db.into(db.appUser).insert(
        AppUserCompanion.insert(
          singleton: const d.Value(1),
          // Si tu as d'autres champs obligatoires dans AppUser, ajoute-les ici :
          // nom: const d.Value('Test'),
        ),
      );

      // Création d'un Exercice
      final exoId = await db.into(db.exercise).insert(
        ExerciseCompanion.insert(name: 'Bench Press', type: 'poly', difficulty: 3),
      );

      // Création d'une Séance (Aujourd'hui)
      final nowTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final sessionId = await db.into(db.session).insert(
        SessionCompanion.insert(
          userId: 1, 
          dateTs: nowTs,
          durationMin: const d.Value(60),
        ),
      );

      // Création des stats de l'exercice (3 séries x 10 reps x 100kg)
      await db.into(db.sessionExercise).insert(
        SessionExerciseCompanion.insert(
          sessionId: sessionId,
          exerciseId: exoId,
          position: 1,
          sets: const d.Value(3),
          reps: const d.Value(10),
          load: const d.Value(100.0),
        ),
      );

      // --- 2. EXECUTION ---
      final tonnage = await service.getVolumeTotalSemaine(1);
      final nbSeances = await service.getSessionsRealiseesSemaine(1);

      // --- 3. VERIFICATION ---
      // 3 * 10 * 100 = 3000
      expect(tonnage, 3000.0, reason: "Le tonnage devrait être de 3000kg");
      expect(nbSeances, 1, reason: "Il devrait y avoir 1 séance");
    });
  });
}