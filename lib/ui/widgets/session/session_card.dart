import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Modèle pour les informations d'une séance
class SessionInfo {
  final String dayName; // "Lundi"
  final int dayNumber; // 15
  final String monthName; // "Novembre"
  final int durationMinutes; // 60
  final String sessionType; // "PUSH", "PULL", "LEGS", etc.
  final List<ExerciseItem> exercises;

  const SessionInfo({
    required this.dayName,
    required this.dayNumber,
    required this.monthName,
    required this.durationMinutes,
    required this.sessionType,
    required this.exercises,
  });
}

/// Modèle pour un exercice dans la séance
class ExerciseItem {
  final String name;
  final String sets; // "4 séries"
  final String reps; // "8 répétitions"
  final String rest; // "1min de repos"
  final String load; // "60kg de charge"
  final IconData icon;

  const ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.load,
    required this.icon,
  });
}

/// Widget réutilisable pour afficher une carte de séance
class SessionCard extends StatelessWidget {
  final SessionInfo sessionInfo;
  final VoidCallback? onNextPressed;

  const SessionCard({
    super.key,
    required this.sessionInfo,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: const Color(0xFF2A2A2A), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prochaine séance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sessionInfo.dayName} ${sessionInfo.dayNumber} ${sessionInfo.monthName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              '${sessionInfo.durationMinutes} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sessionInfo.sessionType,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des exercices
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                sessionInfo.exercises.length,
                (index) => _buildExerciseRow(
                  context,
                  sessionInfo.exercises[index],
                  isLast: index == sessionInfo.exercises.length - 1,
                ),
              ),
            ),
          ),

          // Bouton Suite
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Suite',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(
    BuildContext context,
    ExerciseItem exercise,
    {required bool isLast}
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                exercise.icon,
                color: AppTheme.gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.sets} / ${exercise.reps} / ${exercise.rest} de repos/ ${exercise.load}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            thickness: 1,
            height: 0,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
