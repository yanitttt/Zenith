import 'package:flutter/material.dart';
import 'package:recommandation_mobile/ui/pages/match_page.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav/bottom_nav_bar.dart';
import 'dashboard_page.dart';
import 'exercises_page.dart';
import 'admin_page.dart'; // ⬅️ NEW

class RootShell extends StatefulWidget {
  final AppDb db;
  const RootShell({super.key, required this.db});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(db: widget.db),
      const _PlaceholderPage(title: 'Planning'),
      MatchPage(db: widget.db),
      ExercisesPage(db: widget.db),
      AdminPage(db: widget.db), // ⬅️ Admin (remplace Profil)
    ];

    final items = const [
      BottomNavItem(icon: Icons.home_outlined, label: 'Acceuil'),
      BottomNavItem(icon: Icons.calendar_month_outlined, label: 'Planning'),
      BottomNavItem(icon: Icons.show_chart, label: 'Match'),
      BottomNavItem(icon: Icons.fitness_center, label: 'Mes Exercices'),
      BottomNavItem(icon: Icons.admin_panel_settings, label: 'Admin'), // ⬅️
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BottomNavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: items,
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}
