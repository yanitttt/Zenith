import 'package:drift/drift.dart';
import '../data/db/app_db.dart';

/// Petite classe utilitaire pour transporter les données du graphique camembert
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
  final List<MuscleStat> muscleStats;

  DashboardData({
    required this.streakWeeks,
    required this.volumeVariation,
    required this.efficiency,
    required this.weeklyAttendance,
    required this.muscleStats,
  });
}

class DashboardService {
  final AppDb db;

  DashboardService(this.db);

  // =================================================================
  // A. UTILITAIRES DE DATE
  // =================================================================

  /// Timestamp du début de la semaine (Lundi 00:00)
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

  /// Timestamp actuel
  int _getNowTs() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Helper pour les noms de jours (Lun, Mar...)
  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  // =================================================================
  // B. STATS "FOCUS SEMAINE" (Ton code existant)
  // =================================================================

  /// 1. Nombre de séances TERMINÉES cette semaine
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

  /// 2. Durée totale d'entrainement cette semaine (en minutes)
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

  /// 3. Volume total soulevé cette semaine (Tonnage)
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

  // =================================================================
  // C. PROGRAMMES & SUIVI (Ton code existant)
  // =================================================================

  /// 4. Nombre total de programmes suivis (Historique)
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

  /// 5. Récupérer le nom du programme ACTIF
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

  // =================================================================
  // D. STATS GLOBALES (All Time) - NOUVEAU
  // =================================================================

  /// Tonnage Total depuis le début (Somme de tous les kg soulevés)
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

  /// Temps total passé à la salle depuis le début (formatté en "XX h")
  Future<String> getTotalHeuresEntrainement(int userId) async {
    final result =
        await db
            .customSelect(
              'SELECT SUM(duration_min) as total_min FROM session WHERE user_id = ?',
              variables: [Variable.withInt(userId)],
              readsFrom: {db.session},
            )
            .getSingle();

    final minutes = result.read<int?>('total_min') ?? 0;
    final hours = (minutes / 60).toStringAsFixed(1);
    return "$hours h";
  }

  /// Nombre total de séances terminées depuis le début
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

  // =================================================================
  // E. ANALYSE & GRAPHIQUES - NOUVEAU
  // =================================================================

  /// Répartition musculaire (Top 6 muscles) pour Pie Chart
  Future<List<MuscleStat>> getRepartitionMusculaire(int userId) async {
    // Sur les 30 derniers jours pour que ce soit pertinent
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

  /// Assiduité sur les 7 derniers jours (pour Bar Chart)
  /// Retourne Map : {'Lun': 1, 'Mar': 0, ...}
  Future<Map<String, int>> getAssiduiteSemaine(int userId) async {
    final now = DateTime.now();
    Map<String, int> result = {};

    // On boucle sur les 7 derniers jours (J-6 à Aujourd'hui)
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

  // =================================================================
  // F. FEEDBACK & RECORDS - NOUVEAU
  // =================================================================

  /// Moyenne du Feedback "Plaisir" (sur 5)
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

  /// Moyenne du Feedback "Difficulté"
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

  /// Record personnel (Max Load) pour un exercice précis
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
  // =================================================================
  // G. METRIQUES AVANCEES & COMPLEXES - NOUVEAU
  // =================================================================

  /// 1. Variation du Volume (vs Semaine Précédente) en %
  /// Retourne un pourcentage (ex: 15.5 pour +15.5%, -10.0 pour -10%)
  Future<double> getVolumeVariationPercentage(int userId) async {
    final now = DateTime.now();

    // Semaine actuelle
    final startCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    final startCurrentWeekTs =
        DateTime(
          startCurrentWeek.year,
          startCurrentWeek.month,
          startCurrentWeek.day,
        ).millisecondsSinceEpoch ~/
        1000;

    // Semaine précédente
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

    // Volume Semaine Actuelle
    final volCurrent = await getVolumeTotalSemaine(userId);

    // Volume Semaine Précédente
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

  /// 2. Streak (Semaines consécutives avec au moins 1 séance)
  Future<int> getCurrentStreakWeeks(int userId) async {
    int streak = 0;
    final now = DateTime.now();
    // On commence à vérifier à partir de la semaine dernière (car la semaine courante peut être en cours)
    // Si l'utilisateur a fait une séance cette semaine, ça compte pour le streak actuel.

    // Vérifions d'abord cette semaine
    final sessionsThisWeek = await getSessionsRealiseesSemaine(userId);
    if (sessionsThisWeek > 0) {
      streak++;
    }

    // Remonter dans le temps semaine par semaine
    // On commence à -1 semaine
    int weeksBack = 1;
    while (true) {
      final d = now.subtract(Duration(days: 7 * weeksBack));
      // Début de cette semaine là
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
        // Streak brisé
        break;
      }

      // Sécurité pour pas boucler à l'infini si bug
      if (weeksBack > 520) break; // 10 ans
    }

    return streak;
  }

  /// 3. Efficacité d'entraînement (Volume / Minute) cette semaine
  Future<double> getTrainingEfficiency(int userId) async {
    final vol = await getVolumeTotalSemaine(userId);
    final duration = await getDureeTotaleSemaine(userId);

    if (duration == 0) return 0.0;

    final eff = vol / duration;
    return double.parse(eff.toStringAsFixed(1));
  }

  // =================================================================
  // H. STREAMING - NOUVEAU
  // =================================================================

  Stream<DashboardData> watchDashboardData(int userId) {
    // On surveille la table Session (et SessionExercise indirectement via les requêtes)
    return db.select(db.session).watch().asyncMap((_) async {
      final streak = await getCurrentStreakWeeks(userId);
      final variation = await getVolumeVariationPercentage(userId);
      final efficiency = await getTrainingEfficiency(userId);
      final weeklyAttendance = await getAssiduiteSemaine(userId);
      final muscleStats = await getRepartitionMusculaire(userId);

      return DashboardData(
        streakWeeks: streak,
        volumeVariation: variation,
        efficiency: efficiency,
        weeklyAttendance: weeklyAttendance,
        muscleStats: muscleStats,
      );
    });
  }
}
