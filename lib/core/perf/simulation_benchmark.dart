import 'package:flutter/foundation.dart';
import 'package:recommandation_mobile/core/perf/perf_service.dart';

class SimulationBenchmark {
  /// Simulates a naive implementation:
  /// Iterating N times with a database call inside the loop.
  ///
  /// Each fake DB call takes ~2ms (I/O latency).
  static Future<int> simulateLegacy(int n) async {
    final stopwatch = Stopwatch()..start();

    // N+1 pattern: 1 query per item
    for (int i = 0; i < n; i++) {
      await _fakeDbCall(); // Mimic SELECT * FROM ... WHERE id = i
      _heavyCalculation(); // Mimic computing adjustment
    }

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// Simulates an optimized implementation:
  /// Fetching all N items in 1 batch query, then processing in memory.
  ///
  /// The batch query takes ~5ms (slightly longer than 1 simple query),
  /// but it happens only once.
  static Future<int> simulateOptimized(int n) async {
    final stopwatch = Stopwatch()..start();

    // Batch pattern: 1 query for all items
    await _fakeDbCall(latencyMs: 5); // Mimic SELECT ... WHERE id IN (...)

    // Processing loop (Memory only, no awaiting)
    for (int i = 0; i < n; i++) {
      _heavyCalculation();
    }

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  static Future<void> _fakeDbCall({int latencyMs = 2}) async {
    // Simulate async I/O delay
    await Future.delayed(Duration(milliseconds: latencyMs));
  }

  static void _heavyCalculation() {
    // Simulate some CPU work (negligible compared to I/O, but present)
    // e.g. Math.sqrt, loop, object creation
    int sum = 0;
    for (int j = 0; j < 100; j++) {
      sum += j;
    }
    if (sum < 0) debugPrint('$sum'); // Prevent dead code elimination
  }

  /// Returns structured data for visualization
  static Future<List<BenchmarkDataPoint>> runFullSuiteData() async {
    final sizes = [10, 20, 30, 40, 50, 100];
    final List<BenchmarkDataPoint> results = [];

    for (final n in sizes) {
      final tLegacy = await simulateLegacy(n);
      final tOptimized = await simulateOptimized(n);

      results.add(BenchmarkDataPoint(n, tLegacy, tOptimized));
      debugPrint('Sim N=$n -> Legacy: ${tLegacy}ms | Opt: ${tOptimized}ms');
    }
    return results;
  }

  /// Runs the full comparative suite returning a Markdown report string
  static Future<String> runFullSuite() async {
    final data = await runFullSuiteData();
    final buffer = StringBuffer();
    buffer.writeln('--- RESULTATS SIMULATION STRESS TEST ---');
    buffer.writeln('N;Legacy(ms);Optimized(ms)');

    for (final point in data) {
      buffer.writeln('${point.n};${point.legacyMs};${point.optimizedMs}');
    }

    return buffer.toString();
  }
}

class BenchmarkDataPoint {
  final int n;
  final int legacyMs;
  final int optimizedMs;

  BenchmarkDataPoint(this.n, this.legacyMs, this.optimizedMs);
}
