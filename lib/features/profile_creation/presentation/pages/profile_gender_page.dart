import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';

/// Page de sélection du genre lors de la création du profil
class ProfileGenderPage extends StatefulWidget {
  final UserProfileModel userProfile;

  const ProfileGenderPage({
    super.key,
    required this.userProfile,
  });

  @override
  State<ProfileGenderPage> createState() => _ProfileGenderPageState();
}

class _ProfileGenderPageState extends State<ProfileGenderPage> {
  String? _selectedGender;

  void _onGenderSelected(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _onNextPressed() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner votre genre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mise à jour du modèle
    final updatedProfile = widget.userProfile.copyWith(
      gender: _selectedGender,
    );

    // TODO: Naviguer vers la page suivante ou terminer l'onboarding
    // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage(profile: updatedProfile)));

    // Pour l'instant, afficher les données complètes
    debugPrint('Profil complet: ${updatedProfile.toJson()}');

    // Message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil créé: ${updatedProfile.name}, ${updatedProfile.age}, ${updatedProfile.gender}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label "GENRE" en haut à gauche
              const Text(
                'GENRE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Section titre centrée
              Center(
                child: Column(
                  children: [
                    const Text(
                      'À propos de toi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pour te fournir la meilleur expérience\npossible en fonction de ton genre',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Boutons de sélection du genre
              Center(
                child: Column(
                  children: [
                    // Bouton Femmelle
                    _GenderButton(
                      label: 'Femmelle',
                      icon: Icons.female,
                      isSelected: _selectedGender == 'female',
                      backgroundColor: const Color(0xFFD4A855),
                      textColor: Colors.black,
                      onTap: () => _onGenderSelected('female'),
                    ),

                    const SizedBox(height: 40),

                    // Bouton Mâle
                    _GenderButton(
                      label: 'Mâle',
                      icon: Icons.male,
                      isSelected: _selectedGender == 'male',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      onTap: () => _onGenderSelected('male'),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Boutons navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton retour
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Bouton "Suivant"
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A855),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Suivant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget personnalisé pour les boutons de sélection du genre
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: textColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
