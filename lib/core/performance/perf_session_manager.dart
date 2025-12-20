import 'package:flutter/foundation.dart';
import 'perf_core.dart';
import 'perf_memory.dart';
import 'perf_ui.dart';
import 'perf_report.dart';

/// Gestionnaire de session qui maintient l'état d'enregistrement globalement,
/// indépendamment des écrans (UI).
/// Singleton.
class PerfSessionManager extends ChangeNotifier {
  static final PerfSessionManager _instance = PerfSessionManager._internal();

  factory PerfSessionManager() => _instance;

  PerfSessionManager._internal();

  bool _isRecording = false;
  String _currentScenarioName = "Session Libre";

  bool get isRecording => _isRecording;
  String get currentScenarioName => _currentScenarioName;

  void setScenarioName(String name) {
    _currentScenarioName = name;
    notifyListeners();
  }

  void startSession() {
    if (_isRecording) return;
    _isRecording = true;
    notifyListeners();

    // Reset data
    PerfCore().clear();
    PerfUI().reset();
    PerfMemory().clear();

    // Start listeners
    PerfUI().init();
    PerfMemory().start(interval: const Duration(seconds: 1));

    debugPrint('[PERF-MANAGER] Session "$_currentScenarioName" démarrée');
  }

  Future<void> stopSessionAndExport() async {
    if (!_isRecording) return;

    _isRecording = false;
    notifyListeners();

    // Stop listeners
    PerfUI().stop();
    PerfMemory().stop();

    debugPrint('[PERF-MANAGER] Session terminée. Export...');

    // Export
    await PerfReport.saveAndShare(scenarioName: _currentScenarioName);
  }
}
