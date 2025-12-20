import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'perf_config.dart';

/// Module responsable de mesurer les performances de rendu UI (Raster/Build).
class PerfUI {
  static final PerfUI _instance = PerfUI._internal();

  factory PerfUI() => _instance;

  PerfUI._internal();

  /// Liste des timings de frames collectés
  final List<FrameTiming> _frames = [];

  // Statistiques en cache
  int _totalFrames = 0;
  int _jankCount16ms = 0; // Frames > 16ms (~60fps)
  int _jankCount32ms = 0; // Frames > 32ms (~30fps)

  // Limites approximatives pour détecter un Jank (en microsecondes)
  // 16ms = 16666µs
  static const int _k16ms = 16666;
  static const int _k32ms = 33333;

  /// Active l'écoute des timings de frames.
  void init() {
    if (!PerfConfig.isPerfMode) return;

    // On s'assure de ne pas ajouter plusieurs fois le callback
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
    debugPrint('[PERF-UI] Frame Tracking Initialisé');
  }

  /// Arrête l'écoute.
  void stop() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  /// Reset des compteurs (utile entre deux scénarios).
  void reset() {
    _frames.clear();
    _totalFrames = 0;
    _jankCount16ms = 0;
    _jankCount32ms = 0;
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    if (timings.isEmpty) return;

    for (final timing in timings) {
      _totalFrames++;
      final duration = timing.totalSpan.inMicroseconds;

      if (duration > _k16ms) {
        _jankCount16ms++;
      }
      if (duration > _k32ms) {
        _jankCount32ms++;
      }
      _frames.add(timing);
    }
  }

  /// Récupère un résumé des stats, utile pour le rapport JSON.
  Map<String, dynamic> getStats() {
    if (_frames.isEmpty) {
      return {
        'total_frames': 0,
        'avg_ms': 0.0,
        'p90_ms': 0.0,
        'p99_ms': 0.0,
        'max_ms': 0.0,
        'jank_16ms_count': 0,
        'jank_32ms_count': 0,
      };
    }

    // Calcul des centiles
    // On travaille sur totalSpan (raster + build + vsync overhead)
    final durations = _frames.map((f) => f.totalSpan.inMicroseconds).toList();
    durations.sort();

    final count = durations.length;
    final avg = durations.reduce((a, b) => a + b) / count;
    final max = durations.last;

    // P90 index
    final p90Index = (count * 0.90).ceil() - 1;
    final p90 = durations[p90Index < 0 ? 0 : p90Index];

    // P99 index
    final p99Index = (count * 0.99).ceil() - 1;
    final p99 = durations[p99Index < 0 ? 0 : p99Index];

    return {
      'total_frames': _totalFrames,
      'avg_ms': (avg / 1000).toStringAsFixed(2),
      'p90_ms': (p90 / 1000).toStringAsFixed(2),
      'p99_ms': (p99 / 1000).toStringAsFixed(2),
      'max_ms': (max / 1000).toStringAsFixed(2),
      'jank_16ms_count': _jankCount16ms,
      'jank_32ms_count': _jankCount32ms,
    };
  }
}
