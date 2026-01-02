import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../data/db/app_db.dart';
import '../data/db/daos/program_dao.dart';
import '../core/prefs/app_prefs.dart'; // Pour récupérer l'userId courant si dispo
import 'package:shared_preferences/shared_preferences.dart';

class HomeWidgetService {
  final AppDb db;

  HomeWidgetService(this.db);

  Future<void> updateHomeWidget() async {
    try {
      debugPrint('[HOME_WIDGET] === Début updateHomeWidget (Real Data) ===');

      // Récupérer l'ID utilisateur courant (on suppose qu'il est stocké dans les prefs ou on prend le premier/seul user)
      // Comme AppPrefs demande SharedPreferences, on l'instancie
      final sp = await SharedPreferences.getInstance();
      final prefs = AppPrefs(sp);
      final userId = prefs.currentUserId;

      if (userId == null) {
        debugPrint(
          '[HOME_WIDGET] Pas d\'utilisateur connecté, impossible de mettre à jour le widget.',
        );
        return;
      }

      final programDao = ProgramDao(db);
      final nextSession = await programDao.getNextSession(userId);

      if (nextSession == null) {
        debugPrint(
          '[HOME_WIDGET] Aucune prochaine session trouvée. Mise à jour avec message vide.',
        );
        await HomeWidget.saveWidgetData<String>('dayName', 'Aucune');
        await HomeWidget.saveWidgetData<String>('dayNumber', '');
        await HomeWidget.saveWidgetData<String>('monthName', 'séance');
        await HomeWidget.saveWidgetData<String>('durationMinutes', '0');
        await HomeWidget.saveWidgetData<String>('sessionType', 'REPOS');
        await HomeWidget.saveWidgetData<String>(
          'exercise1',
          'Aucune séance programmée\nProfitez de votre repos !',
        );
        await HomeWidget.saveWidgetData<String>('exercise2', '');

        await HomeWidget.updateWidget(
          name: 'SessionWidgetProvider',
          androidName: 'SessionWidgetProvider',
          iOSName: 'SessionWidget',
        );
        return;
      }

      debugPrint(
        '[HOME_WIDGET] Session trouvée: ${nextSession.dayName} ${nextSession.dayNumber}',
      );

      // Utilisation du plugin home_widget pour sauvegarder les données
      // Cela écrit dans le fichier SharedPreferences attendu par le plugin (accessible nativement)

      await HomeWidget.saveWidgetData<String>('dayName', nextSession.dayName);
      await HomeWidget.saveWidgetData<String>(
        'dayNumber',
        nextSession.dayNumber.toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        'monthName',
        nextSession.monthName,
      );
      await HomeWidget.saveWidgetData<String>(
        'durationMinutes',
        nextSession.durationMinutes.toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        'sessionType',
        nextSession.sessionType,
      );

      if (nextSession.exercises.isNotEmpty) {
        final ex1 = nextSession.exercises[0];
        // Formatage pour le widget Android (String simple)
        final ex1Str = "${ex1.name}\n${ex1.sets} / ${ex1.reps} / ${ex1.load}";
        await HomeWidget.saveWidgetData<String>('exercise1', ex1Str);
      } else {
        await HomeWidget.saveWidgetData<String>('exercise1', "");
      }

      if (nextSession.exercises.length > 1) {
        final ex2 = nextSession.exercises[1];
        final ex2Str = "${ex2.name}\n${ex2.sets} / ${ex2.reps} / ${ex2.load}";
        await HomeWidget.saveWidgetData<String>('exercise2', ex2Str);
      } else {
        await HomeWidget.saveWidgetData<String>('exercise2', "");
      }

      // Important: forcer la mise à jour du widget pour repeindre l'UI native
      await HomeWidget.updateWidget(
        name: 'SessionWidgetProvider',
        androidName: 'SessionWidgetProvider',
        iOSName: 'SessionWidget', // Si applicable
      );

      debugPrint(
        '[HOME_WIDGET] === Widget mis à jour avec succès (via home_widget) ===',
      );
    } catch (e, st) {
      debugPrint('[HOME_WIDGET] Erreur lors de la mise à jour du widget: $e');
      debugPrint('[HOME_WIDGET] StackTrace: $st');
    }
  }

  Future<void> initializeWidget() async {
    try {
      // Configurer le groupe de partage iOS si nécessaire
      // await HomeWidget.setAppGroupId('group.your.app');
      await updateHomeWidget();
    } catch (e) {
      debugPrint('[HOME_WIDGET] Erreur lors de l\'initialisation: $e');
    }
  }
}
