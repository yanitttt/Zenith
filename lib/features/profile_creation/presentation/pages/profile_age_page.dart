import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/user_profile_model.dart';
import 'profile_gender_page.dart';

/// Page de saisie de la date de naissance lors de la création du profil
class ProfileAgePage extends StatefulWidget {
  final UserProfileModel userProfile;

  const ProfileAgePage({
    super.key,
    required this.userProfile,
  });

  @override
  State<ProfileAgePage> createState() => _ProfileAgePageState();
}

class _ProfileAgePageState extends State<ProfileAgePage> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre date de naissance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation basique du format (JJ/MM/AAAA)
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(_dateController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format invalide. Utilisez JJ/MM/AAAA'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mise à jour du modèle
    final updatedProfile = widget.userProfile.copyWith(
      age: _dateController.text.trim(),
    );

    // Navigation vers la page du genre
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileGenderPage(userProfile: updatedProfile),
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
              // Label "AGE" en haut à gauche
              const Text(
                'AGE',
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
                      'Pour adapter les recommandations à\nton profil',
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

              const SizedBox(height: 80),

              // Label "Date de naissance"
              const Text(
                'Date de naissance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Champ de texte
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE0E0E0),
                  hintText: 'JJ/MM/ANNEE',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),

              const SizedBox(height: 150),

              // Boutons de navigation
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
