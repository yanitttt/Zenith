import '../core/prefs/app_prefs.dart';
import 'inactivity_service.dart';

class ReminderService {
  final AppPrefs prefs;
  final InactivityService inactivityService;

  ReminderService({
    required this.prefs,
    required this.inactivityService,
  });

  /// Retourne le message à afficher ou null
  Future<String?> getReminderMessage() async {
    if (!prefs.reminderEnabled) return null;

    final lastDate = await inactivityService.getLastSessionDate();
    if (lastDate == null) {
      return "Vous n'avez encore jamais fait de séance.";
    }

    final days = await inactivityService.getDaysSinceLastSession();

    if (days >= prefs.reminderDays) {
      return "Dernière séance : ${lastDate.toLocal().toString().split(' ')[0]} "
          "— $days jours sans entraînement. Il est temps de reprendre!";
    }

    return null;
  }
}
