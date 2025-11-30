import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/db/app_db.dart';
import '../../services/session_tracking_service.dart';
import '../theme/app_theme.dart';
import '../../services/program_generator_service.dart';

class ActiveSessionPage extends StatefulWidget {
  final AppDb db;
  final int userId;
  final int programDayId;
  final String dayName;

  const ActiveSessionPage({
    super.key,
    required this.db,
    required this.userId,
    required this.programDayId,
    required this.dayName,
  });

  @override
  State<ActiveSessionPage> createState() => _ActiveSessionPageState();
}

class _ActiveSessionPageState extends State<ActiveSessionPage> {
  late final SessionTrackingService _sessionService;
  late final ProgramGeneratorService _programGenerator;
  late DateTime _startTime;
  int? _sessionId;
  List<ActiveSessionExercise> _exercises = [];
  int _currentExerciseIndex = 0;
  bool _loading = true;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionTrackingService(widget.db);
    _programGenerator = ProgramGeneratorService(widget.db);
    _startTime = DateTime.now();
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      // Créer la session
      final sessionId = await _sessionService.startSession(
        userId: widget.userId,
        programDayId: widget.programDayId,
      );

      // Charger les exercices
      final exercises = await _sessionService.getSessionExercises(
        widget.programDayId,
      );

      if (mounted) {
        setState(() {
          _sessionId = sessionId;
          _exercises = exercises;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[ACTIVE_SESSION] Erreur init: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showExerciseDialog(ActiveSessionExercise exercise) async {
    final result = await showDialog<ActiveSessionExercise>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _ExercisePerformanceDialog(
            exercise: exercise,
            sessionService: _sessionService,
            userId: widget.userId,
          ),
    );

    if (result != null) {
      setState(() {
        _exercises[_currentExerciseIndex] = result;
      });

      // Sauvegarder automatiquement
      await _sessionService.saveExercisePerformance(
        sessionId: _sessionId!,
        exercise: result,
      );

      // Passer au suivant si pas le dernier
      if (_currentExerciseIndex < _exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
        });
      }
    }
  }

  Future<void> _completeSession() async {
    // Vérifier que tous les exercices sont complétés
    final allCompleted = _exercises.every((e) => e.isCompleted);

    if (!allCompleted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Séance incomplète',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Tu n\'as pas complété tous les exercices. Veux-tu quand même terminer la séance ?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(color: AppTheme.gold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Terminer',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
      );

      if (confirmed != true) return;
    }

    setState(() => _completing = true);

