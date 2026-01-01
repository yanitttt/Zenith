import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/core/prefs/app_prefs.dart';
import 'package:recommandation_mobile/services/inactivity_service.dart';
import 'package:recommandation_mobile/services/reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard reminder service', () {
    late AppDb db;
    late AppPrefs prefs;
    late ReminderService reminderService;

    setUp(() async {
      /// Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = AppPrefs(sp);

      await prefs.setReminderEnabled(true);
      await prefs.setReminderDays(3);

      /// DB en mémoire
      db = AppDb.forTesting(NativeDatabase.memory());

      /// Créer un utilisateur
      final userId = await db.into(db.appUser).insert(
        AppUserCompanion.insert(
          prenom: const drift.Value('Test'),
        ),
      );

      /// Simuler une séance il y a 4 jours
      final now = DateTime.now();
      await db.into(db.session).insert(
        SessionCompanion.insert(
          userId: userId,
          dateTs:
              now.subtract(const Duration(days: 4)).millisecondsSinceEpoch ~/ 1000,
          durationMin: const drift.Value(60), // 60 minutes
        ),
      );

      final inactivityService = InactivityService(db);

      reminderService = ReminderService(
        inactivityService: inactivityService,
        prefs: prefs,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Affiche un message si inactif depuis X jours', () async {
      final message = await reminderService.getReminderMessage();

      expect(message, isNotNull);
      expect(message, contains('4'));
    });

    test('Ne retourne rien si rappel désactivé', () async {
      await prefs.setReminderEnabled(false);

      final message = await reminderService.getReminderMessage();

      expect(message, isNull);
    });

    test('Ne retourne rien si pas encore le seuil', () async {
      await prefs.setReminderDays(7);

      final message = await reminderService.getReminderMessage();

      expect(message, isNull);
    });
  });
}
