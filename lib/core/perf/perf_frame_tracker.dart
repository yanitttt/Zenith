import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// Classe responsable de la collecte des métriques de frames (rendu UI).
class PerfFrameTracker {
  final List<FrameTiming> _frames = [];
  String _currentScreen = 'Unknown';

  // Stockage des sessions par écran
  final Map<String, List<FrameTiming>> _screenSessions = {};

  void start() {
    SchedulerBinding.instance.addTimingsCallback(_onFrame);
  }

  void stop() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrame);
  }

  void setCurrentScreen(String screenName) {
    if (_currentScreen == screenName) return;

    debugPrint('📱 Changement écran perf: $_currentScreen -> $screenName');
    _currentScreen = screenName;
    _screenSessions.putIfAbsent(screenName, () => []);
  }

  void _onFrame(List<FrameTiming> timings) {
    if (_currentScreen == 'Unknown') return;

    _frames.addAll(timings);

    if (_screenSessions.containsKey(_currentScreen)) {
      _screenSessions[_currentScreen]!.addAll(timings);
    }

    // Détection basique de Jank (frames > 16ms soit < 60fps)
    for (final timing in timings) {
      final duration = timing.totalSpan.inMilliseconds;
      if (duration > 16) {
        // debugPrint('⚠️ Jank détecté sur $_currentScreen: ${duration}ms');
      }
    }
  }

  /// Calcule les statistiques globales et par écran.
  Map<String, dynamic> getStats() {
    return {
      'global': _calculateStats(_frames),
      'screens': _screenSessions.map(
        (key, value) => MapEntry(key, _calculateStats(value)),
      ),
    };
  }

  Map<String, dynamic> _calculateStats(List<FrameTiming> timings) {
    if (timings.isEmpty) return {'count': 0};

    final sortedDurations =
        timings.map((t) => t.totalSpan.inMicroseconds / 1000.0).toList()
          ..sort();

    final count = sortedDurations.length;
    final p50 = sortedDurations[(count * 0.50).toInt()];
    final p90 = sortedDurations[(count * 0.90).toInt()];
    final p99 = sortedDurations[(count * 0.99).toInt()];
    final worst = sortedDurations.last;

    // Jank: > 16.6ms (60fps) et > 33.3ms (30fps)
    final jank16 = sortedDurations.where((d) => d > 16.6).length;
    final jank32 = sortedDurations.where((d) => d > 33.3).length;

    return {
      'count': count,
      'p50_ms': p50,
      'p90_ms': p90,
      'p99_ms': p99,
      'worst_ms': worst,
      'jank_16ms_count': jank16,
      'jank_32ms_count': jank32,
      'jank_ratio': count > 0 ? jank16 / count : 0.0,
    };
  }
}
