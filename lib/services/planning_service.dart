import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class PlanningItem {
  final int? sessionId;
  final int? programDayId;
  final String title;
  final int duration;
  final bool isDone;
  final bool isScheduled;
  final DateTime date;

  PlanningItem({
    this.sessionId,
    this.programDayId,
    required this.title,
    required this.duration,
    required this.isDone,
    this.isScheduled = false,
    required this.date,
  });
}

class PlanningService {
  final AppDb db;

  PlanningService(this.db);

  Future<List<PlanningItem>> getSessionsForDate(
    int userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final startTs = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfDay.millisecondsSinceEpoch ~/ 1000;

    // 1. Fetch Scheduled Programs First
    final queryScheduled = db.select(db.programDayExercise).join([
      innerJoin(
        db.programDay,
        db.programDay.id.equalsExp(db.programDayExercise.programDayId),
      ),
      innerJoin(
        db.userProgram,
        db.userProgram.programId.equalsExp(db.programDay.programId),
      ),
    ]);

    queryScheduled.where(
      db.programDayExercise.scheduledDate.isBetweenValues(
            startOfDay,
            endOfDay.subtract(const Duration(seconds: 1)),
          ) &
          db.userProgram.userId.equals(userId) &
          db.userProgram.isActive.equals(1),
    );

    final List<PlanningItem> items = [];

    final rowsScheduled = await queryScheduled.get();
    final Map<String, int> scheduledPrograms = {}; // Nom -> ID

    for (final row in rowsScheduled) {
      final pd = row.readTable(db.programDay);
      scheduledPrograms[pd.name] = pd.id;
    }

    // 2. Fetch Done or "Free" Sessions
    final queryDone = db.select(db.session).join([
      leftOuterJoin(
        db.programDay,
        db.programDay.id.equalsExp(db.session.programDayId),
      ),
    ]);

    queryDone.where(
      db.session.userId.equals(userId) &
          db.session.dateTs.isBetweenValues(startTs, endTs),
    );

    final rowsDone = await queryDone.get();
    final Set<String> doneProgramNames = {};

    // First pass to identify what is done
    for (final row in rowsDone) {
      final session = row.readTable(db.session);
      final programDay = row.readTableOrNull(db.programDay);
      if (session.programDayId != null && programDay != null) {
        doneProgramNames.add(programDay.name);
      }
    }

    // Add Scheduled Items First (if not done)
    for (final entry in scheduledPrograms.entries) {
      final pName = entry.key;
      final pId = entry.value;

      if (!doneProgramNames.contains(pName)) {
        items.add(
          PlanningItem(
            sessionId: null,
            programDayId: pId,
            title: pName,
            duration: 0,
            isDone: false,
            isScheduled: true,
            date: startOfDay,
          ),
        );
      }
    }

    // Add Done / Free Sessions Second (so they appear at the end)
    for (final row in rowsDone) {
      final session = row.readTable(db.session);
      final programDay = row.readTableOrNull(db.programDay);

      items.add(
        PlanningItem(
          sessionId: session.id,
          programDayId: session.programDayId,
          title: session.name ?? programDay?.name ?? "Séance Libre",
          duration: session.durationMin ?? 0,
          isDone: true,
          isScheduled: false,
          date: DateTime.fromMillisecondsSinceEpoch(session.dateTs * 1000),
        ),
      );
    }

    // Optional: Sort by ID if multiple free sessions are added to keep them stable?
    // items.sort(...) if needed, but append order is likely sufficient for now.

    return items;
  }

  Future<Set<int>> getDaysWithActivity(int userId, DateTime startOfWeek) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final startTs = startOfWeek.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfWeek.millisecondsSinceEpoch ~/ 1000;

    final daysSet = <int>{};

    final sessions =
        await (db.select(db.session)..where(
          (s) =>
              s.userId.equals(userId) &
              s.dateTs.isBetweenValues(startTs, endTs),
        )).get();

    for (final s in sessions) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.dateTs * 1000);
      daysSet.add(date.weekday);
    }

    final query = db.select(db.programDayExercise).join([
      innerJoin(
        db.programDay,
        db.programDay.id.equalsExp(db.programDayExercise.programDayId),
      ),
      innerJoin(
        db.userProgram,
        db.userProgram.programId.equalsExp(db.programDay.programId),
      ),
    ]);

    query.where(
      db.programDayExercise.scheduledDate.isBetweenValues(
            startOfWeek,
            endOfWeek.subtract(const Duration(seconds: 1)),
          ) &
          db.userProgram.userId.equals(userId) &
          db.userProgram.isActive.equals(1),
    );

    final scheduledRows = await query.get();

    for (final row in scheduledRows) {
      final e = row.readTable(db.programDayExercise);
      if (e.scheduledDate != null) {
        daysSet.add(e.scheduledDate!.weekday);
      }
    }

    return daysSet;
  }
}
