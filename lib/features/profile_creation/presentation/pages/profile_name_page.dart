import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';
import 'profile_age_page.dart';

/// Page de saisie du nom lors de la création du profil
class ProfileNamePage extends StatefulWidget {
  const ProfileNamePage({super.key});

  @override
  State<ProfileNamePage> createState() => _ProfileNamePageState();
}

class _ProfileNamePageState extends State<ProfileNamePage> {
  final TextEditingController _nameController = TextEditingController();
  UserProfileModel _userProfile = UserProfileModel.empty();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mise à jour du modèle
    final updatedProfile = _userProfile.copyWith(
      name: _nameController.text.trim(),
    );

    // Navigation vers la page de l'âge
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileAgePage(userProfile: updatedProfile),
      ),
    );*/
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
              // Label "NOM" en haut à gauche
              const Text(
                'NOM',
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
                      'Pour personnaliser ton expérience',
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

              // Label "Ton nom"
              const Text(
                'Ton nom',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Champ de texte
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE0E0E0),
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

              const Spacer(),

              // Bouton "Suivant" en bas à droite
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
