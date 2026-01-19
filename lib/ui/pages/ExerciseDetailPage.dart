import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/exercice_video_player.dart';

class ExerciseDetailPage extends StatefulWidget {
  final ExerciseData exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      appBar: _isFullscreen
          ? null
          : AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: _isFullscreen
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: _isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  height: _isFullscreen
                      ? MediaQuery.of(context).size.height
                      : 220,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                    _isFullscreen ? BorderRadius.zero : BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.exercise.videoAsset != null
                            ? ExerciseVideoPlayer(
                          assetPath: widget.exercise.videoAsset!,
                        )
                            : const Center(
                          child: Text(
                            "Vidéo bientôt disponible",
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),


                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFullscreen = !_isFullscreen;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFullscreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!_isFullscreen) ...[
                  const SizedBox(height: 24),


                  if (widget.exercise.description != null) ...[
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
                          color: Color(0xFFD9BE77),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        widget.exercise.description!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],


                  if (widget.exercise.etapes != null) ...[
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Color(0xFFD9BE77),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        widget.exercise.etapes!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}