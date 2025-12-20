import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'perf_config.dart';

/// Classe principale pour les mesures de performance "métier" (actions, calculs).
class PerfCore {
  static final PerfCore _instance = PerfCore._internal();

  factory PerfCore() => _instance;

  PerfCore._internal();

  final List<PerfMeasure> _measures = [];

  /// Retourne une copie des mesures enregistrées
  List<PerfMeasure> get measures => List.unmodifiable(_measures);

  /// Efface toutes les mesures stockées
  void clear() {
    _measures.clear();
  }

  /// Mesure le temps d'exécution d'une fonction asynchrone [action].
  /// [name] est le nom de l'action pour le rapport.
  Future<T> measure<T>(String name, Future<T> Function() action) async {
    if (!PerfConfig.isPerfMode) {
      return action();
    }

    final int start = DateTime.now().millisecondsSinceEpoch;
    // Utilisation de Timeline pour visualisation dans Flutter DevTools
    dev.Timeline.startSync(name);

    try {
      final result = await action();
      return result;
    } finally {
      dev.Timeline.finishSync();
      final int end = DateTime.now().millisecondsSinceEpoch;
      final int duration = end - start;

      _measures.add(
        PerfMeasure(name: name, startTime: start, durationMs: duration),
      );

      // Log immédiat pour debug
      debugPrint('[PERF] Action "$name" : ${duration}ms');
    }
  }

  /// Mesure le temps d'exécution d'une fonction synchrone [action].
  T measureSync<T>(String name, T Function() action) {
    if (!PerfConfig.isPerfMode) {
      return action();
    }

    final int start = DateTime.now().millisecondsSinceEpoch;
    dev.Timeline.startSync(name);

    try {
      final result = action();
      return result;
    } finally {
      dev.Timeline.finishSync();
      final int end = DateTime.now().millisecondsSinceEpoch;
      final int duration = end - start;

      _measures.add(
        PerfMeasure(name: name, startTime: start, durationMs: duration),
      );

      debugPrint('[PERF] Action Sync "$name" : ${duration}ms');
    }
  }
}

/// Modèle simple pour stocker une mesure ponctuelle
class PerfMeasure {
  final String name;
  final int startTime;
  final int durationMs;

  PerfMeasure({
    required this.name,
    required this.startTime,
    required this.durationMs,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'start_time': startTime,
    'duration_ms': durationMs,
  };
}
