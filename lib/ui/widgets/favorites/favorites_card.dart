import 'package:flutter/material.dart';

class FavoritesCard extends StatelessWidget {
  const FavoritesCard({super.key});

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
            "Exercices favoris",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              _CircleExercise(icon: Icons.fitness_center),
              SizedBox(width: 16),
              _CircleExercise(icon: Icons.sports_gymnastics),
              SizedBox(width: 16),
              _CircleExercise(icon: Icons.accessibility_new),
              SizedBox(width: 16),
              _CircleExercise(icon: Icons.sports_handball),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleExercise extends StatelessWidget {
  final IconData icon;
  const _CircleExercise({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 34),
    );
  }
}
