import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/inactivity_service.dart';

void main() {
  late AppDb db;
  late InactivityService service;

  setUp(() async {
    db = AppDb.forTesting(NativeDatabase.memory());
    service = InactivityService(db);

    // Create user (FK requirement)
    final userId = await db.into(db.appUser).insert(AppUserCompanion.insert());

    // Insert session from yesterday
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    await db
        .into(db.session)
        .insert(
          SessionCompanion.insert(
            userId: userId,
            dateTs: (yesterday.millisecondsSinceEpoch ~/ 1000),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('Retourne la date de la dernière séance', () async {
    final lastSession = await service.getLastSessionDate();

    expect(lastSession, isNotNull);
  });

  test('Retourne le nombre de jours depuis la dernière séance', () async {
    final days = await service.getDaysSinceLastSession();

    expect(days, 1);
  });
}
