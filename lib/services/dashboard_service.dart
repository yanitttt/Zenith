import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

class MuscleStat {
  final String muscleName;
  final int count;
  MuscleStat(this.muscleName, this.count);
}

class DashboardData {
  final int streakWeeks;
  final double volumeVariation;
  final double efficiency;
  final Map<String, int> weeklyAttendance;
  final double totalHeures;
  final int totalSeances;
  final List<MuscleStat> muscleStats;
  final double moyennePlaisir;
  final bool hasProgram;

  DashboardData({
    required this.streakWeeks,
    required this.volumeVariation,
    required this.efficiency,
    required this.weeklyAttendance,
    required this.muscleStats,
    required this.totalHeures,
    required this.totalSeances,
    required this.moyennePlaisir,
    required this.hasProgram,
  });
}

class DashboardService {
  final AppDb db;

  DashboardService(this.db);

  int _getStartOfWeekTs() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return startOfDay.millisecondsSinceEpoch ~/ 1000;
  }

  int _getNowTs() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  Future<int> getSessionsRealiseesSemaine(int userId) async {
    final startTs = _getStartOfWeekTs();
    final endTs = _getNowTs();

    final result =
        await db
            .customSelect(
              'SELECT COUNT(*) as cnt FROM session WHERE user_id = ? AND date_ts >= ? AND date_ts <= ?',
              variables: [
                Variable.withInt(userId),
                Variable.withInt(startTs),
                Variable.withInt(endTs),
              ],
              readsFrom: {db.session},
            )
            .getSingle();

    return result.read<int>('cnt');
  }

  Future<int> getDureeTotaleSemaine(int userId) async {
    final startTs = _getStartOfWeekTs();

    final result =
        await db
            .customSelect(
              'SELECT SUM(duration_min) as total_min FROM session WHERE user_id = ? AND date_ts >= ?',
              variables: [Variable.withInt(userId), Variable.withInt(startTs)],
              readsFrom: {db.session},
            )
            .getSingle();

    return result.read<int?>('total_min') ?? 0;
  }

  Future<double> getVolumeTotalSemaine(int userId) async {
    final startTs = _getStartOfWeekTs();

    final result =
        await db
            .customSelect(
              '''
      SELECT SUM(se.sets * se.reps * se.load) as total_vol 
      FROM session_exercise se
      JOIN session s ON se.session_id = s.id
      WHERE s.user_id = ? AND s.date_ts >= ?
      ''',
              variables: [Variable.withInt(userId), Variable.withInt(startTs)],
              readsFrom: {db.session, db.sessionExercise},
            )
            .getSingle();

    return result.read<double?>('total_vol') ?? 0.0;
  }

  Future<int> getNbProgrammesSuivis(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT COUNT(*) as cnt FROM user_program WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.userProgram},
            )
            .getSingle();

    return result.read<int>('cnt');
  }

  Future<String> getProgrammeActifNom(int userId) async {
    final result =
        await db
            .customSelect(
              '''
      SELECT wp.name 
      FROM user_program up
      JOIN workout_program wp ON up.program_id = wp.id
      WHERE up.user_id = ? AND up.is_active = 1
      LIMIT 1
      ''',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.userProgram, db.workoutProgram},
            )
            .getSingleOrNull();

    if (result == null) return "Aucun";
    return result.read<String>('name');
  }

  Future<double> getTotalTonnageAllTime(int userId) async {
    final result =
        await db
            .customSelect(
              '''
      SELECT SUM(se.sets * se.reps * se.load) as total_kg
      FROM session_exercise se
      JOIN session s ON se.session_id = s.id
      WHERE s.user_id = ?
      ''',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.session, db.sessionExercise},
            )
            .getSingle();

    return result.read<double?>('total_kg') ?? 0.0;
  }

  Future<double> getTotalHeuresEntrainement(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT SUM(duration_min) as total_min FROM session WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.session},
            )
            .getSingle();

    final minutes = result.read<int?>('total_min') ?? 0;
    return minutes / 60;
  }

  Future<int> getTotalSeances(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT COUNT(*) as cnt FROM session WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.session},
            )
            .getSingle();
    return result.read<int>('cnt');
  }

  Future<List<MuscleStat>> getRepartitionMusculaire(int userId) async {
    final limitTs =
        DateTime.now()
            .subtract(const Duration(days: 30))
            .millisecondsSinceEpoch ~/
        1000;

    final rows =
        await db
            .customSelect(
              '''
      SELECT m.name as muscle_name, COUNT(*) as frequency
      FROM session s
      JOIN session_exercise se ON s.id = se.session_id
      JOIN exercise_muscle em ON se.exercise_id = em.exercise_id
      JOIN muscle m ON em.muscle_id = m.id
      WHERE s.user_id = ? AND s.date_ts >= ?
      GROUP BY m.name
      ORDER BY frequency DESC
      LIMIT 6
      ''',
              variables: [Variable.withInt(userId), Variable.withInt(limitTs)],
              readsFrom: {
                db.session,
                db.sessionExercise,
                db.exerciseMuscle,
                db.muscle,
              },
            )
            .get();

    return rows.map((row) {
      return MuscleStat(
        row.read<String>('muscle_name'),
        row.read<int>('frequency'),
      );
    }).toList();
  }

  Future<Map<String, int>> getAssiduiteSemaine(int userId) async {
    final now = DateTime.now();
    Map<String, int> result = {};

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));

      final startOfDay =
          DateTime(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 1000;
      final endOfDay = startOfDay + 86400;

      final row =
          await db
              .customSelect(
                'SELECT COUNT(*) as cnt FROM session WHERE user_id = ? AND date_ts >= ? AND date_ts < ?',
                variables: [
                  Variable.withInt(userId),
                  Variable.withInt(startOfDay),
                  Variable.withInt(endOfDay),
                ],
                readsFrom: {db.session},
              )
              .getSingle();

      String dayName = _getDayName(day.weekday);
      result[dayName] = row.read<int>('cnt');
    }
    return result;
  }

  Future<double> getMoyennePlaisir(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT AVG(pleasant) as avg_fun FROM user_feedback WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.userFeedback},
            )
            .getSingle();

    return result.read<double?>('avg_fun') ?? 0.0;
  }

  Future<double> getMoyenneDifficulte(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT AVG(difficult) as avg_diff FROM user_feedback WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.userFeedback},
            )
            .getSingle();

    return result.read<double?>('avg_diff') ?? 0.0;
  }

  Future<double> getPersonalRecord(int userId, int exerciseId) async {
    final result =
        await db
            .customSelect(
              '''
      SELECT MAX(se.load) as max_load
      FROM session_exercise se
      JOIN session s ON se.session_id = s.id
      WHERE s.user_id = ? AND se.exercise_id = ?
      ''',
              variables: [
                Variable.withInt(userId),
                Variable.withInt(exerciseId),
              ],
              readsFrom: {db.session, db.sessionExercise},
            )
            .getSingle();

    return result.read<double?>('max_load') ?? 0.0;
  }

  Future<double> getVolumeVariationPercentage(int userId) async {
    final now = DateTime.now();

    final startCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    final startCurrentWeekTs =
        DateTime(
          startCurrentWeek.year,
          startCurrentWeek.month,
          startCurrentWeek.day,
        ).millisecondsSinceEpoch ~/
        1000;

    final startLastWeek = startCurrentWeek.subtract(const Duration(days: 7));
    final endLastWeek = startCurrentWeek.subtract(const Duration(seconds: 1));

    final startLastWeekTs =
        DateTime(
          startLastWeek.year,
          startLastWeek.month,
          startLastWeek.day,
        ).millisecondsSinceEpoch ~/
        1000;
    final endLastWeekTs =
        DateTime(
          endLastWeek.year,
          endLastWeek.month,
          endLastWeek.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch ~/
        1000;

    final volCurrent = await getVolumeTotalSemaine(userId);

    final resultLast =
        await db
            .customSelect(
              '''
      SELECT SUM(se.sets * se.reps * se.load) as total_vol 
      FROM session_exercise se
      JOIN session s ON se.session_id = s.id
      WHERE s.user_id = ? AND s.date_ts >= ? AND s.date_ts <= ?
      ''',
              variables: [
                Variable.withInt(userId),
                Variable.withInt(startLastWeekTs),
                Variable.withInt(endLastWeekTs),
              ],
              readsFrom: {db.session, db.sessionExercise},
            )
            .getSingle();

    final volLast = resultLast.read<double?>('total_vol') ?? 0.0;

    if (volLast == 0) {
      return volCurrent > 0
          ? 100.0
          : 0.0; // Si on passe de 0 à X, c'est 100% de gain (ou infini, mais on met 100 pour l'UI)
    }

    final variation = ((volCurrent - volLast) / volLast) * 100;
    return double.parse(variation.toStringAsFixed(1));
  }

  Future<int> getCurrentStreakWeeks(int userId) async {
    int streak = 0;
    final now = DateTime.now();

    final sessionsThisWeek = await getSessionsRealiseesSemaine(userId);
    if (sessionsThisWeek > 0) {
      streak++;
    }

    int weeksBack = 1;
    while (true) {
      final d = now.subtract(Duration(days: 7 * weeksBack));

      final startOfWeek = d.subtract(Duration(days: d.weekday - 1));
      final startTs =
          DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          ).millisecondsSinceEpoch ~/
          1000;
      final endTs = startTs + (7 * 24 * 3600) - 1;

      final result =
          await db
              .customSelect(
                'SELECT COUNT(*) as cnt FROM session WHERE user_id = ? AND date_ts >= ? AND date_ts <= ?',
                variables: [
                  Variable.withInt(userId),
                  Variable.withInt(startTs),
                  Variable.withInt(endTs),
                ],
                readsFrom: {db.session},
              )
              .getSingle();

      final count = result.read<int>('cnt');
      if (count > 0) {
        streak++;
        weeksBack++;
      } else {
        break;
      }

      // Sécurité pour pas boucler à l'infini si bug
      if (weeksBack > 520) break; // 10 ans
    }

    return streak;
  }

  Future<double> getTrainingEfficiency(int userId) async {
    final vol = await getVolumeTotalSemaine(userId);
    final duration = await getDureeTotaleSemaine(userId);

    if (duration == 0) return 0.0;

    final eff = vol / duration;
    return double.parse(eff.toStringAsFixed(1));
  }

  Stream<DashboardData> watchDashboardData(int userId) {
    // On écoute plusieurs tables pour déclencher le rafraîchissement
    // "hasProgram" dépend de userProgram
    // Les stats dépendent de session, sessionExercise, userFeedback
    return db
        .customSelect(
          'SELECT 1', // Requête dummy pour le trigger
          readsFrom: {
            db.session,
            db.sessionExercise,
            db.userProgram,
            db.userFeedback,
          },
        )
        .watch()
        .asyncMap((_) async {
          final streak = await getCurrentStreakWeeks(userId);
          final variation = await getVolumeVariationPercentage(userId);
          final efficiency = await getTrainingEfficiency(userId);
          final weeklyAttendance = await getAssiduiteSemaine(userId);
          final muscleStats = await getRepartitionMusculaire(userId);
          final totalHeures = await getTotalHeuresEntrainement(userId);
          final totalSeances = await getTotalSeances(userId);

          return DashboardData(
            streakWeeks: streak,
            volumeVariation: variation,
            efficiency: efficiency,
            weeklyAttendance: weeklyAttendance,
            muscleStats: muscleStats,
            totalHeures: totalHeures,
            totalSeances: totalSeances,
            moyennePlaisir: await getMoyennePlaisir(userId),
            hasProgram: (await getNbProgrammesSuivis(userId)) > 0,
          );
        });
  }
}
