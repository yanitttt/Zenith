import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav/bottom_nav_bar.dart';
import 'dashboard_page.dart';
import 'exercises_page.dart';

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
      const DashboardPage(),
      const _PlaceholderPage(title: 'Planning'),
      const _PlaceholderPage(title: 'Progression'),
      ExercisesPage(db: widget.db), // ← Mes Exercices
      const _PlaceholderPage(title: 'Profil'),
    ];

    final items = const [
      BottomNavItem(icon: Icons.home_outlined, label: 'Acceuil'),
      BottomNavItem(icon: Icons.calendar_month_outlined, label: 'Planning'),
      BottomNavItem(icon: Icons.show_chart, label: 'Progression'),
      BottomNavItem(icon: Icons.fitness_center, label: 'Mes Exercices'),
      BottomNavItem(icon: Icons.person, label: 'Profil'),
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
