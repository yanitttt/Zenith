import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart'
    show innerJoin; // Add specific import or just drift
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../../data/db/daos/user_goal_dao.dart';
import '../../data/db/daos/user_equipment_dao.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../../core/prefs/app_prefs.dart';
import '../../services/notification_service.dart';
import '../../services/ImcService.dart';
import '../../services/gamification_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AppDb db;
  final AppPrefs prefs;

  late final UserDao userDao;
  late final UserGoalDao goalDao;
  late final UserEquipmentDao equipmentDao;
  late final UserTrainingDayDao trainingDayDao;

  // Cache pour les jours d'entraînement (userId -> liste de jours)
  final Map<int, List<int>> _trainingDaysCache = {};
  // Subscriptions pour les mises à jour en temps réel
  final Map<int, StreamSubscription> _trainingDaysSubscriptions = {};
  final Map<int, StreamSubscription> _badgesSubscriptions = {};

  AdminViewModel({required this.db, required this.prefs}) {
    userDao = UserDao(db);
    goalDao = UserGoalDao(db);
    equipmentDao = UserEquipmentDao(db);
    trainingDayDao = UserTrainingDayDao(db);

    // Initialisation unique du stream
    usersStream = userDao.watchAllOrdered();

    // Ensure badges exist (repair if migration failed)
    GamificationService(db).ensureBadgesExist();
  }

  /// Stream des utilisateurs pour la mise à jour en temps réel
  late final Stream<List<AppUserData>> usersStream;

  @override
  void dispose() {
    for (final sub in _trainingDaysSubscriptions.values) {
      sub.cancel();
    }
    for (final sub in _badgesSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }

  /// Récupère les jours d'entraînement mis en cache pour un utilisateur
  List<int>? getCachedTrainingDays(int userId) {
    return _trainingDaysCache[userId];
  }

  /// Charge les jours d'entraînement d'un utilisateur et écoute les changements
  void loadTrainingDaysIfNeeded(int userId) {
    if (_trainingDaysSubscriptions.containsKey(userId)) return;

    // On s'abonne pour avoir les mises à jour en temps réel (ex: modif depuis WorkoutPage)
    final sub = trainingDayDao.watchDayNumbersForUser(userId).listen((days) {
      _trainingDaysCache[userId] = days;
      notifyListeners();
    });

    _trainingDaysSubscriptions[userId] = sub;
  }

  /// Met à jour les jours d'entraînement pour un utilisateur
  Future<void> updateTrainingDays(int userId, List<int> newDays) async {
    try {
      await trainingDayDao.replace(userId, newDays);
      _trainingDaysCache[userId] = newDays;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour des jours d'entraînement: $e");
      rethrow;
    }
  }

  /// Active ou désactive le rappel d'inactivité
  Future<void> toggleReminder(bool enabled) async {
    await prefs.setReminderEnabled(enabled);
    notifyListeners();
  }

  /// Change le nombre de jours pour le rappel d'inactivité
  Future<void> updateReminderDays(int days) async {
    await prefs.setReminderDays(days);
    notifyListeners();
  }

  /// Supprime un utilisateur et ses données associées
  /// Retourne [true] si l'utilisateur supprimé était l'utilisateur courant
  Future<bool> deleteUser(int userId) async {
    try {
      await userDao.deleteUserCascade(userId);

      await NotificationService().showNotification(
        id: 0,
        title: "Profil Supprimé",
        body: "Votre profil a été supprimé avec succès.",
      );

      // Vérifier si c'était l'utilisateur courant
      final currentId = prefs.currentUserId;
      if (currentId == userId) {
        await prefs.clearCurrentUserId();
        await prefs.setOnboarded(false);
        return true; // Indique qu'il faut rediriger vers l'onboarding
      }
      return false;
    } catch (e) {
      debugPrint("Erreur lors de la suppression de l'utilisateur: $e");
      rethrow;
    }
  }

  /// -- Méthodes Utilitaires (Calculs) --
  /// Déplacées ici pour alléger le Widget

  String getFullName(AppUserData u) {
    return [
      if ((u.prenom ?? '').trim().isNotEmpty) u.prenom!.trim(),
      if ((u.nom ?? '').trim().isNotEmpty) u.nom!.trim(),
    ].join(' ').trim();
  }

  String getAgeLabel(DateTime? dob) {
    if (dob == null) return '';
    final now = DateTime.now();
    int years = now.year - dob.year;
    final hadBirthday =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthday) years--;
    return " • $years ans";
  }

  String getGenderLabel(String? g) {
    switch ((g ?? '').toLowerCase()) {
      case 'femme':
      case 'f':
        return 'Femme';
      case 'homme':
      case 'm':
        return 'Homme';
      default:
        return '—';
    }
  }

  IconData getGenderIcon(String? g) {
    switch ((g ?? '').toLowerCase()) {
      case 'femme':
      case 'f':
        return Icons.female;
      case 'homme':
      case 'm':
        return Icons.male;
      default:
        return Icons.help_outline;
    }
  }

  // Retourne (valeurImc, categorie)
  (double?, String?) calculateImc(AppUserData u) {
    if (u.height != null && u.weight != null) {
      final calc = IMCcalculator(height: u.height!, weight: u.weight!);
      final imc = calc.calculateIMC();
      final imcArrondi = double.parse(imc.toStringAsFixed(2));
      final imcCategory = calc.getIMCCategory();
      return (imcArrondi, imcCategory);
    }
    return (null, null);
  }

  String getFormattedDays(List<int> days) {
    if (days.isEmpty) return "Jours d'entraînement";
    const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    // Assurer que les jours sont triés et valides (1-7)
    final sortedDays = List<int>.from(days)..sort();
    return sortedDays
        .where((d) => d >= 1 && d <= 7)
        .map((d) => dayNames[d - 1])
        .join(', ');
  }

  // --- GAMIFICATION ---

  final Map<int, List<GamificationBadgeData>> _badgesCache = {};

  List<GamificationBadgeData>? getCachedUserBadges(int userId) =>
      _badgesCache[userId];

  Future<void> loadUserBadgesIfNeeded(int userId) async {
    if (_badgesSubscriptions.containsKey(userId)) return;

    // Subscribe to stream
    final sub = watchUserBadges(userId).listen((badges) {
      _badgesCache[userId] = badges;
      notifyListeners();
    });
    _badgesSubscriptions[userId] = sub;
  }

  // Reload inutilisé mais gardé pour compatibilité ou force refresh manuel si besoin
  Future<void> reloadUserBadges(int userId) async {
    // Si on a déjà une souscription, elle devrait gérer l'update.
    // Mais on peut forcer une lecture one-shot si vraiment nécessaire.
    // Pour l'instant on laisse vide ou on log.
    debugPrint(
      "Reload demandé, mais le stream gère ça automatiquement maintenant.",
    );
  }

  Future<String> getDebugInfo(int userId) async {
    try {
      final ubCount = await (db.select(db.userBadge)
        ..where((u) => u.userId.equals(userId))).get().then((l) => l.length);
      final gbCount = await db
          .select(db.gamificationBadge)
          .get()
          .then((l) => l.length);
      final sessionCount = await (db.select(db.session)
        ..where((s) => s.userId.equals(userId))).get().then((l) => l.length);
      return "S:$sessionCount | UB:$ubCount | GB:$gbCount";
    } catch (e) {
      return "Err: $e";
    }
  }

  Future<void> checkRetroactiveBadges(int userId) async {
    await GamificationService(db).checkRetroactiveBadges(userId);
  }

  Stream<List<GamificationBadgeData>> watchUserBadges(int userId) {
    final query = db.select(db.userBadge).join([
      innerJoin(
        db.gamificationBadge,
        db.gamificationBadge.id.equalsExp(db.userBadge.badgeId),
      ),
    ])..where(db.userBadge.userId.equals(userId));

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(db.gamificationBadge)).toList();
    });
  }
}
