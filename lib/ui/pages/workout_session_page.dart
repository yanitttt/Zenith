import 'package:flutter/material.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../../services/recommendation_service.dart';
import '../theme/app_theme.dart';

class WorkoutSessionPage extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;

  const WorkoutSessionPage({
    super.key,
    required this.db,
    required this.prefs,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late final RecommendationService _recommendationService;
  List<RecommendedExercise> _workout = [];
  List<ObjectiveData> _userObjectives = [];
  ObjectiveData? _selectedObjective;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService(widget.db);
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = widget.prefs.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }


      final objectives =
          await _recommendationService.getUserObjectives(userId);
      if (objectives.isEmpty) {
        throw Exception('Aucun objectif défini');
      }


      final workout = await _recommendationService.generateWorkoutSession(
        userId: userId,
        objectiveId: _selectedObjective?.id ?? objectives.first.id,
        totalExercises: 6,
      );

      if (mounted) {
        setState(() {
          _userObjectives = objectives;
          _selectedObjective ??= objectives.first;
          _workout = workout;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[WORKOUT_SESSION] Erreur: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _changeObjective(ObjectiveData objective) async {
    setState(() => _selectedObjective = objective);
    await _loadWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_userObjectives.length > 1) _buildObjectiveSelector(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    )
                  : _error != null
                      ? _buildError()
                      : _workout.isEmpty
                          ? _buildEmptyState()
                          : _buildWorkoutList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ta séance du jour',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedObjective != null)
            Row(
              children: [
                const Icon(Icons.flag, color: AppTheme.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Objectif: ${_selectedObjective!.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildObjectiveSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _userObjectives.length,
        itemBuilder: (context, index) {
          final objective = _userObjectives[index];
          final isSelected = _selectedObjective?.id == objective.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(objective.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _changeObjective(objective);
              },
              backgroundColor: Colors.grey.shade900,
              selectedColor: AppTheme.gold,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _workout.length,
      itemBuilder: (context, index) {
        final exercise = _workout[index];
        return _buildExerciseCard(exercise, index + 1);
      },
    );
  }

  Widget _buildExerciseCard(RecommendedExercise exercise, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(
                          label: exercise.type.toUpperCase(),
                          color: exercise.type == 'poly'
                              ? Colors.blue
                              : Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          label: 'Difficulté ${exercise.difficulty}/5',
                          color: _getDifficultyColor(exercise.difficulty),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (exercise.objectiveAffinity > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.gold, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Affinité: ${(exercise.objectiveAffinity * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (exercise.cardio > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Cardio: ${(exercise.cardio * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 2) return Colors.green;
    if (difficulty <= 3) return Colors.orange;
    return Colors.red;
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkout,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center,
                color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Aucun exercice disponible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vérifie que ton équipement et tes objectifs sont bien configurés',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWorkout,
              icon: const Icon(Icons.refresh),
              label: const Text('Recharger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
