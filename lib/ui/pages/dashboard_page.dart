import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/charts/muscle_pie_chart.dart';
import '../utils/responsive.dart';
import '../../core/perf/perf_monitor_widget.dart';
import '../../core/perf/perf_service.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../../services/dashboard_service.dart'; // Pour le type DashboardData

class DashboardPage extends StatelessWidget {
  final AppDb db;
  const DashboardPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // Responsive instancié ici, utilisé plus bas
    // Note: On pourrait l'instancier dans le builder si on voulait être puriste sur contexte,
    // mais ici c'est safe car on est dans build.
    final responsive = Responsive(context);

    // Initialisation du ViewModel via Provider
    return ChangeNotifierProvider<DashboardViewModel>(
      create: (_) => DashboardViewModel(db),
      child: Scaffold(
        backgroundColor: AppTheme.scaffold,
        body: SafeArea(
          child: Consumer<DashboardViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.gold),
                );
              }

              if (vm.errorMessage != null) {
                return Center(
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<DashboardData>(
                  stream: vm.dashboardStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur: ${snapshot.error}"));
                    }

                    // Valeurs par défaut si pas de data ou chargement
                    final data = snapshot.data;
                    final streakWeeks = data?.streakWeeks ?? 0;
                    // final volumeVariation = data?.volumeVariation ?? 0.0; // Inutilisé dans code d'origine
                    // final efficiency = data?.efficiency ?? 0.0; // Inutilisé dans code d'origine
                    final weeklyAttendance = data?.weeklyAttendance ?? {};
                    final muscleStats = data?.muscleStats ?? <MuscleStat>[];
                    final totalHeures = data?.totalHeures ?? 0.0;
                    final totalSeances = data?.totalSeances ?? 0;
                    // final moyennePlaisir = data?.moyennePlaisir ?? 0.0; // Inutilisé dans code d'origine

                    return PerfMonitorWidget(
                      label: 'Dashboard_Body',
                      logOnBuild: PerfService.isPerfMode,
                      logOnRender: PerfService.isPerfMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// HEADER COMPACT
                          _buildHeader(vm.userName, vm.todayDate),

                          const SizedBox(height: 16),

                          /// TOP ROW - KEY METRICS (3 Cards)
                          SizedBox(
                            height: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildCompactStatCard(
                                    "Temps total",
                                    vm.formatHeures(totalHeures),
                                    Icons.timer,
                                    Colors.purpleAccent,
                                    responsive,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactStatCard(
                                    "Streak",
                                    "$streakWeeks sem.",
                                    Icons.local_fire_department,
                                    Colors.redAccent,
                                    responsive,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactStatCard(
                                    "Séances total",
                                    "$totalSeances",
                                    Icons.fitness_center,
                                    Colors.orangeAccent,
                                    responsive,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// MIDDLE - WEEKLY CHART (Expanded)
                          Expanded(
                            flex: 3,
                            child: _buildWeeklyChartContainer(
                              weeklyAttendance,
                              responsive,
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
                                  child: _buildPieChartContainer(
                                    muscleStats,
                                    responsive,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildFocusCard(
                                    muscleStats,
                                    responsive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Extrait: Header
  Widget _buildHeader(String userName, String todayDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour $userName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              "Prêt à tout casser ?",
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
            todayDate,
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Extrait: Container Chart Semaine
  Widget _buildWeeklyChartContainer(
    Map<String, int> weeklyAttendance,
    Responsive responsive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      padding: EdgeInsets.fromLTRB(
        responsive.rw(16),
        responsive.rh(16),
        responsive.rw(16),
        0,
      ),
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
          SizedBox(height: responsive.rh(12)),
          Expanded(
            child:
                weeklyAttendance.isNotEmpty
                    ? PerfMonitorWidget(
                      label: 'WeeklyChart',
                      logOnBuild: PerfService.isPerfMode,
                      logOnRender: PerfService.isPerfMode,
                      child: WeeklyBarChart(weeklyData: weeklyAttendance),
                    )
                    : const Center(
                      child: Text(
                        "Aucune donnée",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  /// Extrait: Container Pie Chart
  Widget _buildPieChartContainer(
    List<MuscleStat> muscleStats,
    Responsive responsive,
  ) {
    // Note: Typage strict maintenant utilisé

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child:
          muscleStats.isNotEmpty
              ? PerfMonitorWidget(
                label: 'MusclePieChart',
                logOnBuild: PerfService.isPerfMode,
                logOnRender: PerfService.isPerfMode,
                child: MusclePieChart(muscleStats: muscleStats),
              )
              : const Center(
                child: Text(
                  "Pas de données",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
    );
  }

  /// Extrait: Focus Card
  Widget _buildFocusCard(List<MuscleStat> muscleStats, Responsive responsive) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(responsive.rw(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.black,
            size: responsive.rsp(32),
          ),
          SizedBox(height: responsive.rh(8)),
          Text(
            "Focus",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: responsive.rsp(14),
            ),
          ),
          SizedBox(height: responsive.rh(4)),
          Text(
            muscleStats.isNotEmpty ? muscleStats.first.muscleName : "--",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: responsive.rsp(16),
            ),
          ),
        ],
      ),
    );
  }

  /// Extrait: Carte Stat Compacte
  Widget _buildCompactStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Responsive responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.rw(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: responsive.rsp(20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.rsp(16),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: responsive.rsp(11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
