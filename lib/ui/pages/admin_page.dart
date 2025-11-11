// lib/ui/pages/admin_page.dart
import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';
import '../../services/ImcService.dart';

class AdminPage extends StatefulWidget {
  final AppDb db;
  const AdminPage({super.key, required this.db});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: const Color(0xFF111111), width: 2),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: const [
                    Icon(Icons.admin_panel_settings, color: AppTheme.gold),
                    SizedBox(width: 10),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: .5,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bloc liste
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: const Color(0xFF111111), width: 2),
                  ),
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
                                const Icon(Icons.people_outline, color: AppTheme.gold),
                                const SizedBox(width: 8),
                                Text(
                                  'Utilisateurs: $count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                              itemBuilder: (_, i) => _UserCard(u: users[i]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
  const _UserCard({required this.u});

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
    final hadBirthday = (now.month > dob.month) ||
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
    final calc = IMCcalculator(height: u.height!, weight: u.weight!);
    final imc = calc.calculateIMC();
    final imcArrondi = double.parse(imc.toStringAsFixed(2));
    final imcCategory = calc.getIMCCategory();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold, width: 2),
              ),
              child: Icon(genderIcon, color: AppTheme.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '(Sans nom)' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.2,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Chips infos: genre / naissance / âge
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InfoChip(
                          icon: genderIcon,
                          text: genderLabel,
                        ),
                        if (birth != null)
                          _InfoChip(
                            icon: Icons.cake_outlined,
                            text: 'Né(e) le $birth ',
                          ),
                        if (age != null)
                          _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            text: '$age ans',
                          ),
                        if (imcArrondi != null)
                          _InfoChip(
                            icon : Icons.chevron_right,
                            text: "IMC : $imcArrondi",
                          ),
                        if (imcCategory != null)
                          _InfoChip(
                            icon : Icons.chevron_right,
                            text: "IMC : $imcCategory",
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1B1B1B), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.gold),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
