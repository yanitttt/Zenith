import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesCard extends StatelessWidget {
  final List<ExerciseData> exercises;
  const FavoritesCard({super.key, required this.exercises});

  IconData _getExerciseIcon(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('squat') || name.contains('jambe')) {
      return Icons.accessibility_new;
    } else if (name.contains('développé') ||
        name.contains('presse') ||
        name.contains('bench')) {
      return Icons.fitness_center;
    } else if (name.contains('curl') ||
        name.contains('biceps') ||
        name.contains('triceps')) {
      return Icons.sports_martial_arts;
    } else if (name.contains('rowing') ||
        name.contains('tirage') ||
        name.contains('dos')) {
      return Icons.rowing;
    } else if (name.contains('épaule') || name.contains('shoulder')) {
      return Icons.sports_handball;
    } else if (name.contains('cardio') || name.contains('course')) {
      return Icons.directions_run;
    } else {
      return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Exercices recommandés",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          exercises.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Aucun exercice disponible',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      exercises.map((exercise) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _CircleExercise(
                            icon: _getExerciseIcon(exercise.name),
                            label: exercise.name,
                          ),
                        );
                      }).toList(),
                ),
              ),
        ],
      ),
    );
  }
}

class _CircleExercise extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CircleExercise({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black, size: 34),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