    try {
      await _sessionService.completeSession(
        sessionId: _sessionId!,
        startTime: _startTime,
      );

      // Régénérer les jours futurs du programme
      if (mounted) {
        setState(() {
          // Mettre à jour le message du bouton si nécessaire,
          // mais _completing est déjà true donc le bouton affiche "Finalisation..."
        });
      }

      // Récupérer l'ID du programme
      final programDay =
          await (widget.db.select(widget.db.programDay)
            ..where((tbl) => tbl.id.equals(widget.programDayId))).getSingle();

      // Lancer la régénération
      await _programGenerator.regenerateFutureDays(
        userId: widget.userId,
        programId: programDay.programId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bravo ! Séance terminée'),
            backgroundColor: AppTheme.gold,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('[ACTIVE_SESSION] Erreur completion: $e');
      if (mounted) {
        setState(() => _completing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  String _getElapsedTime() {
    final now = DateTime.now();
    final elapsed = now.difference(_startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}min' : '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text(
                  'Abandonner la séance ?',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Ta progression ne sera pas sauvegardée.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(color: AppTheme.gold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Abandonner',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
        return confirmed == true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffold,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.dayName, style: const TextStyle(fontSize: 18)),
              Text(
                _getElapsedTime(),
                style: const TextStyle(fontSize: 12, color: AppTheme.gold),
              ),
            ],
          ),
        ),
        body:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.gold),
                )
                : Column(
                  children: [
                    _buildProgress(),
                    Expanded(child: _buildExercisesList()),
                    _buildCompleteButton(),
                  ],
                ),
      ),
    );
  }

  Widget _buildProgress() {
    final completed = _exercises.where((e) => e.isCompleted).length;
    final total = _exercises.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completed/$total exercices',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              color: AppTheme.gold,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        final isCurrent = index == _currentExerciseIndex;
        return _buildExerciseCard(exercise, index, isCurrent);
      },
    );
  }

  Widget _buildExerciseCard(
    ActiveSessionExercise exercise,
    int index,
    bool isCurrent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppTheme.gold : Colors.grey.shade800,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    exercise.isCompleted ? AppTheme.gold : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child:
                    exercise.isCompleted
                        ? const Icon(Icons.check, color: Colors.black)
                        : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            title: Text(
              exercise.exerciseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildSuggestionChip(
                    icon: Icons.repeat,
                    text: exercise.setsSuggestion ?? '-',
                  ),
                  _buildSuggestionChip(
                    icon: Icons.fitness_center,
                    text: exercise.repsSuggestion ?? '-',
                  ),
                ],
              ),
            ),
            trailing:
                exercise.isCompleted
                    ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.gold,
                      size: 32,
                    )
                    : ElevatedButton(
                      onPressed: () => _showExerciseDialog(exercise),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCurrent ? AppTheme.gold : Colors.grey.shade700,
                        foregroundColor:
                            isCurrent ? Colors.black : Colors.white,
                      ),
                      child: const Text('Faire'),
                    ),
          ),
          if (exercise.isCompleted) _buildCompletedInfo(exercise),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedInfo(ActiveSessionExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Séries', '${exercise.actualSets ?? "-"}'),
          _buildStatColumn('Reps', '${exercise.actualReps ?? "-"}'),
          _buildStatColumn(
            'Charge',
            '${exercise.actualLoad?.toStringAsFixed(1) ?? "-"} kg',
          ),
          _buildStatColumn(
            'RPE',
            '${exercise.actualRpe?.toStringAsFixed(1) ?? "-"}/10',
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _completing ? null : _completeSession,
          icon:
              _completing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                  : const Icon(Icons.check_circle),
          label: Text(_completing ? 'Finalisation...' : 'Terminer la séance'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.gold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExercisePerformanceDialog extends StatefulWidget {
  final ActiveSessionExercise exercise;
  final SessionTrackingService sessionService;
  final int userId;

  const _ExercisePerformanceDialog({
    required this.exercise,
    required this.sessionService,
    required this.userId,
  });

  @override
  State<_ExercisePerformanceDialog> createState() =>
      _ExercisePerformanceDialogState();
}

class _ExercisePerformanceDialogState
    extends State<_ExercisePerformanceDialog> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _loadController;
  double _rpe = 7.0;
  bool _loadingAnalysis = true;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.exercise.actualSets?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.exercise.actualReps?.toString() ?? '',
    );
    _loadController = TextEditingController(
      text: widget.exercise.actualLoad?.toString() ?? '',
    );
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    final analysis = await widget.sessionService.analyzePerformance(
      exerciseId: widget.exercise.exerciseId,
      userId: widget.userId,
    );
    if (mounted) {
      setState(() {
        _analysis = analysis;
        _loadingAnalysis = false;

        // Pré-remplir avec les moyennes si disponibles
        if (analysis['hasHistory'] == true) {
          if (_setsController.text.isEmpty) {
            _setsController.text =
                (analysis['averageSets'] as double).round().toString();
          }
          if (_repsController.text.isEmpty) {
            _repsController.text =
                (analysis['averageReps'] as double).round().toString();
          }
          if (_loadController.text.isEmpty) {
            _loadController.text = (analysis['averageLoad'] as double)
                .toStringAsFixed(1);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  void _save() {
    final sets = int.tryParse(_setsController.text);
    final reps = int.tryParse(_repsController.text);
    final load = double.tryParse(_loadController.text);

    if (sets == null || reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séries et reps sont obligatoires')),
      );
      return;
    }

    final updated = widget.exercise.copyWith(
      actualSets: sets,
      actualReps: reps,
      actualLoad: load,
      actualRpe: _rpe,
      isCompleted: true,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exercise.exerciseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.exercise.setsSuggestion != null ||
                widget.exercise.repsSuggestion != null)
              Text(
                'Suggéré: ${widget.exercise.setsSuggestion ?? "-"} × ${widget.exercise.repsSuggestion ?? "-"}',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            if (!_loadingAnalysis &&
                _analysis != null &&
                _analysis!['hasHistory'] == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.insights,
                          color: AppTheme.gold,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Historique',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dernières fois: ${_analysis!['averageSets']?.toStringAsFixed(0)} séries × ${_analysis!['averageReps']?.toStringAsFixed(0)} reps @ ${_analysis!['averageLoad']?.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildTextField(
              controller: _setsController,
              label: 'Nombre de séries',
              icon: Icons.repeat,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _repsController,
              label: 'Nombre de répétitions',
              icon: Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loadController,
              label: 'Charge (kg)',
              icon: Icons.monitor_weight,
              isDecimal: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'RPE (Ressenti d\'effort)',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rpe,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    activeColor: AppTheme.gold,
                    label: _rpe.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _rpe = value),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _rpe.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Valider'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        if (isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppTheme.gold),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
