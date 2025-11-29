// lib/ui/pages/admin_page.dart
import 'package:flutter/material.dart';
import 'package:recommandation_mobile/data/db/daos/user_training_day_dao.dart';
import 'package:recommandation_mobile/ui/pages/onboarding/profile_basics_page.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';
import '../../services/ImcService.dart';
import 'onboarding/onboarding_flow.dart';
import '../../core/prefs/app_prefs.dart';
import '../../services/notification_service.dart';

class AdminPage extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;
  const AdminPage({
    super.key,
    required this.db,
    required this.prefs,  // <-- AJOUT
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final UserDao _userDao;
  late final UserTrainingDayDao _trainingDayDao;

  @override
  void initState() {
    super.initState();
    _userDao = UserDao(widget.db);
    _trainingDayDao = UserTrainingDayDao(widget.db);
  }

  Future<void> _confirmAndDelete(int userId) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer le profil ?'),
      content: const Text(
        'Cette action effacera entièrement votre profil et vos données. '
        'Voulez-vous continuer ?',
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.gold,
          ),
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

  // Reset prefs
  await widget.prefs.setCurrentUserId(-1); // utiliser -1 plutôt que null
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
                      padding:  EdgeInsets.only(left: 18),
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
                    tooltip: 'Tester les notifications',
                    onPressed: () async {
                      await NotificationService().showNotification(
                        id: 1,
                        title: "Test Notification",
                        body: "Le service de notification fonctionne correctement !",
                      );
                    },
                    icon: const Icon(Icons.notifications_active, color: AppTheme.gold),
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
                    // Bandeau stats


                    // Liste
                    Expanded(
                      child: StreamBuilder<List<AppUserData>>(
                        stream: _userDao.watchAllOrdered(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final users = snap.data ?? const <AppUserData>[];
                          if (users.isEmpty) {
                            return const Center(
                              child: Text('Aucun utilisateur', style: TextStyle(color: Colors.white70)),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: users.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _UserCard(
                              u: users[i],
                              onDelete: () => _confirmAndDelete(users[i].id),
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

  const _UserCard({
    required this.u,
    this.onDelete,
    Key? key,
  }) : super(key: key);

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
    final dao = context.findAncestorStateOfType<_AdminPageState>()!._trainingDayDao;
    final days = await dao.getDayNumbersForUser(widget.u.id);
    if (mounted) {
      setState(() => _selectedDays = days);
    }
  }

  Future<void> _showTrainingDaysDialog() async {
    final tempSelected = List<int>.from(_selectedDays);

    final result = await showDialog<List<int>>(
      context: context,
      builder: (ctx) => _TrainingDaysDialog(selectedDays: tempSelected),
    );

    if (result != null) {
      final dao = context.findAncestorStateOfType<_AdminPageState>()!._trainingDayDao;
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
        (now.month > dob.month) || (now.month == dob.month && now.day >= dob.day);
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
    final fullName = [
      if ((widget.u.prenom ?? '').trim().isNotEmpty) widget.u.prenom!.trim(),
      if ((widget.u.nom ?? '').trim().isNotEmpty) widget.u.nom!.trim(),
    ].join(' ').trim();

    final age = _calcAge(widget.u.birthDate);
    final genderLabel = _genderLabel(widget.u.gender);
    final genderIcon = _genderIcon(widget.u.gender);

    double? imcArrondi;
    String? imcCategory;
    if (widget.u.height != null && widget.u.weight != null) {
      final calc = IMCcalculator(height: widget.u.height!, weight: widget.u.weight!);
      final imc = calc.calculateIMC();
      imcArrondi = double.parse(imc.toStringAsFixed(2));
      imcCategory = calc.getIMCCategory();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD9BE77),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // En-tête du profil compact
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
                // Avatar simple
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
                        fullName.isEmpty ? 'Utilisateur ${widget.u.id}' : fullName,
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
                if (widget.u.metabolism != null && widget.u.metabolism!.trim().isNotEmpty) ...[
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
                          final parent = context.findAncestorStateOfType<_AdminPageState>()!;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfileBasicsPage(
                                initialPrenom: widget.u.prenom ?? "",
                                initialNom: widget.u.nom ?? "",
                                initialBirthDate: widget.u.birthDate,
                                initialWeight: widget.u.weight,
                                initialHeight: widget.u.height,
                                initialGender: (widget.u.gender == "homme") ? Gender.homme : Gender.femme,
                                onNext: ({
                                  required String prenom,
                                  required String nom,
                                  required DateTime birthDate,
                                  required double weight,
                                  required double height,
                                  required Gender gender,
                                }) async {
                                  final updated = widget.u.copyWith(
                                    prenom: Value(prenom),
                                    nom: Value(nom),
                                    birthDate: Value(birthDate),
                                    weight: Value(weight),
                                    height: Value(height),
                                    gender: Value(gender == Gender.homme ? "homme" : "femme"),
                                  );
                                  await parent._userDao.updateOne(updated);
                                  Navigator.pop(context);
                                },
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
                  label: _selectedDays.isEmpty
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
    );  }
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
        border: Border.all(
          color: const Color(0xFFD9BE77),
          width: 1,
        ),
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
    final backgroundColor = isDanger
        ? Colors.red.shade900.withOpacity(0.3)
        : const Color(0xFF0F0F1E);
    final borderColor = isDanger
        ? Colors.red.shade700
        : const Color(0xFFD9BE77);
    final textColor = isDanger
        ? Colors.red.shade300
        : const Color(0xFFD9BE77);

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

// Widget de dialog pour sélectionner les jours d'entraînement
class _TrainingDaysDialog extends StatefulWidget {
  final List<int> selectedDays;

  const _TrainingDaysDialog({required this.selectedDays});

  @override
  State<_TrainingDaysDialog> createState() => _TrainingDaysDialogState();
}

class _TrainingDaysDialogState extends State<_TrainingDaysDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedDays);
  }

  void _toggleDay(int dayNum) {
    setState(() {
      if (_tempSelected.contains(dayNum)) {
        _tempSelected.remove(dayNum);
      } else {
        _tempSelected.add(dayNum);
      }
      _tempSelected.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return Dialog(
      backgroundColor: const Color(0xFF020216),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD9BE77), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFD9BE77), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Jours d\'entraînement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD9BE77),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez les jours où vous souhaitez vous entraîner',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _tempSelected.contains(dayNum);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _toggleDay(dayNum),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD9BE77).withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD9BE77) : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? const Color(0xFFD9BE77) : Colors.white54,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD9BE77),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, _tempSelected),
                    child: const Text('Valider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}