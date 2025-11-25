class IMCcalculator {
  final double height; // in meters
  final double weight; // in kilograms

  IMCcalculator({required this.height, required this.weight});

  double calculateIMC() {
    if (height <= 0) {
      throw ArgumentError("Le poids doit être un nombre positif.");
    }

    final tailleM = height > 10 ? height / 100 : height; //conversion en m

    return weight / (tailleM * tailleM);
  }

  String getIMCCategory() {
    double imc = calculateIMC();
    if (imc < 18.5) {
      return "Sous-poids";
    } else if (imc >= 18.5 && imc < 24.9) {
      return "Poids normal";
    } else {
      return "Sur-poids";
    }
  }
}