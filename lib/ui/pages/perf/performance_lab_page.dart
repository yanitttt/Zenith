import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:recommandation_mobile/core/perf/perf_service.dart';
import 'package:recommandation_mobile/core/perf/perf_report.dart';
import 'package:recommandation_mobile/core/perf/complexity_analyzer.dart';
import 'package:recommandation_mobile/core/perf/perf_monitor_widget.dart';
import 'package:recommandation_mobile/core/perf/simulation_benchmark.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/core/prefs/app_prefs.dart';
import 'package:recommandation_mobile/services/recommendation_service.dart';
import 'package:recommandation_mobile/core/theme/app_theme.dart';

class PerformanceLabPage extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;

  const PerformanceLabPage({super.key, required this.db, required this.prefs});

  @override
  State<PerformanceLabPage> createState() => _PerformanceLabPageState();
}

class _PerformanceLabPageState extends State<PerformanceLabPage> {
  bool _isRecording = false;
  String _status = 'Prêt';
  List<BenchmarkDataPoint>? _benchmarkData;
  bool _showGraph = true;

  Future<void> _runRecommendationTest() async {
    final userId = widget.prefs.currentUserId;
    if (userId == null) {
      setState(() => _status = 'Erreur: Aucun utilisateur connecté');
      return;
    }

    setState(() {
      _status = 'Analyse Recommandation (DB) en cours...';
      _isRecording = true;
    });

    final service = RecommendationService(widget.db);

    try {
      // 1. Analyse de complexité (faire varier la LIMIT)
      final cResult = await ComplexityAnalyzer.analyze(
        name: 'RecService_GetExercises',
        workload: (n) async {
          await service.getRecommendedExercises(userId: userId, limit: n);
        },
        inputSizes: [5, 10, 20, 50],
      );

      // 2. Mesure standard (Limit 10)
      await PerfService().measure('RecService_Standard_10', () async {
        await service.getRecommendedExercises(userId: userId, limit: 10);
      });

      setState(() {
        _status =
            'Complexité: ${cResult.estimatedComplexity.name}\n'
            'Timings: ${cResult.timingsMicroseconds}\n'
            'Voir rapport standard pour mesure detaillee.';
        _isRecording = false;
      });

      await PerfReport.generateAndShare('RecService_Analysis');
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
        _isRecording = false;
      });
    }
  }

  Future<void> _runComplexityDemo() async {
    setState(() {
      _status = 'Analyse complexité en cours...';
      _isRecording = true;
    });

    final result = await ComplexityAnalyzer.analyze(
      name: 'List_Generation',
      workload: (n) {
        final list = List.generate(n, (i) => i);
        for (var item in list) {
          item.toString();
        }
      },
      inputSizes: [100, 1000, 10000, 50000],
    );

    setState(() {
      _status =
          'Résultat: ${result.estimatedComplexity.toString().split('.').last}\n'
          '${result.timingsMicroseconds}';
      _isRecording = false;
    });
  }

  Future<void> _runSimulationBenchmark() async {
    setState(() {
      _status = 'Simulation Benchmark en cours...';
      _benchmarkData = null;
      _isRecording = true;
    });

    final data = await SimulationBenchmark.runFullSuiteData();

    setState(() {
      _status = 'Simulation terminée.';
      _benchmarkData = data;
      _isRecording = false;
    });
  }

  Future<void> _runScenarioA() async {
    setState(() {
      _isRecording = true;
      _status = 'Exécution Scénario A (Simulation charge)...';
    });

    PerfService().onScreenChanged('Scenario_A');

    await PerfService().measure('Scenario_A_Total', () async {
      await PerfService().measure('Math_Heavy', () async {
        await Future.delayed(const Duration(milliseconds: 500));
        int sum = 0;
        for (int i = 0; i < 100000; i++) {
          sum += i;
        }
        debugPrint('Sum: $sum');
      });

      await PerfService().measure('Network_Call', () async {
        await Future.delayed(const Duration(seconds: 1));
      });
    });

    setState(() {
      _isRecording = false;
      _status = 'Scénario terminé. Génération rapport...';
    });

    await PerfReport.generateAndShare('Scenario_A_Standard');

    setState(() {
      _status = 'Rapport partagé !';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!PerfService.isPerfMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Performance Lab')),
        body: const Center(
          child: Text(
            'Le mode Performance n\'est pas activé.\nRelancez avec --dart-define=PERF_MODE=true',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Lab'),
        // Suppression de la couleur violette hardcodée -> utilise le thème (transparent)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: AppTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: $_status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            PerfMonitorWidget(
              label: 'Btn_ScenarioA',
              child: ElevatedButton.icon(
                onPressed: _isRecording ? null : _runScenarioA,
                icon: const Icon(Icons.timer),
                label: const Text('Lancer Scénario A (Test CPU/Res)'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isRecording ? null : _runComplexityDemo,
              icon: const Icon(Icons.analytics),
              label: const Text('Démo Analyse O(n) (Liste)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isRecording ? null : _runRecommendationTest,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Analyse RecService (SQL)'),
            ),
            const SizedBox(height: 12),

            // Bouton Stress Test (Style distinct mais harmonieux)
            ElevatedButton.icon(
              onPressed: _isRecording ? null : _runSimulationBenchmark,
              icon: const Icon(Icons.speed, color: AppTheme.error),
              style: ElevatedButton.styleFrom(
                // On garde une distinction subtile (bordure rouge ou fond légèrement teinté)
                // Ici on utilise le thème par défaut mais on ajoute une bordure pour marquer "Attention"
                side: const BorderSide(color: AppTheme.error, width: 2),
              ),
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Comparaison : Ancien vs Nouvel Algo',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "STRESS TEST",
                    style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            if (_benchmarkData != null) ...[
              const SizedBox(height: 20),
              // Graph Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vue : ', style: Theme.of(context).textTheme.bodyMedium),
                  Switch(
                    value: _showGraph,
                    onChanged: (v) => setState(() => _showGraph = v),
                    activeColor: AppTheme.gold,
                  ),
                  Text(
                    _showGraph ? 'Graphique' : 'Tableau',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Graph / Table Area
              if (_showGraph)
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine:
                            (value) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                        getDrawingVerticalLine:
                            (value) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'N=${value.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                            interval: 10,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}ms',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Legacy (Red - Error Color)
                        LineChartBarData(
                          spots:
                              _benchmarkData!
                                  .map(
                                    (e) => FlSpot(
                                      e.n.toDouble(),
                                      e.legacyMs.toDouble(),
                                    ),
                                  )
                                  .toList(),
                          isCurved: true,
                          color: AppTheme.error,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        // Optimized (Success Color)
                        LineChartBarData(
                          spots:
                              _benchmarkData!
                                  .map(
                                    (e) => FlSpot(
                                      e.n.toDouble(),
                                      e.optimizedMs.toDouble(),
                                    ),
                                  )
                                  .toList(),
                          isCurved: true,
                          color: AppTheme.success,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: AppTheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'N',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Naïf',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Opt.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Gain',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white24),
                        ..._benchmarkData!.map((e) {
                          final gain =
                              e.legacyMs /
                              (e.optimizedMs == 0 ? 1 : e.optimizedMs);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${e.n}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${e.legacyMs}ms',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.error,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${e.optimizedMs}ms',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'x${gain.toStringAsFixed(1)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.gold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 12, color: AppTheme.error),
                    SizedBox(width: 4),
                    Text('Naïf O(N)', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 12, color: AppTheme.success),
                    SizedBox(width: 4),
                    Text('Optimisé O(1)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            TextButton.icon(
              onPressed: () async {
                await PerfReport.generateAndShare('Manual_Export');
              },
              icon: const Icon(Icons.share, color: Colors.white70),
              label: const Text(
                'Exporter métriques actuelles',
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Métriques en direct:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.gold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final stats = PerfService().getStats();
                  final battery =
                      (stats['battery_samples'] as List?)?.lastOrNull;
                  final frames = stats['frames'] as Map?;

                  return Text(
                    'Battery : ${battery?['level']}% (${battery?['current_uA']} uA)\n'
                    'Frames  : ${frames?['global']?['count']} (Jank: ${frames?['global']?['jank_ratio']?.toStringAsFixed(2)})\n'
                    'Memory  : ${(stats['resource_samples'] as List?)?.lastOrNull?['java_heap_mb']} MB (Java)',
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
