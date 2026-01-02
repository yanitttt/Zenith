import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db/app_db.dart';
import '../data/db/daos/program_dao.dart';
import '../core/prefs/app_prefs.dart';

// --- Constants (OCP/Maintenance) ---
class WidgetKeys {
  static const String widgetState = 'widget_state';
  static const String dayName = 'dayName';
  static const String dayNumber = 'dayNumber';
  static const String monthName = 'monthName';
  static const String duration = 'durationMinutes';
  static const String type = 'sessionType';
  static const String exercise1 = 'exercise1';
  static const String exercise2 = 'exercise2';
}

// --- States (Explicit State Management) ---
class WidgetState {
  static const String newUser = 'new_user';
  static const String session = 'session';
  static const String empty = 'empty';
}

class HomeWidgetService {
  final AppDb db;

  HomeWidgetService(this.db);

  /// Entry point to update the widget.
  /// Designed to be battery-efficient: only fetches necessary data and pushes changes.
  Future<void> updateHomeWidget() async {
    debugPrint('[HOME_WIDGET] === Début updateHomeWidget (Optimized) ===');

    // Lazy load deps to keep startup fast
    final sp = await SharedPreferences.getInstance();
    final prefs = AppPrefs(sp);
    final userId = prefs.currentUserId;

    if (userId == null) {
      debugPrint('[HOME_WIDGET] Pas d\'utilisateur connecté. Abort.');
      return;
    }

    final programDao = ProgramDao(db);

    try {
      // 1. Fetch Data
      final nextSession = await programDao.getNextSession(userId);

      // 2. Determine State & Data to Save
      final Map<String, dynamic> dataToSave = {};

      if (nextSession != null) {
        // STATE: SESSION
        debugPrint(
          '[HOME_WIDGET] Session trouvée. State: ${WidgetState.session}',
        );
        dataToSave[WidgetKeys.widgetState] = WidgetState.session;
        dataToSave[WidgetKeys.dayName] = nextSession.dayName;
        dataToSave[WidgetKeys.dayNumber] =
            nextSession.dayNumber.toString(); // Fix: Save as String
        dataToSave[WidgetKeys.monthName] = nextSession.monthName;
        dataToSave[WidgetKeys.duration] =
            nextSession.durationMinutes.toString(); // Fix: Save as String
        dataToSave[WidgetKeys.type] = nextSession.sessionType;

        // Format exercises efficiently
        if (nextSession.exercises.isNotEmpty) {
          dataToSave[WidgetKeys.exercise1] = _formatExercise(
            nextSession.exercises[0],
          );
        } else {
          dataToSave[WidgetKeys.exercise1] = "";
        }

        if (nextSession.exercises.length > 1) {
          dataToSave[WidgetKeys.exercise2] = _formatExercise(
            nextSession.exercises[1],
          );
        } else {
          dataToSave[WidgetKeys.exercise2] = "";
        }
      } else {
        // No next session. Check if New User or Finished.
        final hasProgram = await programDao.hasAnyProgram(userId);
        if (!hasProgram) {
          // STATE: NEW USER
          debugPrint(
            '[HOME_WIDGET] Aucune historique. State: ${WidgetState.newUser}',
          );
          dataToSave[WidgetKeys.widgetState] = WidgetState.newUser;
        } else {
          // STATE: EMPTY (Rest/Finished)
          debugPrint(
            '[HOME_WIDGET] Programme terminé/Repos. State: ${WidgetState.empty}',
          );
          dataToSave[WidgetKeys.widgetState] = WidgetState.empty;
          dataToSave[WidgetKeys.dayName] = "Aucune";
          dataToSave[WidgetKeys.exercise1] = "Aucune séance programmée";
          dataToSave[WidgetKeys.exercise2] = "Profitez de votre repos !";
          dataToSave[WidgetKeys.type] = "REPOS";
        }
      }

      // 3. Batched Save (Performance)
      await _saveData(dataToSave);

      // 4. Notify Native Widget
      await HomeWidget.updateWidget(
        name: 'SessionWidgetProvider',
        androidName: 'SessionWidgetProvider',
        iOSName: 'SessionWidget',
      );

      debugPrint('[HOME_WIDGET] Mise à jour terminée avec succès.');
    } catch (e, stack) {
      debugPrint('[HOME_WIDGET] Erreur critique: $e\n$stack');
    }
  }

  String _formatExercise(NextSessionExerciseData ex) {
    return "${ex.name}\n${ex.sets} / ${ex.reps} / ${ex.load}";
  }

  Future<void> _saveData(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
    }
  }

  Future<void> initializeWidget() async {
    await updateHomeWidget();
  }
}
