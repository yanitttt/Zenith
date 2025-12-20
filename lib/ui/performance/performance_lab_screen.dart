import 'package:flutter/material.dart';
import 'package:recommandation_mobile/core/performance/perf_config.dart';
import 'package:recommandation_mobile/core/performance/perf_session_manager.dart';

/// Écran "Performance Lab" pour piloter les sessions de test.
/// Accessible uniquement si PERF_MODE = true.
class PerformanceLabScreen extends StatefulWidget {
  const PerformanceLabScreen({super.key});

  @override
  State<PerformanceLabScreen> createState() => _PerformanceLabScreenState();
}

class _PerformanceLabScreenState extends State<PerformanceLabScreen> {
  final _manager = PerfSessionManager();
  late TextEditingController _scenarioController;

  @override
  void initState() {
    super.initState();
    _scenarioController = TextEditingController(
      text: _manager.currentScenarioName,
    );
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_manager.isRecording) {
      _manager.stopSessionAndExport().then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⬛ Enregistrement terminé. Rapport généré.'),
            ),
          );
        }
      });
    } else {
      _manager.startSession();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔴 Enregistrement perf démarré...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!PerfConfig.isPerfMode) {
      return const Scaffold(
        body: Center(child: Text('Mode Performance désactivé.')),
      );
    }

    return AnimatedBuilder(
      animation: _manager,
      builder: (context, child) {
        final isRecording = _manager.isRecording;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Performance Lab ⚡'),
            backgroundColor: isRecording ? Colors.red : Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  "Contrôle de Session",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: !isRecording,
                  decoration: const InputDecoration(
                    labelText: "Nom du scénario",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _manager.setScenarioName(val),
                  controller: _scenarioController,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.fiber_manual_record,
                    ),
                    label: Text(
                      isRecording
                          ? "ARRÊTER & EXPORTER"
                          : "DÉMARRER ENREGISTREMENT",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                if (isRecording) ...[
                  const Center(
                    child: Text(
                      "🔴 ENREGISTREMENT EN COURS...\nVous pouvez quitter cet écran et naviguer dans l'app.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                const Divider(),
                const Text(
                  "Moniteurs Actifs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.speed),
                  title: const Text("Frame Timing (UI)"),
                  subtitle: const Text("Détection Jank (>16ms), FPS"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
                ListTile(
                  leading: const Icon(Icons.memory),
                  title: const Text("Mémoire & OS"),
                  subtitle: const Text("Heap, Native Battery/CPU"),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
