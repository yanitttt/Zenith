import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'perf_config.dart';

/// Interface avec le code natif (Android) pour récupérer les métriques système.
class PerfNative {
  static const MethodChannel _channel = MethodChannel(
    'com.example.recommandation_mobile/perf',
  );

  /// Récupère les infos batterie (Niveau %, Statut, Courant, Température ...).
  /// Retourne une Map vide si échec ou non supporté.
  static Future<Map<String, dynamic>> getBatteryInfo() async {
    if (!PerfConfig.isPerfMode) return {};
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getBatteryInfo',
      );
      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      debugPrint('[PERF-NATIVE] Erreur getBatteryInfo: ${e.message}');
      return {};
    }
  }

  /// Récupère des infos CPU approximatives (si accessible).
  static Future<Map<String, dynamic>> getCpuInfo() async {
    if (!PerfConfig.isPerfMode) return {};
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getCpuInfo',
      );
      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      debugPrint('[PERF-NATIVE] Erreur getCpuInfo: ${e.message}');
      return {};
    }
  }

  /// Récupère les infos mémoire du process (via Debug.getMemoryInfo).
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    if (!PerfConfig.isPerfMode) return {};
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getMemoryInfo',
      );
      return result?.cast<String, dynamic>() ?? {};
    } on PlatformException catch (e) {
      debugPrint('[PERF-NATIVE] Erreur getMemoryInfo: ${e.message}');
      return {};
    }
  }
}
