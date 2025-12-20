import 'dart:async';
import 'package:flutter/foundation.dart';
import 'perf_config.dart';
import 'perf_native.dart';

/// Module de surveillance de la mémoire vive.
/// Capture des snapshots réguliers de la mémoire utilisée par l'application.
class PerfMemory {
  static final PerfMemory _instance = PerfMemory._internal();

  factory PerfMemory() => _instance;

  PerfMemory._internal();

  Timer? _timer;
  final List<Map<String, dynamic>> _snapshots = [];

  /// Retourne les snapshots capturés.
  List<Map<String, dynamic>> get snapshots => List.unmodifiable(_snapshots);

  /// Démarre le monitoring périodique.
  /// [interval] : fréquence de capture (défaut 2 secondes).
  void start({Duration interval = const Duration(seconds: 2)}) {
    if (!PerfConfig.isPerfMode) return;
    stop(); // Sécurité

    // Capture immédiate
    _capture();

    _timer = Timer.periodic(interval, (_) => _capture());
    debugPrint('[PERF-MEMORY] Monitoring Mémoire Démarré');
  }

  /// Arrête le monitoring.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Efface les données enregistrées.
  void clear() {
    _snapshots.clear();
  }

  Future<void> _capture() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final memInfo = await PerfNative.getMemoryInfo();

    if (memInfo.isNotEmpty) {
      _snapshots.add({'timestamp': now, ...memInfo});
    }
  }
}
