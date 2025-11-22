// lib/ui/pages/admin_page.dart
import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';
import '../../services/ImcService.dart';
import 'onboarding/onboarding_flow.dart';
import '../../core/prefs/app_prefs.dart';
import 'edit_user_page.dart';

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

  @override
  void initState() {
    super.initState();
    _userDao = UserDao(widget.db);
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
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton.tonal(
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




              Expanded(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bandeau stats
                    FutureBuilder<int>(
                      future: _userDao.countUsers(),
                      builder: (context, snap) {
                        final count = snap.data ?? 0;
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF111111), width: 2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                tooltip: 'Rafraîchir',
                                onPressed: () => setState(() {}),
                                icon: const Icon(Icons.refresh, color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

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

class _UserCard extends StatelessWidget {
  final AppUserData u;
  final VoidCallback? onDelete;

  const _UserCard({
    required this.u,
    this.onDelete,
    Key? key,
  }) : super(key: key);

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
      if ((u.prenom ?? '').trim().isNotEmpty) u.prenom!.trim(),
      if ((u.nom ?? '').trim().isNotEmpty) u.nom!.trim(),
    ].join(' ').trim();

    final lines = <String>[];
    lines.add('id=${u.id}');
    if (u.level != null) lines.add('niveau=${u.level}');
    if (u.weight != null) lines.add('poids=${u.weight}kg');
    if (u.height != null) lines.add('taille=${u.height}cm');
    if (u.metabolism != null && u.metabolism!.trim().isNotEmpty) {
      lines.add('métabolisme=${u.metabolism}');
    }
    final subtitle = lines.join('  •  ');

    final age = _calcAge(u.birthDate);
    final birth = u.birthDate != null ? _fmtDate(u.birthDate!) : null;
    final genderLabel = _genderLabel(u.gender);
    final genderIcon = _genderIcon(u.gender);

    double? imcArrondi;
    String? imcCategory;
    if (u.height != null && u.weight != null) {
      final calc = IMCcalculator(height: u.height!, weight: u.weight!);
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
                      if ((u.prenom ?? '').trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                u.prenom!.trim(),
                                style: const TextStyle(
                                  fontSize: 18, // texte agrandi
                                  fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Nom badge_outlined
                      if ((u.nom ?? '').trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.badge_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                u.nom!.trim(),
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
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
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
                      if (u.height != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.height_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${u.height} cm',
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
                          border: Border.all(color: Color(0xFFD9BE77), width: 5),
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
                      if (u.weight != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFD9BE77), width: 5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monitor_weight_outlined, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${u.weight} kg',
                                  style: const TextStyle(
                                    fontSize: 18, // taille du texte agrandie
                                    fontWeight: FontWeight.bold, // optionnel pour accentuer
                                  ),
                                ),
                              ],
                            ),
                          ),
                      // Niveau
                      if ((u.level ?? '').trim().isNotEmpty)
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFD9BE77), width: 5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  u.level!.trim(),
                                  style: const TextStyle(
                                    fontSize: 18, // texte agrandi
                                    fontWeight: FontWeight.bold, // optionnel pour plus de visibilité
                                  ),
                                ),
                              ],
                            ),
                          ),
                      // Metabolisme
                      if (u.metabolism != null && u.metabolism!.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                u.metabolism!.trim(),
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
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_right, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'IMC : $imcArrondi',
                                style: const TextStyle(
                                  fontSize: 18, // augmente ici la taille du texte
                                  fontWeight: FontWeight.bold, // optionnel pour accentuer
                                ),
                              ),
                            ],
                          ),
                        ),

                      // IMC catégorie
                      if (imcCategory != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFD9BE77), width: 5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_right, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'IMC : $imcCategory',
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
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
  Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => EditProfilePage(
      user: u,
      userDao: context.findAncestorStateOfType<_AdminPageState>()!._userDao,
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

        // === BOUTON SUPPRIMER ===
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onDelete,
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