import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../theme/app_theme.dart';

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
              // Header Admin
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
                    // placeholder pour actions futures (export, purge, etc.)
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bloc stats + liste users
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: const Color(0xFF111111), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats bandeau
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

                      // Liste des users
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

  @override
  Widget build(BuildContext context) {
    final title = [
      if ((u.prenom ?? '').trim().isNotEmpty) u.prenom!.trim(),
      if ((u.nom ?? '').trim().isNotEmpty) u.nom!.trim(),
    ].join(' ').trim();

    final subtitle = 'id=${u.id}'
        '${u.age != null ? '  •  âge=${u.age}' : ''}'
        '${u.weight != null ? '  •  poids=${u.weight}kg' : ''}'
        '${u.height != null ? '  •  taille=${u.height}cm' : ''}'
        '${u.level != null ? '  •  niveau=${u.level}' : ''}'
        '${u.metabolism != null ? '  •  métabolisme=${u.metabolism}' : ''}';

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
              child: const Icon(Icons.person, color: AppTheme.gold),
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
