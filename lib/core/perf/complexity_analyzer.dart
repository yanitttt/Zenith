import 'package:flutter/foundation.dart';
import 'perf_service.dart';

/// Types de complexité supportés pour l'estimation.
enum ComplexityType {
  constant, // O(1)
  linear, // O(n)
  quadratic, // O(n^2)
  exponential, // O(e^n) - non implémenté
  unknown,
}

/// Résultat d'une analyse de complexité.
class ComplexityResult {
  final String metricName;
  final Map<int, int> timingsMicroseconds; // n -> duration
  final ComplexityType estimatedComplexity;

  ComplexityResult({
    required this.metricName,
    required this.timingsMicroseconds,
    required this.estimatedComplexity,
  });

  Map<String, dynamic> toJson() {
    return {
      'metric': metricName,
      'complexity': estimatedComplexity.toString().split('.').last,
      'timings_us': timingsMicroseconds.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
    };
  }

  @override
  String toString() {
    return 'ComplexityResult($metricName): $estimatedComplexity\nDetails: $timingsMicroseconds';
  }
}

/// Utilitaire pour estimer la complexité algorithmique d'une fonction.
class ComplexityAnalyzer {
  /// Analyse une fonction [workload] qui prend un paramètre de taille [n].
  /// On exécute la fonction avec des valeurs de N croissantes.
  /// [inputSizes] définit les valeurs de N à tester (défaut: 10, 100, 1000, 5000).
  static Future<ComplexityResult> analyze({
    required String name,
    required Function(int n) workload,
    List<int> inputSizes = const [10, 100, 1000, 5000],
  }) async {
    debugPrint('🔬 Analyse de complexité pour "$name"...');
    final timings = <int, int>{};

    for (final n in inputSizes) {
      // Warmup (chauffer le JIT)
      try {
        workload(inputSizes.first);
      } catch (_) {}

      final stopwatch = Stopwatch()..start();
      try {
        await Future.value(workload(n)); // Supporte sync et async
      } catch (e) {
        debugPrint('⚠️ Erreur dans workload($n): $e');
      }
      stopwatch.stop();
      timings[n] = stopwatch.elapsedMicroseconds;
    }

    final complexity = _estimateComplexity(timings);

    final result = ComplexityResult(
      metricName: name,
      timingsMicroseconds: timings,
      estimatedComplexity: complexity,
    );

    _printReport(result);
    // Enregistrement dans le service de perf
    PerfService().logAlgoMetric(result.toJson());

    return result;
  }

  static ComplexityType _estimateComplexity(Map<int, int> timings) {
    if (timings.length < 3) return ComplexityType.unknown;

    final entries = timings.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    // Analyse grossière de la pente
    double scoreLinear = 0;
    double scoreQuadratic = 0;

    for (int i = 1; i < entries.length; i++) {
      final n1 = entries[i - 1].key;
      final t1 = entries[i - 1].value;
      final n2 = entries[i].key;
      final t2 = entries[i].value;

      if (t1 <= 0) continue;

      final ratioN = n2 / n1;
      final ratioT = t2 / t1;

      // O(1) : le temps ne bouge pas (ratioT ~ 1)
      if (ratioT < 1.2) {
        // C'est constant
        continue;
      }

      // O(n) : ratio temps ~= ratio N
      if ((ratioT - ratioN).abs() < ratioN * 0.5) {
        scoreLinear++;
      }

      // O(n^2) : ratio temps ~= ratio N^2
      if ((ratioT - (ratioN * ratioN)).abs() < (ratioN * ratioN) * 0.5) {
        scoreQuadratic++;
      }
    }

    // Le paramètre de décision est basique, à affiner pour de la vraie science
    if (scoreQuadratic > scoreLinear) return ComplexityType.quadratic;
    if (scoreLinear > 0) return ComplexityType.linear;

    // Si ca monte pas beaucoup
    final first = entries.first.value;
    final last = entries.last.value;
    if (last < first * 1.5) return ComplexityType.constant;

    return ComplexityType.unknown;
  }

  static void _printReport(ComplexityResult result) {
    debugPrint('📊 Résultat Analyse complexité: ${result.metricName}');
    debugPrint(
      '   Estimation: ${result.estimatedComplexity.toString().split('.').last}',
    );
    result.timingsMicroseconds.forEach((n, t) {
      debugPrint('   N=$n : ${t / 1000} ms');
    });
  }
}
