/// Model représentant le profil utilisateur
/// Contient toutes les informations collectées lors de la création du profil
class UserProfileModel {
  final String name;
  final String? age;
  final String? fitnessLevel;
  final List<String>? goals;
  final String? gender;

  const UserProfileModel({
    required this.name,
    this.age,
    this.fitnessLevel,
    this.goals,
    this.gender,
  });

  /// Crée une instance vide (valeurs par défaut pour le développement)
  factory UserProfileModel.empty() {
    return const UserProfileModel(
      name: '',
      age: null,
      fitnessLevel: null,
      goals: null,
      gender: null,
    );
  }

  /// Copie le modèle avec de nouvelles valeurs
  UserProfileModel copyWith({
    String? name,
    String? age,
    String? fitnessLevel,
    List<String>? goals,
    String? gender,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      age: age ?? this.age,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goals: goals ?? this.goals,
      gender: gender ?? this.gender,
    );
  }

  /// Convertit le modèle en Map (pour la sauvegarde)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'fitnessLevel': fitnessLevel,
      'goals': goals,
      'gender': gender,
    };
  }

  /// Crée une instance depuis un Map
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String? ?? '',
      age: json['age'] as String?,
      fitnessLevel: json['fitnessLevel'] as String?,
      goals: (json['goals'] as List<dynamic>?)?.cast<String>(),
      gender: json['gender'] as String?,
    );
  }
}
