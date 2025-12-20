import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recommandation_mobile/main.dart' as app;
import 'package:recommandation_mobile/core/perf/perf_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Performance Baseline Test', (tester) async {
    // 1. Lancer l'application
    app.main();
    await tester.pumpAndSettle();

    // 2. Vérifier si on est en mode Perf
    // Note: Le test doit être lancé avec --dart-define=PERF_MODE=true
    // On peut vérifier la présence de l'onglet "Perf" dans la BottomNavBar
    final perfTabFinder = find.byIcon(Icons.speed);
    if (!perfTabFinder.evaluate().isNotEmpty) {
      fail(
        'Le mode PERF_MODE n\'est pas activé. Lancer avec --dart-define=PERF_MODE=true',
      );
    }

    // 3. Naviguer vers l'onglet Performance
    await tester.tap(perfTabFinder);
    await tester.pumpAndSettle();

    // Vérifier qu'on est sur la page
    expect(find.text('Performance Lab'), findsOneWidget);

    // 4. Lancer le Scénario A (CPU/Réseau)
    print('🚀 Lancement Scénario A...');
    final btnScenarioA = find.text('Lancer Scénario A (Test CPU/Res)');
    await tester.tap(btnScenarioA);

    // Attendre la fin du scénario (il y a des délais simulateurs de ~2s au total)
    // On pompe des frames jusqu'à ce que le statut indique "Rapport partagé" ou que le bouton soit réactivé
    // Le scénario A met environ 1.5s + overhead
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 5. Lancer l'Analyse RecService (SQL + Algo)
    print('🚀 Lancement Analyse RecService...');
    final btnRecService = find.text('Analyse RecService (SQL)');
    // Scroll si besoin (si l'écran est petit)
    await tester.scrollUntilVisible(btnRecService, 50.0);
    await tester.tap(btnRecService);

    // Cette analyse fait plusieurs requêtes SQL et benchmarks
    await tester.pumpAndSettle(const Duration(seconds: 5));

    print('✅ Tests de performance terminés avec succès.');
    // Les rapports sont générés dans le dossier de l'app ou loggés.
  });
}
