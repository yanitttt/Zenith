import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PerformanceMonitorService {
  static final PerformanceMonitorService _instance =
      PerformanceMonitorService._internal();

  factory PerformanceMonitorService() {
    return _instance;
  }

  PerformanceMonitorService._internal();

  final Map<String, int> _startTimes = {};
  final Map<String, dynamic> _metrics = {};
  final Map<String, dynamic> _metadata = {};

  void startMetric(String name) {
    _startTimes[name] = DateTime.now().millisecondsSinceEpoch;
  }

  void stopMetric(String name) {
    final startTime = _startTimes[name];
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      _metrics[name] = duration;
      _startTimes.remove(name);
    }
  }

  void addMetadata(String key, dynamic value) {
    _metadata[key] = value;
  }

  Future<Map<String, dynamic>> generateReport() async {
    final memoryUsage = ProcessInfo.currentRss;

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'metrics_ms': Map<String, dynamic>.from(_metrics),
      'metadata': Map<String, dynamic>.from(_metadata),
      'memory_rss_bytes': memoryUsage,
      'platform': Platform.operatingSystem,
      'dart_version': Platform.version,
    };
  }

  Map<String, dynamic>? _lastReport;

  Map<String, dynamic>? get lastReport => _lastReport;

  Future<void> saveReport(String fileNamePrefix) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${directory.path}/performance_reports');
      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }

      final report = await generateReport();
      _lastReport = report;
      final jsonReport = jsonEncode(report);

      debugPrint('--- PERFORMANCE REPORT START ---');
      debugPrint(jsonReport);
      debugPrint('--- PERFORMANCE REPORT END ---');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${reportDir.path}/${fileNamePrefix}_$timestamp.json');

      await file.writeAsString(jsonReport);
      debugPrint('[PERFORMANCE] Report saved to ${file.path}');

      // Clear metrics after saving? Maybe optional. For now, let's clear.
      clear();
    } catch (e) {
      debugPrint('[PERFORMANCE] Error saving report: $e');
    }
  }

  void clear() {
    _startTimes.clear();
    _metrics.clear();
    _metadata.clear();
  }
}
