import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/prefs/app_prefs.dart';
import '../../data/db/app_db.dart';
import '../../services/program_generator_service.dart';
import '../../services/session_tracking_service.dart';
import '../../data/db/daos/user_training_day_dao.dart';
import '../widgets/training_days_dialog.dart';
import '../theme/app_theme.dart';
import 'active_session_page.dart';
import '../utils/responsive.dart';

class WorkoutProgramPage extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;

  const WorkoutProgramPage({super.key, required this.db, required this.prefs});

  @override
  State<WorkoutProgramPage> createState() => _WorkoutProgramPageState();
}

class _WorkoutProgramPageState extends State<WorkoutProgramPage> {
  late final ProgramGeneratorService _programService;
  late final SessionTrackingService _sessionService;
  late final UserTrainingDayDao _trainingDayDao;
  WorkoutProgramData? _currentProgram;
  List<ProgramDaySession> _programDays = [];
  Map<int, SessionData> _completedSessions = {};
  int _selectedDayIndex = 0;
  bool _loading = true;
  String? _error;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _programService = ProgramGeneratorService(widget.db);
    _sessionService = SessionTrackingService(widget.db);
    _trainingDayDao = UserTrainingDayDao(widget.db);
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = widget.prefs.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier s'il existe un programme actif
      final program = await _programService.getActiveUserProgram(userId);

      // Vérifier si l'utilisateur a des jours d'entraînement définis
      final trainingDays = await _trainingDayDao.getDayNumbersForUser(userId);

      // Si un programme existe mais qu'aucun jour d'entraînement n'est défini,
      // c'est probablement un programme généré automatiquement par l'ancienne logique.
      // On le supprime pour forcer l'état vide et la nouvelle procédure.
      if (program != null && trainingDays.isEmpty) {
        debugPrint(
          '[WORKOUT_PAGE] Programme détecté sans jours définis -> Suppression pour forcer l\'état vide',
        );

        // Désactiver/Supprimer le programme
        await (widget.db.delete(widget.db.userProgram)
          ..where((tbl) => tbl.userId.equals(userId))).go();

        if (mounted) {
          setState(() {
            _currentProgram = null;
            _programDays = [];
            _loading = false;
          });
        }
        return;
      }

