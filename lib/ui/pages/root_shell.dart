import 'package:flutter/material.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav/bottom_nav_bar.dart';
import 'dashboard_page.dart';
import 'exercises_page.dart';
import 'admin_page.dart';
import 'workout_program_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'planning_page.dart';
import '../../core/perf/perf_service.dart';
import 'perf/performance_lab_page.dart';

class RootShell extends StatefulWidget {
  final AppDb db;
  const RootShell({super.key, required this.db});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  AppPrefs? _prefs;
  Key _planningKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _prefs = AppPrefs(sp));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(
        backgroundColor: AppTheme.scaffold,
        body: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
      );
    }

    final pages = [
      DashboardPage(db: widget.db),
      PlanningPage(key: _planningKey, db: widget.db),
      WorkoutProgramPage(db: widget.db, prefs: _prefs!),
      ExercisesPage(db: widget.db),
      AdminPage(db: widget.db, prefs: _prefs!),
    ];

    final items = const [
      BottomNavItem(icon: Icons.home_outlined, label: 'Acceuil'),
      BottomNavItem(icon: Icons.calendar_month_outlined, label: 'Planning'),
      BottomNavItem(icon: Icons.fitness_center_outlined, label: 'Programme'),
      BottomNavItem(icon: Icons.list, label: 'Exercices'),
      BottomNavItem(icon: Icons.person, label: 'Profil'),
    ];

    // Solution propre:
    final visiblePages = List<Widget>.from(pages);
    final visibleItems = List<BottomNavItem>.from(items);

    if (PerfService.isPerfMode) {
      visiblePages.add(PerformanceLabPage(db: widget.db, prefs: _prefs!));
      visibleItems.add(const BottomNavItem(icon: Icons.speed, label: 'Perf'));
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: IndexedStack(index: _index, children: visiblePages),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BottomNavBar(
          currentIndex: _index,
          onTap: (i) {
            setState(() {
              _index = i;
              if (i == 1) {
                // Si c'est le planning
                _planningKey = UniqueKey();
              }
            });
          },
          items: visibleItems,
        ),
      ),
    );
  }
}
