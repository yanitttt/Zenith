import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/banner/header_banner.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/progress/progress_card.dart';
import '../widgets/favorites/favorites_card.dart';
// ❌ supprime cet import : '../widgets/bottom_nav/bottom_nav_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
            children: const [
              SizedBox(height: 8),
              HeaderBanner(
                title: "Bonjour Nom !\nPrêt pour ta séance ?",
                showSettings: true,
              ),
              SizedBox(height: 16),

              // ligne calendrier + progression
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: CalendarCard()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: ProgressCard(percent: 0.60)),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: FavoritesCard(),
              ),

              SizedBox(height: 16),
              Expanded(child: SizedBox()), // espace vide comme sur la maquette
            ],
          ),
        ),
      ),
    );
  }
}
