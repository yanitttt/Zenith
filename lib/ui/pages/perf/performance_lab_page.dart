import 'package:flutter/material.dart';
import 'package:recommandation_mobile/core/perf/perf_service.dart';
import 'package:recommandation_mobile/core/perf/perf_report.dart';
import 'package:recommandation_mobile/core/perf/complexity_analyzer.dart';
import 'package:recommandation_mobile/core/perf/perf_monitor_widget.dart';
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
        for (int i = 0; i < 100000; i++) sum += i;
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
      body: Padding(
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
            const Text('Métriques en direct:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final stats = PerfService().getStats();
                  final battery =
                      (stats['battery_samples'] as List?)?.lastOrNull;
                  final frames = stats['frames'] as Map?;

                  return SingleChildScrollView(
                    child: Text(
                      'Battery: ${battery?['level']}% (${battery?['current_uA']} uA)\n'
                      'Frames: ${frames?['global']?['count']} (Jank: ${frames?['global']?['jank_ratio']?.toStringAsFixed(2)})\n'
                      'Memory (Java): ${(stats['resource_samples'] as List?)?.lastOrNull?['java_heap_mb']} MB',
                      style: const TextStyle(fontFamily: 'Courier'),
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
