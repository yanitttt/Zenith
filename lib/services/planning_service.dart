import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class PlanningItem {
  final int? sessionId;
  final int? programDayId;
  final String title; // "PPL Push" ou "Séance libre"
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

  /// Récupère toutes les séances d'une journée précise (Réalisées + Planifiées)
  Future<List<PlanningItem>> getSessionsForDate(
    int userId,
    DateTime date,
  ) async {
    // 1. Calculer le timestamp de début et fin de la journée (00:00 à 23:59)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final startTs = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfDay.millisecondsSinceEpoch ~/ 1000;

    // --- A. SÉANCES RÉALISÉES ---
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

    final List<PlanningItem> items = [];

    // On garde une trace des programDayId réalisés pour ne pas les afficher en double (prévu + fait)
    final Set<int> doneProgramDayIds = {};
    final Set<String> doneProgramNames = {};

    for (final row in rowsDone) {
      final session = row.readTable(db.session);
      final programDay = row.readTableOrNull(db.programDay);

      if (session.programDayId != null) {
        doneProgramDayIds.add(session.programDayId!);
        if (programDay != null) {
          doneProgramNames.add(programDay.name);
        }
      }

      items.add(
        PlanningItem(
          sessionId: session.id,
          programDayId: session.programDayId,
          title: programDay?.name ?? "Séance Libre",
          duration: session.durationMin ?? 0,
          isDone: true,
          isScheduled: false,
          date: DateTime.fromMillisecondsSinceEpoch(session.dateTs * 1000),
        ),
      );
    }

    // --- B. SÉANCES PLANIFIÉES (via ProgramDayExercise.scheduledDate) ---
    // On cherche les exercices prévus pour ce jour, et on les groupe par ProgramDay

    final queryScheduled = db.select(db.programDayExercise).join([
      innerJoin(
        db.programDay,
        db.programDay.id.equalsExp(db.programDayExercise.programDayId),
      ),
      // Jointure pour vérifier si le programme est actif
      innerJoin(
        db.userProgram,
        db.userProgram.programId.equalsExp(db.programDay.programId),
      ),
    ]);

    // Filtre sur la date exacte ET programme actif
    queryScheduled.where(
      db.programDayExercise.scheduledDate.isBetweenValues(
            startOfDay,
            endOfDay.subtract(const Duration(seconds: 1)),
          ) &
          db.userProgram.userId.equals(userId) &
          db.userProgram.isActive.equals(1),
    );

    final rowsScheduled = await queryScheduled.get();

    // Grouper par NOM de ProgramDay pour éviter les doublons visuels
    final Map<String, int> scheduledPrograms = {}; // Nom -> ID

    for (final row in rowsScheduled) {
      final pd = row.readTable(db.programDay);
      scheduledPrograms[pd.name] = pd.id;
    }

    // Créer les items pour ce qui est prévu MAIS PAS ENCORE FAIT
    for (final entry in scheduledPrograms.entries) {
      final pName = entry.key;
      final pId = entry.value;

      // On vérifie si ce programme (par son nom) n'a pas déjà été fait aujourd'hui
      if (!doneProgramNames.contains(pName)) {
        items.add(
          PlanningItem(
            sessionId: null,
            programDayId: pId,
            title: pName,
            duration: 0, // Pas encore fait
            isDone: false,
            isScheduled: true,
            date: startOfDay, // Date prévue
          ),
        );
      }
    }

    return items;
  }

  /// Récupère une liste de jours où il y a eu activité OU prévu
  Future<Set<int>> getDaysWithActivity(int userId, DateTime startOfWeek) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final startTs = startOfWeek.millisecondsSinceEpoch ~/ 1000;
    final endTs = endOfWeek.millisecondsSinceEpoch ~/ 1000;

    final daysSet = <int>{};

    // 1. Jours avec séances réalisées
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

    // 2. Jours avec séances prévues (UNIQUEMENT PROGRAMMES ACTIFS)
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
