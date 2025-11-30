import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/dashboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/charts/muscle_pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardPage extends StatefulWidget {
  final AppDb db;
  const DashboardPage({super.key, required this.db});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final UserRepository _userRepo;
  late final DashboardService _dashboardService;

  String _userName = "...";
  bool _isLoading = true;
  String _todayDate = "";
  int? _userId;
  double _totalHeures = 0.0; // corrigé en double
  int _totalSeances = 0;

  // Metrics
  int _streakWeeks = 0;
  double _volumeVariation = 0.0;
  double _efficiency = 0.0;
  Map<String, int> _weeklyAttendance = {};
  List<MuscleStat> _muscleStats = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      Intl.defaultLocale = 'fr_FR';
      final now = DateTime.now();
      final formatter = DateFormat('d MMM', 'fr_FR');
      setState(() {
        _todayDate = formatter.format(now);
      });
    });

    _userRepo = UserRepository(widget.db);
    _dashboardService = DashboardService(widget.db);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _userRepo.current();
      final prenom = user?.prenom?.trim() ?? "Athlète";
      _userId = user?.id;

      if (_userId != null) {
        final streak = await _dashboardService.getCurrentStreakWeeks(_userId!);
        final variation = await _dashboardService.getVolumeVariationPercentage(_userId!);
        final efficiency = await _dashboardService.getTrainingEfficiency(_userId!);
        final weeklyAttendance = await _dashboardService.getAssiduiteSemaine(_userId!);
        final muscleStats = await _dashboardService.getRepartitionMusculaire(_userId!);
        final totalHeuresStr = await _dashboardService.getTotalHeuresEntrainement(_userId!);
        final totalSeances = await _dashboardService.getTotalSeances(_userId!);

        if (mounted) {
          setState(() {
            _userName = prenom;
            _streakWeeks = streak;
            _volumeVariation = variation;
            _efficiency = efficiency;
            _weeklyAttendance = weeklyAttendance;
            _muscleStats = muscleStats;
            _totalHeures = double.tryParse(totalHeuresStr.replaceAll(" h", "")) ?? 0.0; // conversion
            _isLoading = false;
            _totalSeances = totalSeances;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userName = prenom;
            _isLoading = false;
          });
        }
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

  // Fonction pour formater les heures en "X h YY min"
  String formatHeures(double heures) {
    final int h = heures.floor();
    final int minutes = ((heures - h) * 60).round();
    return "$h h ${minutes.toString().padLeft(2, '0')} min";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// HEADER COMPACT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bonjour $_userName",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Prêt à tout casser ?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(217, 190, 119, 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color.fromRGBO(217, 190, 119, 0.3)),
                    ),
                    child: Text(
                      _todayDate,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// TOP ROW - KEY METRICS (3 Cards)
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatCard(
                        "Temps total",
                        formatHeures(_totalHeures),
                        Icons.timer,
                        Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactStatCard(
                        "Progression",
                        "${_volumeVariation > 0 ? '+' : ''}$_volumeVariation%",
                        _volumeVariation >= 0 ? Icons.trending_up : Icons.trending_down,
                        _volumeVariation >= 0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactStatCard(
                        "Séances",
                        "$_totalSeances",
                        Icons.fitness_center,
                        Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// MIDDLE - WEEKLY CHART (Expanded)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Activité Semaine",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _weeklyAttendance.isNotEmpty
                            ? WeeklyBarChart(weeklyData: _weeklyAttendance)
                            : const Center(child: Text("Aucune donnée", style: TextStyle(color: Colors.grey))),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// BOTTOM - PIE CHART & SUMMARY (Expanded)
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
                        ),
                        child: _muscleStats.isNotEmpty
                            ? MusclePieChart(muscleStats: _muscleStats)
                            : const Center(child: Text("Pas de données", style: TextStyle(color: Colors.grey))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.black, size: 32),
                            const SizedBox(height: 8),
                            const Text(
                              "Focus",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _muscleStats.isNotEmpty ? _muscleStats.first.muscleName : "--",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}