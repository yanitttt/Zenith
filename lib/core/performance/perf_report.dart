import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'perf_core.dart';
import 'perf_ui.dart';
import 'perf_memory.dart';
import 'perf_native.dart';
import 'perf_config.dart';

/// Classe gérant la consolidation et l'export du rapport de performance.
class PerfReport {
  /// Génère le rapport complet au format Map (prêt pour JSON).
  static Future<Map<String, dynamic>> generate({
    required String scenarioName,
  }) async {
    if (!PerfConfig.isPerfMode) return {};

    final uiStats = PerfUI().getStats();
    final actionMeasures = PerfCore().measures.map((m) => m.toJson()).toList();
    final memorySnapshots = PerfMemory().snapshots;

    // Infos device snapshot à la fin
    final batteryInfo = await PerfNative.getBatteryInfo();
    final cpuInfo = await PerfNative.getCpuInfo();

    final now = DateTime.now();
    final String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    return {
      'meta': {
        'scenario': scenarioName,
        'timestamp': timestamp,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      },
      'device_metrics': {'battery': batteryInfo, 'cpu': cpuInfo},
      'ui_metrics': uiStats,
      'actions': actionMeasures,
      'memory_history': memorySnapshots,
    };
  }

  /// Sauvegarde le rapport en JSON localement et propose le partage.
  static Future<void> saveAndShare({required String scenarioName}) async {
    if (!PerfConfig.isPerfMode) return;

    try {
      final report = await generate(scenarioName: scenarioName);
      final jsonString = const JsonEncoder.withIndent('  ').convert(report);

      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName =
          'perf_report_${scenarioName.replaceAll(" ", "_")}_$dateStr.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);
      debugPrint('[PERF-REPORT] Rapport sauvegardé : ${file.path}');

      // Partage du fichier
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Rapport Performance PROJET: $scenarioName');
    } catch (e) {
      debugPrint('[PERF-REPORT] Erreur lors de l\'export : $e');
    }
  }
}
