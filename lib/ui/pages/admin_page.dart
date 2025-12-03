// lib/ui/pages/admin_page.dart

import 'package:flutter/material.dart';
import 'package:recommandation_mobile/data/db/daos/user_equipment_dao.dart';
import 'package:recommandation_mobile/data/db/daos/user_goal_dao.dart';
import 'package:recommandation_mobile/data/db/daos/user_training_day_dao.dart';

import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';
import '../../services/ImcService.dart';
import 'onboarding/onboarding_flow.dart';
import '../../core/prefs/app_prefs.dart';
import 'edit_user_page.dart';
import '../../services/notification_service.dart';
import '../widgets/training_days_dialog.dart';

class AdminPage extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;
  const AdminPage({super.key, required this.db, required this.prefs});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final UserDao _userDao;
  late final UserGoalDao _goalDao; // DAO pour les objectifs
  late final UserEquipmentDao _equipmentDao; // DAO pour les équipements
  late final UserTrainingDayDao _trainingDayDao;

  @override
  void initState() {
    super.initState();
    _userDao = UserDao(widget.db);
    _goalDao = UserGoalDao(widget.db); // Initialisation
    _equipmentDao = UserEquipmentDao(widget.db); // Initialisation
    _trainingDayDao = UserTrainingDayDao(widget.db);
  }

  Future<void> _confirmAndDelete(int userId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer le profil ?'),
            content: const Text(
              'Cette action effacera entièrement votre profil et vos données. '
              'Voulez-vous continuer ?',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (ok == true) {
      await _userDao.deleteUserCascade(userId);

      await NotificationService().showNotification(
        id: 0,
        title: "Profil Supprimé",
        body: "Votre profil a été supprimé avec succès.",
      );

      await widget.prefs.setCurrentUserId(-1);
      await widget.prefs.setOnboarded(false);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OnboardingFlow(db: widget.db, prefs: widget.prefs),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Text(
                        "Profil",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4B868),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Rafraîchir',
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh, color: AppTheme.gold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Liste
                    Expanded(
                      child: StreamBuilder<List<AppUserData>>(
                        stream: _userDao.watchAllOrdered(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final users = snap.data ?? const <AppUserData>[];
                          if (users.isEmpty) {
                            return const Center(
                              child: Text(
                                'Aucun utilisateur',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: users.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 10),
                            itemBuilder:
                                (_, i) => _UserCard(
                                  u: users[i],
                                  onDelete:
                                      () => _confirmAndDelete(users[i].id),
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  final AppUserData u;
  final VoidCallback? onDelete;

  const _UserCard({required this.u, this.onDelete, Key? key}) : super(key: key);

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  List<int> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _loadTrainingDays();
  }

  Future<void> _loadTrainingDays() async {
    // Accède directement au DAO via l'état du parent
    final dao =
        context.findAncestorStateOfType<_AdminPageState>()!._trainingDayDao;
    final days = await dao.getDayNumbersForUser(widget.u.id);
    if (mounted) {
      setState(() => _selectedDays = days);
    }
  }

  Future<void> _showTrainingDaysDialog() async {
    final tempSelected = List<int>.from(_selectedDays);

    final result = await showDialog<List<int>>(
      context: context,
      builder: (ctx) => TrainingDaysDialog(selectedDays: tempSelected),
    );

    if (result != null) {
      final dao =
          context.findAncestorStateOfType<_AdminPageState>()!._trainingDayDao;
      await dao.replace(widget.u.id, result);
      setState(() => _selectedDays = result);
    }
  }

  String _getDayName(int dayNum) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[dayNum - 1];
  }

  int? _calcAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    int years = now.year - dob.year;
    final hadBirthday =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthday) years--;
    return years;
  }

  String _genderLabel(String? g) {
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

  IconData _genderIcon(String? g) {
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

  @override
  Widget build(BuildContext context) {
    final fullName =
        [
          if ((widget.u.prenom ?? '').trim().isNotEmpty)
            widget.u.prenom!.trim(),
          if ((widget.u.nom ?? '').trim().isNotEmpty) widget.u.nom!.trim(),
        ].join(' ').trim();

    final age = _calcAge(widget.u.birthDate);
    final genderLabel = _genderLabel(widget.u.gender);
    final genderIcon = _genderIcon(widget.u.gender);

    double? imcArrondi;
    String? imcCategory;
    if (widget.u.height != null && widget.u.weight != null) {
      final calc = IMCcalculator(
        height: widget.u.height!,
        weight: widget.u.weight!,
      );
      final imc = calc.calculateIMC();
      imcArrondi = double.parse(imc.toStringAsFixed(2));
      imcCategory = calc.getIMCCategory();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9BE77), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD9BE77),
                  ),
                  child: Icon(
                    genderIcon,
                    size: 28,
                    color: const Color(0xFF0F0F1E),
                  ),
                ),
                const SizedBox(width: 12),
                // Nom et infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty
                            ? 'Utilisateur ${widget.u.id}'
                            : fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$genderLabel${age != null ? " • $age ans" : ""}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section des statistiques compacte
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grille 2x2 ou 2x3 pour les stats
                Row(
                  children: [
                    if (widget.u.height != null)
                      Expanded(
                        child: _StatCard(
                          icon: Icons.height,
                          label: 'Taille',
                          value: '${widget.u.height}',
                          unit: 'cm',
                        ),
                      ),
                    if (widget.u.height != null && widget.u.weight != null)
                      const SizedBox(width: 8),
                    if (widget.u.weight != null)
                      Expanded(
                        child: _StatCard(
                          icon: Icons.monitor_weight,
                          label: 'Poids',
                          value: '${widget.u.weight}',
                          unit: 'kg',
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Deuxième ligne
                Row(
                  children: [
                    if (imcArrondi != null)
                      Expanded(
                        child: _StatCard(
                          icon: Icons.analytics_outlined,
                          label: 'IMC',
                          value: '$imcArrondi',
                          unit: imcCategory ?? '',
                          isLarge: true,
                        ),
                      ),
                    if (imcArrondi != null && widget.u.level != null)
                      const SizedBox(width: 8),
                    if (widget.u.level != null)
                      Expanded(
                        child: _StatCard(
                          icon: Icons.fitness_center,
                          label: 'Niveau',
                          value: widget.u.level!,
                          unit: '',
                        ),
                      ),
                  ],
                ),

                // Métabolisme sur une ligne si disponible
                if (widget.u.metabolism != null &&
                    widget.u.metabolism!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Métabolisme',
                    value: widget.u.metabolism!.trim(),
                    unit: '',
                    isWide: true,
                  ),
                ],

                const SizedBox(height: 12),

                // Boutons d'action compacts
                Row(
                  children: [
                    Expanded(
                      child: _ModernButton(
                        icon: Icons.edit_outlined,
                        label: 'Modifier',
                        isCompact: true,
                        onPressed: () {
                          final adminState =
                              context
                                  .findAncestorStateOfType<_AdminPageState>()!;
                          final db = adminState.widget.db;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => EditProfilePage(
                                    user: widget.u,
                                    db: db,
                                    userDao: adminState._userDao,
                                    goalDao: adminState._goalDao,
                                    equipmentDao: adminState._equipmentDao,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModernButton(
                        icon: Icons.delete_outline,
                        label: 'Supprimer',
                        isCompact: true,
                        isDanger: true,
                        onPressed: widget.onDelete,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Bouton jours d'entraînement
                _ModernButton(
                  icon: Icons.calendar_today_outlined,
                  label:
                      _selectedDays.isEmpty
                          ? "Jours d'entraînement"
                          : _selectedDays.map(_getDayName).join(', '),
                  isCompact: true,
                  onPressed: _showTrainingDaysDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour les cartes de statistiques
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isLarge;
  final bool isWide;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.isLarge = false,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9BE77), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD9BE77), size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Widget pour les boutons compacts
class _ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isCompact;
  final bool isDanger;

  const _ModernButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isCompact = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDanger
            ? Colors.red.shade900.withOpacity(0.3)
            : const Color(0xFF0F0F1E);
    final borderColor =
        isDanger ? Colors.red.shade700 : const Color(0xFFD9BE77);
    final textColor = isDanger ? Colors.red.shade300 : const Color(0xFFD9BE77);

    return Container(
      width: double.infinity,
      height: isCompact ? 42 : 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
