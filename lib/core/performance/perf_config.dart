// ignore_for_file: avoid_classes_with_only_static_members

/// Configuration globale pour le module de performance.
/// Ce module n'est activé que si le flag de compilation --dart-define=PERF_MODE=true est passé.
class PerfConfig {
  static final PerfConfig _instance = PerfConfig._internal();

  factory PerfConfig() => _instance;

  PerfConfig._internal();

  /// Récupère la valeur du flag PERF_MODE depuis l'environnement.
  /// Valeur par défaut : false (inactif en prod classique)
  static const bool isPerfMode = bool.fromEnvironment(
    'PERF_MODE',
    defaultValue: false,
  );

  /// Indique si l'initialisation a déjà eu lieu
  bool _initialized = false;

  /// Initialise la configuration
  void init() {
    if (_initialized) return;
    _initialized = true;
    if (isPerfMode) {
      // ignore: avoid_print
      print('[PERF] Mode Performance ACTIVÉ');
    }
  }
}
