import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../theme/app_theme.dart';

class ExerciseSwipeCard extends StatelessWidget {
  final ExerciseData exercise;
  final ImageProvider imageProvider;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onUndo;

  const ExerciseSwipeCard({
    super.key,
    required this.exercise,
    required this.imageProvider,
    required this.onLike,
    required this.onDislike,
    required this.onUndo,
  });

  String get _longDescription {
    // Placeholder descriptif long (adapter plus tard depuis la BDD si tu as un champ)
    return "Description : Cet exercice fait blabla blabla blabla blabla blabla blabla "
        "blabla blabla blabla blabla blabla blabla blabla blabla blabla blabla.";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: const Color(0xFF111111), width: 2),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            children: [
              // L'image avec coins arrondis et overlay texte
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Image pleine largeur
                      Positioned.fill(
                        child: Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Bouton Undo (coin haut-gauche)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: _RoundIcon(
                          icon: Icons.refresh, // visuel flèche retour
                          onTap: onUndo,
                        ),
                      ),

                      // Dégradé pour lisibilité du texte en bas
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 240,
                        child: IgnorePointer(
                          ignoring: true,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Titre + description en bas
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _longDescription,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Boutons Like / Dislike (superposés bas de l'image)
                      Positioned(
                        left: 36,
                        right: 36,
                        bottom: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ActionButton(
                              icon: Icons.close,
                              iconColor: const Color(0xFFB54135), // rouge doux
                              onTap: onDislike,
                            ),
                            _ActionButton(
                              icon: Icons.favorite_border,
                              iconColor: const Color(0xFF4E7A57), // vert doux
                              onTap: onLike,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Marge bas (espace pour la bottom bar globale)
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/* ---------- Petits widgets réutilisables ---------- */

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 3),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 44,
        child: Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 6),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Icon(icon, size: 46, color: iconColor),
        ),
      ),
    );
  }
}
