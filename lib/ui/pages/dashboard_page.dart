import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/banner/header_banner.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/progress/progress_card.dart';
import '../widgets/favorites/favorites_card.dart';
import '../widgets/stats/stats_card.dart';

class DashboardPage extends StatefulWidget {
  final AppDb db;
  const DashboardPage({super.key, required this.db});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final UserRepository _userRepo;
  late final ExerciseRepository _exerciseRepo;

  String _userName = "...";
  List<ExerciseData> _randomExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(widget.db);
    _exerciseRepo = ExerciseRepository(widget.db);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Charger le prénom de l'utilisateur
      final user = await _userRepo.current();
      final prenom = user?.prenom?.trim() ?? "Athlète";

      // Charger des exercices aléatoires
      final allExercises = await _exerciseRepo.all();
      allExercises.shuffle();
      final randomExercises = allExercises.take(4).toList();

      if (mounted) {
        setState(() {
          _userName = prenom;
          _randomExercises = randomExercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[DASHBOARD] Erreur: $e');
      if (mounted) {
        setState(() {
          _userName = "Athlète";
          _isLoading = false;
        });
      }
    }
  }

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
              HeaderBanner(
                title: "Bonjour $_userName !\nPrêt pour ta séance ?",
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

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.gold),
                      )
                    : FavoritesCard(exercises: _randomExercises),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatsCard(db: widget.db),
              ),

              const SizedBox(height: 16),
              const Expanded(child: SizedBox()), // espace vide
            ],
          ),
        ),
      ),
    );
  }
}
