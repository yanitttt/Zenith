import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db/app_db.dart';
import 'session_service.dart';

/// Service pour gérer les données du widget Android d'écran d'accueil
/// Sauvegarde directement dans SharedPreferences sans passer par home_widget package
class HomeWidgetService {
  final AppDb db;

  HomeWidgetService(this.db);

  /// Met à jour le widget avec les données de la prochaine séance
  Future<void> updateHomeWidget() async {
    try {
      debugPrint('[HOME_WIDGET] === Début updateHomeWidget ===');

      final sessionService = SessionService(db);
      debugPrint('[HOME_WIDGET] SessionService créé');

      final sessionInfo = await sessionService.getRandomSessionInfo(exerciseCount: 2);
      debugPrint('[HOME_WIDGET] SessionInfo récupéré: ${sessionInfo.dayName}');

      final prefs = await SharedPreferences.getInstance();
      debugPrint('[HOME_WIDGET] SharedPreferences getInstance OK');

      // Sauvegarder les données directement dans SharedPreferences
      // Ces données seront lues par le widget Android natif via SessionWidgetProvider
      debugPrint('[HOME_WIDGET] Sauvegarde dayName: ${sessionInfo.dayName}');
      await prefs.setString('dayName', sessionInfo.dayName);

      await prefs.setInt('dayNumber', sessionInfo.dayNumber);
      debugPrint('[HOME_WIDGET] Sauvegarde dayNumber: ${sessionInfo.dayNumber}');

      await prefs.setString('monthName', sessionInfo.monthName);
      debugPrint('[HOME_WIDGET] Sauvegarde monthName: ${sessionInfo.monthName}');

      await prefs.setInt('durationMinutes', sessionInfo.durationMinutes);
      debugPrint('[HOME_WIDGET] Sauvegarde durationMinutes: ${sessionInfo.durationMinutes}');

      await prefs.setString('sessionType', sessionInfo.sessionType);
      debugPrint('[HOME_WIDGET] Sauvegarde sessionType: ${sessionInfo.sessionType}');

      // Sauvegarder les exercices
      if (sessionInfo.exercises.isNotEmpty) {
        final ex1 = sessionInfo.exercises[0];
        final ex1Str = '${ex1.name}\n${ex1.sets} / ${ex1.reps} / ${ex1.load}';
        await prefs.setString('exercise1', ex1Str);
        debugPrint('[HOME_WIDGET] Sauvegarde exercise1: $ex1Str');
      }

      if (sessionInfo.exercises.length > 1) {
        final ex2 = sessionInfo.exercises[1];
        final ex2Str = '${ex2.name}\n${ex2.sets} / ${ex2.reps} / ${ex2.load}';
        await prefs.setString('exercise2', ex2Str);
        debugPrint('[HOME_WIDGET] Sauvegarde exercise2: $ex2Str');
      }

      // Vérification: relire ce qu'on vient d'écrire
      final readCheck = prefs.getString('dayName');
      debugPrint('[HOME_WIDGET] VÉRIF: Relecture dayName = $readCheck');

      debugPrint('[HOME_WIDGET] === Widget mis à jour avec succès ===');
    } catch (e, st) {
      debugPrint('[HOME_WIDGET] Erreur lors de la mise à jour du widget: $e');
      debugPrint('[HOME_WIDGET] StackTrace: $st');
    }
  }

  /// Initialise le widget avec des données par défaut
  Future<void> initializeWidget() async {
    try {
      await updateHomeWidget();
    } catch (e) {
      debugPrint('[HOME_WIDGET] Erreur lors de l\'initialisation: $e');
    }
  }
}
