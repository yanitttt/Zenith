import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

import '../data/db/app_db.dart';
import 'inactivity_service.dart';
import 'notification_service.dart';

// Nom de la tâche unique pour le WorkManager
const String _inactivityTaskKey = "com.recommandation_mobile.inactivity_check";

// Paramètre configurable : seuil d'inactivité avant notif
// Modifier ici pour tester en minutes (ex: Duration(minutes: 10)) ou en jours (ex: Duration(days: 7))
const Duration INACTIVITY_THRESHOLD = Duration(minutes: 2);

// Entry point pour la background task (Doit être top-level ou static)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case _inactivityTaskKey:
        print("[BackgroundService] Exécution de la tâche d'inactivité...");
        try {
          // 1. Initialiser la DB (Nécessaire car on est dans un nouvel Isolate)
          final db = AppDb();

          // 2. Initialiser les services
          final inactivityService = InactivityService(db);
          final notificationService = NotificationService();

          // Initialisation nécessaire pour les notifs en background
          await notificationService.init();

          // 3. Vérifier la date de dernière séance
          final lastSessionDate = await inactivityService.getLastSessionDate();

          if (lastSessionDate != null) {
            final now = DateTime.now();
            final difference = now.difference(lastSessionDate);

            print(
              "[BackgroundService] Derniere session: $lastSessionDate (Duration: $difference)",
            );

            if (difference >= INACTIVITY_THRESHOLD) {
              // Vérification supplémentaire pour éviter le spam
              // On pourrait stocker la date de dernière notif dans SharedPreferences si besoin.
              // Ici, on envoie simplement si la condition est remplie.

              // Formatage du message selon la durée
              final timeString =
                  difference.inDays >= 1
                      ? "${difference.inDays} jours"
                      : "${difference.inMinutes} minutes";

              await notificationService.showNotification(
                id: 1001, // ID fixe pour remplacer la notif précédente si elle est encore là
                title: "On ne lâche rien !",
                body:
                    "Attention, cela fait $timeString que vous n'avez pas fait votre sport. Revenez vite !",
              );
              print("[BackgroundService] Notification envoyée !");
            }
          } else {
            // Cas où l'utilisateur n'a jamais fait de séance.
            // On peut décider de ne rien faire ou d'envoyer un message d'encouragement au début.
            print("[BackgroundService] Pas de session trouvée.");
          }

          // Fermeture propre de la DB
          await db.close();
        } catch (e, stack) {
          print("[BackgroundService] Erreur: $e");
          print(stack);
          return Future.value(false);
        }
        break;
    }
    return Future.value(true);
  });
}

class BackgroundService {
  // Singleton
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  /// Initialise le WorkManager et planifie la tâche périodique
  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode, // Utile pour voir les logs en dev
    );

    // On planifie une tâche périodique qui tourne 1 fois par jour
    // Note: Android impose un minimum de 15 minutes.
    await Workmanager().registerPeriodicTask(
      "1", // Unique name
      _inactivityTaskKey,
      frequency: const Duration(minutes: 15), // Minimum Android pour périodique
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy:
          ExistingPeriodicWorkPolicy
              .keep, // Evite de replanifier si existe dejà
    );
    print("[BackgroundService] Service initialisé et tâche planifiée.");
  }

  /// Permet de forcer une annulation si besoin
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
