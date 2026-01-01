// lib/ui/pages/admin_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/db/app_db.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/admin_view_model.dart';
import '../widgets/admin/user_card.dart';

class AdminPage extends StatelessWidget {
  final AppDb db;
  final AppPrefs prefs;

  const AdminPage({super.key, required this.db, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Initialisation du ViewModel via Provider
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(db: db, prefs: prefs),
      child: const _AdminPageView(),
    );
  }
}

class _AdminPageView extends StatelessWidget {
  const _AdminPageView();

  @override
  Widget build(BuildContext context) {
    // Accès au ViewModel sans reconstruire toute la page pour rien
    // On utilisera Selector ou Consumer là où c'est nécessaire.
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // HEADER
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
                    // notifyListeners suffira à rafraîchir ceux qui écoutent
                    // Ici, comme le stream est écouté directement, pas forcément besoin
                    // d'une commande refresh explicite sauf si le stream ne se met pas à jour.
                    // Mais on peut forcer un rebuild si nécessaire.
                    onPressed: () {
                      // Pour un Stream, setState n'est pas utile si la source ne change pas.
                      // Ici on peut juste laisser l'utilisateur spammer si ça le rassure,
                      // ou trigger un reload si le ViewModel avait des données fetchées.
                      // Le VM ne expose pas de refresh() pour le stream.
                    },
                    icon: const Icon(Icons.refresh, color: AppTheme.gold),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // OPTION RAPPEL D'INACTIVITÉ
              Builder(
                builder: (context) {
                  final prefs = context.read<AdminViewModel>().prefs;

                  return Card(
                    color: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rappel d'inactivité",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // SWITCH ACTIVER / DESACTIVER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Activer le rappel",
                                style: TextStyle(color: Colors.white),
                              ),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return Switch(
                                    value: prefs.reminderEnabled,
                                    activeColor: AppTheme.success,
                                    onChanged: (v) async {
                                      await prefs.setReminderEnabled(v);
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // CHOIX DU NOMBRE DE JOURS
                          if (prefs.reminderEnabled)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Rappel après",
                                  style: TextStyle(color: Colors.white),
                                ),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return DropdownButton<int>(
                                      value: prefs.reminderDays,
                                      dropdownColor: AppTheme.scaffold,
                                      style: const TextStyle(color: Colors.white),
                                      items: const [
                                        DropdownMenuItem(value: 3, child: Text("3 jours")),
                                        DropdownMenuItem(value: 5, child: Text("5 jours")),
                                        DropdownMenuItem(value: 7, child: Text("7 jours")),
                                        DropdownMenuItem(value: 10, child: Text("10 jours")),
                                      ],
                                      onChanged: (v) async {
                                        if (v == null) return;
                                        await prefs.setReminderDays(v);
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              // LISTE DES UTILISATEURS
              Expanded(
                child: Builder(
                  builder: (context) {
                    final vm = context.read<AdminViewModel>();
                    return StreamBuilder<List<AppUserData>>(
                      stream: vm.usersStream,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Gestion erreur
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              'Erreur: ${snap.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
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

                        // Liste optimisée
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: users.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            return UserCard(u: users[i]);
                          },
                        );
                      },
                    );
                  },
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
