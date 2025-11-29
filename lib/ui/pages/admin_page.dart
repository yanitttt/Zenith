// lib/ui/pages/admin_page.dart
import 'package:flutter/material.dart';
import 'package:recommandation_mobile/data/db/daos/user_equipment_dao.dart';
import 'package:recommandation_mobile/data/db/daos/user_goal_dao.dart';
import 'package:recommandation_mobile/data/db/daos/user_training_day_dao.dart';
import 'package:recommandation_mobile/ui/pages/onboarding/profile_basics_page.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';
import '../../services/ImcService.dart';
import 'onboarding/onboarding_flow.dart';
import '../../core/prefs/app_prefs.dart';
import 'edit_user_page.dart';
import '../../services/notification_service.dart';
import 'onboarding/profile_basics_page.dart';

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
  late final UserGoalDao _goalDao;
  late final UserEquipmentDao _equipmentDao;
  late final UserTrainingDayDao _trainingDayDao;

  @override
  void initState() {
    super.initState();
    _userDao = UserDao(widget.db);
    _goalDao = UserGoalDao(widget.db);
    _equipmentDao = UserEquipmentDao(widget.db);
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

  // ---------- helpers présentation ----------
  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
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
    final title = [
      if ((widget.u.prenom ?? '').trim().isNotEmpty) widget.u.prenom!.trim(),
      if ((widget.u.nom ?? '').trim().isNotEmpty) widget.u.nom!.trim(),
    ].join(' ').trim();

    final lines = <String>[];
    lines.add('id=${widget.u.id}');
    if (widget.u.level != null) lines.add('niveau=${widget.u.level}');
    if (widget.u.weight != null) lines.add('poids=${widget.u.weight}kg');
    if (widget.u.height != null) lines.add('taille=${widget.u.height}cm');
    if (widget.u.metabolism != null && widget.u.metabolism!.trim().isNotEmpty) {
      lines.add('métabolisme=${widget.u.metabolism}');
    }
    final subtitle = lines.join('  •  ');

    final age = _calcAge(widget.u.birthDate);
    final birth = widget.u.birthDate != null ? _fmtDate(widget.u.birthDate!) : null;
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

    return Padding(
  padding: const EdgeInsets.all(12),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFD9BE77), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
//                    Text(
//                      title.isEmpty ? '' : title,
//                      maxLines: 1,
//                      overflow: TextOverflow.ellipsis,
//                      style: const TextStyle(
//                        fontWeight: FontWeight.w800,
//                        fontSize: 16,
//                      ),
//                    ),
//                  const SizedBox(height: 4),
//                  if (subtitle.isNotEmpty)
//                    Text(
//                      subtitle,
//                      maxLines: 2,
//                      overflow: TextOverflow.ellipsis,
//                      style: const TextStyle(
//                        color: Colors.white70,
//                        fontSize: 12.5,
//                        height: 1.2,
//                      ),
//                    ),
                  const SizedBox(height: 8),

                  // Chips infos: genre / naissance / âge / IMC
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [

                      // Prénom person_outline
                      if ((widget.u.prenom ?? '').trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                widget.u.prenom!.trim(),
                                style: const TextStyle(
                                  fontSize: 18, // texte agrandi
                                  fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Nom badge_outlined
                      if ((widget.u.nom ?? '').trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                widget.u.nom!.trim(),
                                style: const TextStyle(
                                  fontSize: 18, // texte agrandi
                                  fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                ),
                              ),
                            ],
                          ),
                        ),
//Age
 
                      if (age != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cake_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$age ans',
                                style: const TextStyle(
                                  fontSize: 18, // texte agrandi
                                  fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                ),
                              ),
                            ],
                          ),
                        ),  

                      //Taille height_outlined
                      if (widget.u.height != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.height_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.u.height} cm',
                                style: const TextStyle(
                                  fontSize: 18, // taille du texte agrandie
                                  fontWeight: FontWeight.bold, // optionnel pour accentuer
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Genre
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD9BE77), width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(genderIcon, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              genderLabel,
                              style: const TextStyle(
                                fontSize: 18, // texte plus grand
                                fontWeight: FontWeight.bold, // optionnel pour mettre en gras
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Poids monitor_weight_outlined
                      if (widget.u.weight != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFD9BE77), width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monitor_weight_outlined, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.u.weight} kg',
                                  style: const TextStyle(
                                    fontSize: 18, // taille du texte agrandie
                                    fontWeight: FontWeight.bold, // optionnel pour accentuer
                                  ),
                                ),
                              ],
                            ),
                          ),
                      // Niveau
                      if ((widget.u.level ?? '').trim().isNotEmpty)
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFD9BE77), width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  widget.u.level!.trim(),
                                  style: const TextStyle(
                                    fontSize: 18, // texte agrandi
                                    fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                  ),
                                ),
                              ],
                            ),
                          ),
                      // Metabolisme
                      if (widget.u.metabolism != null && widget.u.metabolism!.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                widget.u.metabolism!.trim(),
                                style: const TextStyle(
                                  fontSize: 18, // texte agrandi
                                  fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                ),
                              ),
                            ],
                          ),
                        ),


                      // Date de naissance
                     // if (birth != null)
                       // _InfoChip(
                         // icon: Icons.cake_outlined,
                          //text: 'Né(e) le $birth',
                        //),


                     // IMC arrondi
                      if (imcArrondi != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_right, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'IMC : $imcArrondi => $imcCategory',
                                style: const TextStyle(
                                  fontSize: 18, // augmente ici la taille du texte
                                  fontWeight: FontWeight.bold, // optionnel pour accentuer
                                ),
                              ),
                            ],
                          ),
                        ),


                    ],
                  ),
                const SizedBox(height: 20),

        // === BOUTON EDITER ===
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
  final parent = context.findAncestorStateOfType<_AdminPageState>()!;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProfileBasicsPage(
        // --- Valeurs pré-remplies ---
        initialPrenom: widget.u.prenom ?? "",
        initialNom: widget.u.nom ?? "",
        initialBirthDate: widget.u.birthDate,
        initialWeight: widget.u.weight,
        initialHeight: widget.u.height,
        initialGender: (widget.u.gender == "homme")
            ? Gender.homme
            : Gender.femme,

        // --- Fonction quand l’utilisateur valide ---
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

          // Retour
          Navigator.pop(context);
        },
      ),
    ),
  );
},
            child: const Text(
              "Modifier le profil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // === JOURS D'ENTRAÎNEMENT ===
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2A2D5F),
              foregroundColor: AppTheme.gold,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _showTrainingDaysDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  _selectedDays.isEmpty
                    ? "Définir les jours d'entraînement"
                    : "Jours : ${_selectedDays.map(_getDayName).join(', ')}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // === BOUTON SUPPRIMER ===
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed:()  {
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            } ,
            child: const Text(
              "Supprimer le profil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  ),
);  }
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