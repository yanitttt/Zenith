import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/exercice_video_player.dart';

class ExerciseDetailPage extends StatelessWidget {
  final ExerciseData exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎥 VIDÉO
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                color: Colors.black,
              ),
              child: exercise.videoAsset != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ExerciseVideoPlayer(
                        assetPath: exercise.videoAsset!,
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Vidéo bientôt disponible",
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // 📝 DESCRIPTION
            if (exercise.description != null) ...[
              const Text(
                "Description",
                style: TextStyle(
                  color: Color(0xFFD9BE77),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD9BE77),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  exercise.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],

            // 📋 ÉTAPES
            if (exercise.etapes != null) ...[
              const Text(
                "Étapes",
                style: TextStyle(
                  color: Color(0xFFD9BE77),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  exercise.etapes!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}