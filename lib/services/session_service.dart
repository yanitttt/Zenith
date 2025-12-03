import 'dart:math';
import 'package:flutter/material.dart';
import '../data/db/app_db.dart';
import '../data/repositories/exercise_repository.dart';
import '../ui/widgets/session/session_card.dart';


class SessionService {
  final AppDb db;
  SessionService(this.db);


  Future<SessionInfo> getRandomSessionInfo({int exerciseCount = 4}) async {
    try {

      final exerciseRepo = ExerciseRepository(db);
      final allExercises = await exerciseRepo.all();

      if (allExercises.isEmpty) {
        return _getFallbackSession();
      }


      allExercises.shuffle();
      final selectedExercises = allExercises.take(exerciseCount).toList();


      final exerciseItems = selectedExercises.map((e) {
        return ExerciseItem(
          name: e.name,
          sets: '${_randomInt(3, 5)} séries',
          reps: '${_randomInt(6, 12)} répétitions',
          rest: '${_randomInt(1, 3)}min',
          load: '${_randomInt(40, 100)}kg de charge',
          icon: _getExerciseIcon(e.name),
        );
      }).toList();


      final now = DateTime.now();
      final daysOfWeek = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      const monthsOfYear = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];


      final futureDate = now.add(Duration(days: _randomInt(1, 7)));
      final dayName = daysOfWeek[futureDate.weekday % 7];
      final monthName = monthsOfYear[futureDate.month - 1];

      const sessionTypes = ['PUSH', 'PULL', 'LEGS', 'FULL BODY', 'CARDIO'];
      final sessionType = sessionTypes[_randomInt(0, sessionTypes.length - 1)];

      return SessionInfo(
        dayName: dayName,
        dayNumber: futureDate.day,
        monthName: monthName,
        durationMinutes: _randomInt(45, 90),
        sessionType: sessionType,
        exercises: exerciseItems,
      );
    } catch (e) {
      debugPrint('[SESSION_SERVICE] Erreur: $e');
      return _getFallbackSession();
    }
  }


  SessionInfo _getFallbackSession() {
    return SessionInfo(
      dayName: 'Lundi',
      dayNumber: 15,
      monthName: 'Novembre',
      durationMinutes: 60,
      sessionType: 'PUSH',
      exercises: const [
        ExerciseItem(
          name: 'Squat',
          sets: '4 séries',
          reps: '8 répétitions',
          rest: '1min',
          load: '60kg de charge',
          icon: Icons.fitness_center,
        ),
        ExerciseItem(
          name: 'Tapis',
          sets: '4 séries',
          reps: '8 répétitions',
          rest: '1min',
          load: '60kg de charge',
          icon: Icons.self_improvement,
        ),
      ],
    );
  }


  IconData _getExerciseIcon(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();

    if (lowerName.contains('squat') || lowerName.contains('leg')) {
      return Icons.fitness_center;
    } else if (lowerName.contains('bench') || lowerName.contains('press')) {
      return Icons.self_improvement;
    } else if (lowerName.contains('curl') || lowerName.contains('pull')) {
      return Icons.open_in_full;
    } else if (lowerName.contains('row') || lowerName.contains('lat')) {
      return Icons.trending_up;
    } else if (lowerName.contains('deadlift') || lowerName.contains('lift')) {
      return Icons.speed;
    } else if (lowerName.contains('plank') || lowerName.contains('core')) {
      return Icons.favorite;
    } else if (lowerName.contains('dip') || lowerName.contains('trx')) {
      return Icons.catching_pokemon;
    } else if (lowerName.contains('fly') || lowerName.contains('machine')) {
      return Icons.pan_tool;
    }

    return Icons.fit_screen;
  }


  int _randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
}
