import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/db/app_db.dart';
import '../../services/dashboard_service.dart';
import '../../services/performance_monitor_service.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/charts/muscle_pie_chart.dart';
import '../utils/responsive.dart';

class DashboardPage extends StatelessWidget {
  final AppDb db;

  const DashboardPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // 1. PROVIDER INJECTION
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(db),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        // 2. GLOBAL LOADING STATE
        // We listen to the whole VM here just for isLoading, or we could use a Selector.
        child: Selector<DashboardViewModel, bool>(
          selector: (_, vm) => vm.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.gold),
              );
            }
            return child!;
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// HEADER
                const _DashboardHeader(),

                const SizedBox(height: 16),

                /// KEY METRICS ROW
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      // Card 1: Time
                      Expanded(
                        child: Selector<DashboardViewModel, String>(
                          selector: (_, vm) => vm.totalTimeFormatted,
                          builder:
                              (_, value, __) => _buildCompactStatCard(
                                "Temps total",
                                value,
                                Icons.timer,
                                Colors.purpleAccent,
                                responsive,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 2: Streak
                      Expanded(
                        child: Selector<DashboardViewModel, String>(
                          selector: (_, vm) => vm.streakText,
                          builder:
                              (_, value, __) => _buildCompactStatCard(
                                "Streak",
                                value,
                                Icons.local_fire_department,
                                Colors.redAccent,
                                responsive,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Card 3: Sessions
                      Expanded(
                        child: Selector<DashboardViewModel, String>(
                          selector: (_, vm) => vm.totalSessionsText,
                          builder:
                              (_, value, __) => _buildCompactStatCard(
                                "Séances total",
                                value,
                                Icons.fitness_center,
                                Colors.orangeAccent,
                                responsive,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// BAR CHART
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.05),
                      ),
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
                          child: Selector<DashboardViewModel, Map<String, int>>(
                            selector: (_, vm) => vm.weeklyData,
                            builder: (context, data, _) {
                              if (data.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Aucune donnée",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return WeeklyBarChart(weeklyData: data);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// PIE CHART & SUMMARY
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Pie Chart
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.05),
                            ),
                          ),
                          child: Consumer<DashboardViewModel>(
                            // Using Consumer here because we need both muscleStats and check emptiness.
                            // Or we could Select the list itself.
                            builder: (context, vm, _) {
                              if (!vm.hasMuscleData) {
                                return const Center(
                                  child: Text(
                                    "Pas de données",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return MusclePieChart(
                                muscleStats: vm.muscleStats,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Focus Card
                      Expanded(
                        flex: 2,
                        child: Container(
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
                              Selector<DashboardViewModel, String>(
                                selector: (_, vm) => vm.focusMuscleName,
                                builder: (_, name, __) {
                                  return Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: responsive.rsp(16),
                                    ),
                                  );
                                },
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
      ),
    );
  }

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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  void _showPerformanceDialog(BuildContext context) {
    final perfService = PerformanceMonitorService();
    final report = perfService.lastReport;

    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun rapport de performance disponible.'),
        ),
      );
      return;
    }

    // Encoder JSON avec indentation
    final jsonString = const JsonEncoder.withIndent('  ').convert(report);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Performance Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                jsonString,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: AppTheme.gold),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Selector<DashboardViewModel, String>(
              selector: (_, vm) => vm.userName,
              builder:
                  (_, name, __) => Text(
                    "Bonjour $name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
            const Text(
              "Prêt à tout casser ?",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showPerformanceDialog(context),
              icon: const Icon(Icons.analytics_outlined),
              color: Colors.white70,
              tooltip: 'Stats Performance',
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(217, 190, 119, 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(217, 190, 119, 0.3),
                ),
              ),
              child: Selector<DashboardViewModel, String>(
                selector: (_, vm) => vm.todayDate,
                builder:
                    (_, date, __) => Text(
                      date,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
