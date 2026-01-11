import 'package:flutter/material.dart';
import 'package:recommandation_mobile/core/perf/perf_service.dart';
import 'package:recommandation_mobile/core/perf/perf_report.dart';
import 'package:recommandation_mobile/core/perf/complexity_analyzer.dart';
import 'package:recommandation_mobile/core/perf/perf_monitor_widget.dart';
import 'package:recommandation_mobile/core/perf/simulation_benchmark.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/core/prefs/app_prefs.dart';
import 'package:recommandation_mobile/services/recommendation_service.dart';

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
      // Attention: faire varier la limite influe sur le post-processing mais moins sur la query si le WHERE est restrictif.
      // N = limit
      final cResult = await ComplexityAnalyzer.analyze(
        name: 'RecService_GetExercises',
        workload: (n) async {
          await service.getRecommendedExercises(userId: userId, limit: n);
        },
        inputSizes: [5, 10, 20, 50], // Petites valeurs car SQL
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

    // Exemple: Analyse de la construction d'une liste
    final result = await ComplexityAnalyzer.analyze(
      name: 'List_Generation',
      workload: (n) {
        final list = List.generate(n, (i) => i);
        // Simulation o(n)
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
      _status = 'Simulation terminée. Voir Graphique ci-dessous.';
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

    // Simuler du travail
    await PerfService().measure('Scenario_A_Total', () async {
      // 1. Calcul lourd (simulé)
      await PerfService().measure('Math_Heavy', () async {
        await Future.delayed(const Duration(milliseconds: 500));
        // Un peu de CPU
        int sum = 0;
        for (int i = 0; i < 100000; i++) {
          sum += i;
        }
        debugPrint('Sum: $sum');
      });

      // 2. Attente réseau (simulé)
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
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Status: $_status',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              PerfMonitorWidget(
                label: 'Btn_ScenarioA',
                child: ElevatedButton.icon(
                  onPressed: _isRecording ? null : _runScenarioA,
                  icon: const Icon(Icons.timer),
                  label: const Text('Lancer Scénario A (Test CPU/Res)'),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isRecording ? null : _runComplexityDemo,
                icon: const Icon(Icons.analytics),
                label: const Text('Démo Analyse O(n) (Liste)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isRecording ? null : _runRecommendationTest,
                icon: const Icon(Icons.fitness_center),
                label: const Text('Analyse RecService (SQL)'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isRecording ? null : _runSimulationBenchmark,
                icon: const Icon(Icons.speed),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Comparaison ancien algo de recommandation du "9 décembre" vs algo de recommandation optimisé',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "STRESS TEST",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              if (_benchmarkData != null) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vue : '),
                    Switch(
                      value: _showGraph,
                      onChanged: (v) => setState(() => _showGraph = v),
                      activeThumbColor: Colors.orange,
                    ),
                    Text(_showGraph ? 'Graphique' : 'Tableau'),
                  ],
                ),
                const SizedBox(height: 10),
                if (_showGraph)
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  'N=${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
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
                                return Text('${value.toInt()}ms');
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
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          // Legacy (Red)
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
                            color: Colors.redAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          // Optimized (Green)
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
                            color: Colors.greenAccent,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'N (Ex.)',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Naïf (ms)',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Opt. (ms)',
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
                      const Divider(),
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
                                  '${e.legacyMs}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${e.optimizedMs}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'x${gain.toStringAsFixed(1)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                const Center(
                  child: Text(
                    'Rouge: Naïf O(N) vs Vert: Optimisé O(1)',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              // TODO: Autres scénarios
              const Divider(),
              ElevatedButton.icon(
                onPressed: () async {
                  await PerfReport.generateAndShare('Manual_Export');
                },
                icon: const Icon(Icons.share),
                label: const Text('Exporter métriques actuelles'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Métriques en direct:',
                style: TextStyle(fontSize: 18),
              ),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final stats = PerfService().getStats();
                  final battery =
                      (stats['battery_samples'] as List?)?.lastOrNull;
                  final frames = stats['frames'] as Map?;

                  return Text(
                    'Battery: ${battery?['level']}% (${battery?['current_uA']} uA)\n'
                    'Frames: ${frames?['global']?['count']} (Jank: ${frames?['global']?['jank_ratio']?.toStringAsFixed(2)})\n'
                    'Memory (Java): ${(stats['resource_samples'] as List?)?.lastOrNull?['java_heap_mb']} MB',
                    style: const TextStyle(fontFamily: 'Courier'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
