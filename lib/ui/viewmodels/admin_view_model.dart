import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../../data/db/daos/user_goal_dao.dart';
import '../../data/db/daos/user_equipment_dao.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../../core/prefs/app_prefs.dart';
import '../../services/notification_service.dart';
import '../../services/ImcService.dart';

class AdminViewModel extends ChangeNotifier {
  final AppDb db;
  final AppPrefs prefs;

  late final UserDao userDao;
  late final UserGoalDao goalDao;
  late final UserEquipmentDao equipmentDao;
  late final UserTrainingDayDao trainingDayDao;

  // Cache pour les jours d'entraînement (userId -> liste de jours)
  final Map<int, List<int>> _trainingDaysCache = {};

  AdminViewModel({required this.db, required this.prefs}) {
    userDao = UserDao(db);
    goalDao = UserGoalDao(db);
    equipmentDao = UserEquipmentDao(db);
    trainingDayDao = UserTrainingDayDao(db);

    // Initialisation unique du stream
    usersStream = userDao.watchAllOrdered();
  }

  /// Stream des utilisateurs pour la mise à jour en temps réel
  late final Stream<List<AppUserData>> usersStream;

  /// Récupère les jours d'entraînement mis en cache pour un utilisateur
  List<int>? getCachedTrainingDays(int userId) {
    return _trainingDaysCache[userId];
  }

  /// Charge les jours d'entraînement d'un utilisateur si nécessaire
  Future<void> loadTrainingDaysIfNeeded(int userId) async {
    if (_trainingDaysCache.containsKey(userId)) return;

    try {
      final days = await trainingDayDao.getDayNumbersForUser(userId);
      _trainingDaysCache[userId] = days;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors du chargement des jours d'entraînement: $e");
    }
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
        await prefs.setCurrentUserId(-1);
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
}