      if (program == null) {
        // Ne rien faire, l'interface affichera l'état vide
        if (mounted) {
          setState(() {
            _currentProgram = null;
            _programDays = [];
            _loading = false;
          });
        }
      } else {
        // Charger le programme existant
        final days = await _programService.getProgramDays(program.id);

        // Charger les sessions complétées pour chaque jour
        final dayIds = days.map((d) => d.programDayId).toList();
        final completedSessions = await _sessionService
            .getCompletedSessionsForDays(dayIds);

        if (mounted) {
          setState(() {
            _currentProgram = program;
            _programDays = days;
            _completedSessions = completedSessions;
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[WORKOUT_PROGRAM] Erreur: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _generateNewProgram() async {
    setState(() => _generating = true);

    try {
      final userId = widget.prefs.currentUserId;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer le programme
      // Le nombre de jours est récupéré automatiquement depuis UserTrainingDay
      final programId = await _programService.generateUserProgram(
        userId: userId,
      );

      // Recharger le programme
      final program =
          await (widget.db.select(widget.db.workoutProgram)
            ..where((tbl) => tbl.id.equals(programId))).getSingle();

      final days = await _programService.getProgramDays(programId);

      if (mounted) {
        setState(() {
          _currentProgram = program;
          _programDays = days;
          _generating = false;
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Programme généré avec succès !'),
            backgroundColor: AppTheme.gold,
          ),
        );
      }
    } catch (e) {
      debugPrint('[WORKOUT_PROGRAM] Erreur génération: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _generating = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _regenerateProgram() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Régénérer le programme',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Veux-tu créer un nouveau programme ? L\'ancien sera archivé.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _generating = true);

      try {
        final userId = widget.prefs.currentUserId;
        if (userId == null) return;

        // Le nombre de jours est récupéré automatiquement depuis UserTrainingDay
        await _programService.regenerateUserProgram(userId: userId);

        await _loadProgram();
      } catch (e) {
        debugPrint('[WORKOUT_PROGRAM] Erreur régénération: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      } finally {
        if (mounted) setState(() => _generating = false);
      }
    }
  }

  Future<void> _startSession(ProgramDaySession day) async {
    final userId = widget.prefs.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utilisateur non connecté')));
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ActiveSessionPage(
              db: widget.db,
              userId: userId,
              programDayId: day.programDayId,
              dayName: day.dayName,
            ),
      ),
    );

    // Si la session est terminée, recharger le programme
    if (result == true && mounted) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Séance enregistrée et programme mis à jour !'),
          backgroundColor: AppTheme.gold,
        ),
      );

      debugPrint(
        '[WORKOUT_PROGRAM] Retour de session, rechargement du programme...',
      );

      // Recharger pour mettre à jour l'état de complétion et les nouveaux exercices
      await _loadProgram();

      // Debug: Afficher les suggestions du prochain jour pour vérification
      if (_programDays.length > 1) {
        final nextDay = _programDays.firstWhere(
          (d) => !_completedSessions.containsKey(d.programDayId),
          orElse: () => _programDays.last,
        );
        if (nextDay.exercises.isNotEmpty) {
          final firstEx = nextDay.exercises.first;
          debugPrint(
            '[WORKOUT_PROGRAM] Vérification jour ${nextDay.dayOrder}: ${firstEx.exerciseName} -> ${firstEx.setsSuggestion} (was ${firstEx.previousSetsSuggestion}) / ${firstEx.repsSuggestion}',
          );
        }
      }
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return "aujourd'hui";
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'hier';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(responsive),
            if (_programDays.isNotEmpty) _buildDaySelector(responsive),
            Expanded(
              child:
                  _loading || _generating
                      ? _buildLoading()
                      : _error != null
                      ? _buildError()
                      : _programDays.isEmpty
                      ? _buildEmpty(responsive)
                      : _buildDayContent(responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.rw(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mon Programme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.rsp(28),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_currentProgram != null) ...[
                      SizedBox(height: responsive.rh(8)),
                      Text(
                        _currentProgram!.name,
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: responsive.rsp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_currentProgram!.description != null) ...[
                        SizedBox(height: responsive.rh(4)),
                        Text(
                          _currentProgram!.description!,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: responsive.rsp(14),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: _generating ? null : _regenerateProgram,
                icon: const Icon(Icons.refresh),
                color: AppTheme.gold,
                iconSize: responsive.rsp(28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatScheduledDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return "Aujourd'hui";
    } else if (sessionDate == tomorrow) {
      return 'Demain';
    } else {
      final formatter = DateFormat('EEE dd MMM', 'fr_FR');
      return formatter.format(date);
    }
  }

  Widget _buildDaySelector(Responsive responsive) {
    return Container(
      height: responsive.rh(90),
      margin: EdgeInsets.symmetric(horizontal: responsive.rw(24)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _programDays.length,
        itemBuilder: (context, index) {
          final day = _programDays[index];
          final isSelected = _selectedDayIndex == index;
          final isCompleted = _completedSessions.containsKey(day.programDayId);
          return Padding(
            padding: EdgeInsets.only(right: responsive.rw(12)),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.rw(20),
                  vertical: responsive.rh(12),
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.gold
                          : (isCompleted
                              ? Colors.green.shade900
                              : Colors.black),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppTheme.gold
                            : (isCompleted
                                ? Colors.green
                                : Colors.grey.shade800),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Jour ${day.dayOrder}',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: responsive.rsp(14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isCompleted) ...[
                          SizedBox(width: responsive.rw(6)),
                          Icon(
                            Icons.check_circle,
                            color: isSelected ? Colors.black : Colors.green,
                            size: responsive.rsp(16),
                          ),
                        ],
                      ],
                    ),
                    if (day.scheduledDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatScheduledDate(day.scheduledDate!),
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.white60,
                          fontSize: responsive.rsp(11),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayContent(Responsive responsive) {
    if (_programDays.isEmpty) return const SizedBox();

    final currentDay = _programDays[_selectedDayIndex];
    final isCompleted = _completedSessions.containsKey(currentDay.programDayId);
    final completedSession = _completedSessions[currentDay.programDayId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.rw(24),
            responsive.rh(16),
            responsive.rw(24),
            responsive.rh(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDay.dayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.rsp(20),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (currentDay.scheduledDate != null && !isCompleted) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.gold,
                            size: 14,
                          ),
                          SizedBox(width: responsive.rw(6)),
                          Text(
                            'Prévue le ${_formatScheduledDate(currentDay.scheduledDate!)}',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontSize: responsive.rsp(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isCompleted && completedSession != null) ...[
                      SizedBox(height: responsive.rh(4)),
                      Text(
                        'Terminée le ${_formatDate(completedSession.dateTs)} (${completedSession.durationMin ?? 0} min)',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: responsive.rsp(12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: isCompleted ? null : () => _startSession(currentDay),
                icon: Icon(isCompleted ? Icons.check_circle : Icons.play_arrow),
                label: Text(isCompleted ? 'Terminée' : 'Commencer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : AppTheme.gold,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.rw(24),
            0,
            responsive.rw(24),
            responsive.rh(16),
          ),
          child: Text(
            '${currentDay.exercises.length} exercices',
            style: TextStyle(
              color: Colors.white60,
              fontSize: responsive.rsp(14),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: responsive.rw(24)),
            itemCount: currentDay.exercises.length,
            itemBuilder: (context, index) {
              final exercise = currentDay.exercises[index];
              return _buildExerciseCard(exercise, responsive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    ProgramExerciseDetail exercise,
    Responsive responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.rh(16)),
      padding: EdgeInsets.all(responsive.rw(16)),
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
                width: responsive.rw(40),
                height: responsive.rw(40),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${exercise.position}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: responsive.rsp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.rw(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.rsp(18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: responsive.rh(4)),
                    Row(
                      children: [
                        _buildBadge(
                          label: exercise.exerciseType.toUpperCase(),
                          color:
                              exercise.exerciseType == 'poly'
                                  ? Colors.blue
                                  : Colors.purple,
                          responsive: responsive,
                        ),
                        SizedBox(width: responsive.rw(8)),
                        _buildBadge(
                          label: 'Difficulté ${exercise.difficulty}/5',
                          color: _getDifficultyColor(exercise.difficulty),
                          responsive: responsive,
                        ),
                        if (exercise.previousSetsSuggestion != null ||
                            exercise.previousRepsSuggestion != null ||
                            exercise.previousRestSuggestion != null) ...[
                          SizedBox(width: responsive.rw(8)),
                          _buildBadge(
                            label: 'ADAPTÉ',
                            color: AppTheme.gold,
                            responsive: responsive,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.rh(16)),
          const Divider(color: Colors.grey, height: 1),
          SizedBox(height: responsive.rh(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(
                icon: Icons.repeat,
                label: 'Séries',
                value: exercise.setsSuggestion ?? '-',
                previousValue: exercise.previousSetsSuggestion,
                responsive: responsive,
              ),
              _buildInfoColumn(
                icon: Icons.fitness_center,
                label: 'Reps',
                value: exercise.repsSuggestion ?? '-',
                previousValue: exercise.previousRepsSuggestion,
                responsive: responsive,
              ),
              _buildInfoColumn(
                icon: Icons.timer,
                label: 'Repos',
                value:
                    exercise.restSuggestionSec != null
                        ? '${exercise.restSuggestionSec}s'
                        : '-',
                previousValue:
                    exercise.previousRestSuggestion != null
                        ? '${exercise.previousRestSuggestion}s'
                        : null,
                responsive: responsive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    String? previousValue,
    required Responsive responsive,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.gold, size: responsive.rsp(24)),
        SizedBox(height: responsive.rh(4)),
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: responsive.rsp(12)),
        ),
        SizedBox(height: responsive.rh(2)),
        if (previousValue != null && previousValue != value) ...[
          Text(
            previousValue,
            style: TextStyle(
              color: Colors.white38,
              fontSize: responsive.rsp(12),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(height: responsive.rh(2)),
        ],
        Text(
          value,
          style: TextStyle(
            color: previousValue != null ? AppTheme.gold : Colors.white,
            fontSize: responsive.rsp(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required Responsive responsive,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.rw(8),
        vertical: responsive.rh(4),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: responsive.rsp(11),
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

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.gold),
          const SizedBox(height: 16),
          Text(
            _generating ? 'Génération du programme...' : 'Chargement...',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
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
            const Text(
              'Erreur',
              style: TextStyle(
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
              onPressed: _loadProgram,
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

  Widget _buildEmpty(Responsive responsive) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.rw(20)),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppTheme.gold,
                size: responsive.rsp(48),
              ),
            ),
            SizedBox(height: responsive.rh(24)),
            Text(
              'Aucun programme pour l\'instant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.rsp(22),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.rh(12)),
            Text(
              'Cliquez ci-dessous pour générer votre premier programme personnalisé et commencer votre transformation !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsive.rsp(16),
                height: 1.5,
              ),
            ),
            SizedBox(height: responsive.rh(32)),
            SizedBox(
              width: double.infinity,
              height: responsive.rh(56),
              child: ElevatedButton(
                onPressed: _handleGenerateClick,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Générer mon premier programme',
                  style: TextStyle(
                    fontSize: responsive.rsp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGenerateClick() async {
    final userId = widget.prefs.currentUserId;
    if (userId == null) return;

    // Vérifier si l'utilisateur a des jours d'entraînement
    final days = await _trainingDayDao.getDayNumbersForUser(userId);

    if (days.isEmpty) {
      if (!mounted) return;

      // Afficher le dialog pour ajouter des jours
      final result = await showDialog<List<int>>(
        context: context,
        builder: (ctx) => const TrainingDaysDialog(selectedDays: []),
      );

      if (result != null && result.isNotEmpty) {
        await _trainingDayDao.replace(userId, result);
        // Une fois les jours enregistrés, générer le programme
        await _generateNewProgram();
      }
    } else {
      // Si les jours existent déjà, générer directement
      await _generateNewProgram();
    }
  }
}
