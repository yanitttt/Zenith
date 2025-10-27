import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/banner/header_banner.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/progress/progress_card.dart';
import '../widgets/favorites/favorites_card.dart';
import '../widgets/bottom_nav/bottom_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: const Color(0xFF111111), width: 2),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const HeaderBanner(
                title: "Bonjour Nom !\nPrêt pour ta séance ?",
                showSettings: true,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 3, child: CalendarCard()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: ProgressCard(percent: 0.60)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FavoritesCard(),
              ),
              const SizedBox(height: 16),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: BottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  items: const [
                    BottomNavItem(icon: Icons.home_outlined, label: 'Acceuil'),
                    BottomNavItem(icon: Icons.calendar_month_outlined, label: 'Planning'),
                    BottomNavItem(icon: Icons.show_chart, label: 'Progression'),
                    BottomNavItem(icon: Icons.fitness_center, label: 'Mes Exercices'),
                    BottomNavItem(icon: Icons.person, label: 'Profil'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
