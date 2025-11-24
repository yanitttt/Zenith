import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class PlanningItem {
  final int sessionId;
  final String title; // "PPL Push" ou "Séance libre"
  final int duration;
  final bool isDone;
  final DateTime date;

  PlanningItem({
    required this.sessionId,
    required this.title,
    required this.duration,
    required this.isDone,
    required this.date,
  });
}

class PlanningService {
  final AppDb db;

  PlanningService(this.db);

  /// Récupère toutes les séances d'une journée précise
  Future<List<PlanningItem>> getSessionsForDate(int userId, DateTime date) async {
    // 1. Calculer le timestamp de début et fin de la journée (00:00 à 23:59)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final startTs = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfDay.millisecondsSinceEpoch ~/ 1000;

    // 2. Requête : On joint Session -> ProgramDay (pour avoir le nom de la séance prévue)
    // Si program_day_id est null, c'est une séance libre.
    final query = db.select(db.session).join([
      leftOuterJoin(db.programDay, db.programDay.id.equalsExp(db.session.programDayId)),
    ]);

    query.where(
      db.session.userId.equals(userId) &
      db.session.dateTs.isBetweenValues(startTs, endTs)
    );

    final rows = await query.get();

    // 3. Mapping vers notre objet simplifié
    return rows.map((row) {
      final session = row.readTable(db.session);
      final programDay = row.readTableOrNull(db.programDay);

      return PlanningItem(
        sessionId: session.id,
        title: programDay?.name ?? "Séance Libre", // Si pas de programme lié
        duration: session.durationMin ?? 0,
        isDone: (session.durationMin ?? 0) > 0, // Dans ta table Session, si elle existe, c'est qu'elle est faite/créée
        date: DateTime.fromMillisecondsSinceEpoch(session.dateTs * 1000),
      );
    }).toList();
  }

  /// Récupère une liste de jours où il y a eu activité (pour mettre des petits points sur le calendrier)
  Future<Set<int>> getDaysWithActivity(int userId, DateTime startOfWeek) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final startTs = startOfWeek.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfWeek.millisecondsSinceEpoch ~/ 1000;

    final sessions = await (db.select(db.session)
      ..where((s) => s.userId.equals(userId) & s.dateTs.isBetweenValues(startTs, endTs))
    ).get();

    // On retourne un Set des numéros de jours (ex: {1, 3, 5} pour lun, mer, ven)
    return sessions.map((s) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.dateTs * 1000);
      return date.weekday; // 1 = Lundi, 7 = Dimanche
    }).toSet();
  }
}