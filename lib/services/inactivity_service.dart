import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class InactivityService {
  final AppDb db;

  InactivityService(this.db);

  /// Retourne la date de la dernière séance ou null
  Future<DateTime?> getLastSessionDate() async {
    final query = (db.select(db.session)
          ..orderBy([
            (s) => OrderingTerm(
                  expression: s.dateTs,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1));

    final lastSession = await query.getSingleOrNull();
    if (lastSession == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      lastSession.dateTs * 1000,
    );
  }

  /// Nombre de jours depuis la dernière séance
  Future<int> getDaysSinceLastSession() async {
    final lastDate = await getLastSessionDate();
    if (lastDate == null) {
      return 999; // Jamais fait de séance
    }

    final now = DateTime.now();
    return now.difference(lastDate).inDays;
  }
}