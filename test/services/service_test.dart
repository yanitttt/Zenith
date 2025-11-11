import 'package:flutter_test/flutter_test.dart';
import 'package:recommandation_mobile/services/ImcService.dart';

void main() {
  group('IMCcalculator', () {
    test('calcule correctement un IMC valide', () {
      final calc = IMCcalculator(height: 1.75, weight: 70);
      final imc = calc.calculateIMC();

      // 70 / (1.75²) = 22.86
      expect(imc, closeTo(22.86, 0.01));
    });

    test('retourne la bonne catégorie IMC', () {
      expect(IMCcalculator(height: 1.80, weight: 55).getIMCCategory(), 'Sous-poids');
      expect(IMCcalculator(height: 1.75, weight: 70).getIMCCategory(), 'Poids normal');
      expect(IMCcalculator(height: 1.60, weight: 80).getIMCCategory(), 'Sur-poids');
    });

    test('lève une erreur si taille <= 0', () {
      expect(() => IMCcalculator(height: 0, weight: 70).calculateIMC(), throwsArgumentError);
    });
  });
}