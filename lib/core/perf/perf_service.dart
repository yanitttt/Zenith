import 'package:flutter/foundation.dart';

import 'dart:async';

import 'perf_frame_tracker.dart';
import 'perf_platform.dart';

/// Central performance metrics manager (Singleton).
class PerfService {
  static final PerfService _instance = PerfService._internal();

  factory PerfService() {
    return _instance;
  }

  PerfService._internal();

  /// Compile-time flag: --dart-define=PERF_MODE=true
  static const bool isPerfMode = bool.fromEnvironment(
    'PERF_MODE',
    defaultValue: false,
  );

  final PerfFrameTracker _frameTracker = PerfFrameTracker();
  Timer? _pollingTimer;
  final List<Map<String, dynamic>> _batterySamples = [];
  final List<Map<String, dynamic>> _resourceSamples = [];

  /// No-op if not in Perf Mode.
  void init() {
    if (!isPerfMode) return;

    debugPrint('🚀 Mode Performance ACTIVE');
    _frameTracker.start();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 2s
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final now = DateTime.now().toIso8601String();

      final battery = await PerfPlatform.getBatteryInfo();
      if (battery != null) {
        _batterySamples.add({'t': now, ...battery});
      }

      final resources = await PerfPlatform.getResourceInfo();
      if (resources != null) {
        _resourceSamples.add({'t': now, ...resources});
      }
    });
  }

  /// Tracks screen change.
  void onScreenChanged(String screenName) {
    if (!isPerfMode) return;
    _frameTracker.setCurrentScreen(screenName);
  }

  /// Measures async execution time.
  Future<T> measure<T>(
    String actionName,
    Future<T> Function() action, {
    Map<String, dynamic>? tags,
  }) async {
    if (!isPerfMode) return action();

    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('⏱️ Action "$actionName": ${ms}ms');
      logAlgoMetric({
        'name': actionName,
        'duration_ms': ms,
        'timestamp': DateTime.now().toIso8601String(),
        if (tags != null) ...tags,
      });
    }
  }

  /// Measures sync execution time.
  T measureSync<T>(
    String actionName,
    T Function() action, {
    Map<String, dynamic>? tags,
  }) {
    if (!isPerfMode) return action();

    final stopwatch = Stopwatch()..start();
    try {
      return action();
    } finally {
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('⏱️ Action "$actionName": ${ms}ms');
      logAlgoMetric({
        'name': actionName,
        'duration_ms': ms,
        'timestamp': DateTime.now().toIso8601String(),
        if (tags != null) ...tags,
      });
    }
  }

  final List<Map<String, dynamic>> _uiMetrics = [];
  final List<Map<String, dynamic>> _algoMetrics = [];

  // ... (existing code)

  /// Log UI metric (PerfMonitorWidget)
  void logUIMetric(Map<String, dynamic> metric) {
    if (!isPerfMode) return;
    _uiMetrics.add(metric);
  }

  /// Log Algo metric (ComplexityAnalyzer)
  void logAlgoMetric(Map<String, dynamic> metric) {
    if (!isPerfMode) return;
    _algoMetrics.add(metric);
  }

  /// Get current stats (for report)
  Map<String, dynamic> getStats() {
    return {
      'frames': _frameTracker.getStats(),
      'battery_samples': _batterySamples,
      'resource_samples': _resourceSamples,
      'ui_metrics': _uiMetrics,
      'algo_metrics': _algoMetrics,
      'duration_seconds':
          _pollingTimer?.tick != null ? _pollingTimer!.tick * 2 : 0,
    };
  }
}
