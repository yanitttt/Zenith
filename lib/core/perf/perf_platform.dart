import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Wrapper pour le channel natif Android de performance.
class PerfPlatform {
  static const MethodChannel _channel = MethodChannel(
    'com.example.recommandation_mobile/perf',
  );

  /// Récupère les infos batterie (niveau, statut, température, courant).
  /// Retourne null si non supporté ou erreur.
  static Future<Map<String, dynamic>?> getBatteryInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getBatteryInfo',
      );
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('⚠️ Erreur batterie native: ${e.message}');
      return null;
    }
  }

  /// Récupère les infos ressources (CPU, Mémoire).
  /// Retourne null si non supporté ou erreur.
  static Future<Map<String, dynamic>?> getResourceInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getResourceInfo',
      );
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('⚠️ Erreur ressources native: ${e.message}');
      return null;
    }
  }
}
