import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../app_db.dart';

class NextSessionExerciseData {
  final String name;
  final String sets;
  final String reps;
  final String load;
  final String type; // 'poly' ou 'iso', pour l'icône

  NextSessionExerciseData(
    this.name,
    this.sets,
    this.reps,
    this.load,
    this.type,
  );
}

class NextSessionData {
  final String dayName;
  final int dayNumber;
  final String monthName;
  final int durationMinutes;
  final String sessionType;
  final List<NextSessionExerciseData> exercises;

  NextSessionData({
    required this.dayName,
    required this.dayNumber,
    required this.monthName,
    required this.durationMinutes,
    required this.sessionType,
    required this.exercises,
  });
}

class ProgramDao {
  final AppDb db;

  ProgramDao(this.db);

  Future<NextSessionData?> getNextSession(int userId) async {
    debugPrint('[PROGRAM_DAO] getNextSession pour user $userId');

    // 1. Récupérer le programme actif
    final userProgram =
        await (db.select(db.userProgram)
              ..where(
                (tbl) => tbl.userId.equals(userId) & tbl.isActive.equals(1),
              )
              ..limit(1))
            .getSingleOrNull();

    if (userProgram == null) {
      debugPrint(
        '[PROGRAM_DAO] Aucun programme actif trouvé pour user $userId',
      );
      return null;
    }
    debugPrint(
      '[PROGRAM_DAO] Programme actif trouvé: ID ${userProgram.programId}',
    );

    // 2. Récupérer tous les jours du programme
    final programDays =
        await (db.select(db.programDay)
              ..where((tbl) => tbl.programId.equals(userProgram.programId))
              ..orderBy([(t) => OrderingTerm.asc(t.dayOrder)]))
            .get();

    if (programDays.isEmpty) {
      debugPrint(
        '[PROGRAM_DAO] Aucun jour trouvé pour le programme ${userProgram.programId}',
      );
      return null;
    }
    debugPrint('[PROGRAM_DAO] ${programDays.length} jours trouvés');

    // 3. Trouver le premier jour non complété
    // On doit vérifier s'il existe une session complétée pour ce jour
    ProgramDayData? nextDay;
    for (final day in programDays) {
      final completedSession =
          await (db.select(db.session)
                ..where(
                  (tbl) =>
                      tbl.programDayId.equals(day.id) &
                      tbl.durationMin
                          .isNotNull(), // Une session complétée a une durée
                )
                ..limit(1))
              .getSingleOrNull();

      if (completedSession == null) {
        debugPrint(
          '[PROGRAM_DAO] Jour ${day.dayOrder} (${day.name}) non complété -> C\'est la prochaine session.',
        );
        nextDay = day;
        break;
      } else {
        debugPrint(
          '[PROGRAM_DAO] Jour ${day.dayOrder} (${day.name}) déjà complété.',
        );
      }
    }

    if (nextDay == null) {
      debugPrint(
        '[PROGRAM_DAO] Tous les jours sont complétés. Programme terminé ?',
      );
      return null; // Programme terminé
    }

    // 4. Récupérer les détails de ce jour (exercices)
    final dayExercises =
        await (db.select(db.programDayExercise)
              ..where((tbl) => tbl.programDayId.equals(nextDay!.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    if (dayExercises.isEmpty) {
      debugPrint(
        '[PROGRAM_DAO] Aucun exercice trouvé pour le jour ${nextDay.id}',
      );
      return null;
    }
    debugPrint(
      '[PROGRAM_DAO] ${dayExercises.length} exercices trouvés pour la prochaine session',
    );

    // 5. Construire les données pour le widget

    // Date prévue : Si 'scheduledDate' est null ou passé, on met la date de demain ou aujourd'hui ?
    // Pour l'affichage, on utilise la date prévue si dispo, sinon "Prochaine séance"
    final date = dayExercises.first.scheduledDate ?? DateTime.now();

    String sessionType = "SÉANCE";
    // Essayer de déduire le type (PUSH, PULL, etc.) depuis le nom ou les exos
    final dayNameUpper = nextDay.name.toUpperCase();
    if (dayNameUpper.contains("HAUT"))
      sessionType = "UPPER";
    else if (dayNameUpper.contains("BAS"))
      sessionType = "LOWER";
    else if (dayNameUpper.contains("FULL"))
      sessionType = "FULL BODY";
    else if (dayNameUpper.contains("PUSH"))
      sessionType = "PUSH";
    else if (dayNameUpper.contains("PULL"))
      sessionType = "PULL";

    final exercises = <NextSessionExerciseData>[];
    for (var i = 0; i < dayExercises.length; i++) {
      final exData = dayExercises[i];
      final exercise =
          await (db.select(db.exercise)
            ..where((t) => t.id.equals(exData.exerciseId))).getSingle();
      final sets = exData.setsSuggestion ?? "? séries";
      final reps = exData.repsSuggestion ?? "? reps";
      final type = exercise.type;
      // Charge: On met une valeur par défaut car pas de "load" dans programDayExercise
      const load = "Charge adaptée";

      exercises.add(
        NextSessionExerciseData(exercise.name, sets, reps, load, type),
      );
    }

    return NextSessionData(
      dayName: _getDayName(date.weekday),
      dayNumber: date.day,
      monthName: _getMonthName(date.month),
      durationMinutes: _estimateDuration(exercises.length),
      sessionType: sessionType,
      exercises: exercises,
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[(month - 1) % 12];
  }

  int _estimateDuration(int exerciseCount) {
    // Estimation grossière : 10 min par exo + échauffement
    return 10 + (exerciseCount * 8);
  }
}
