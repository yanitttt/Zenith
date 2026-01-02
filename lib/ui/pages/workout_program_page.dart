import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/prefs/app_prefs.dart';
import '../../services/program_generator_service.dart';
import '../../data/db/app_db.dart';
import '../viewmodels/workout_program_viewmodel.dart';
import '../widgets/training_days_dialog.dart';
import '../../core/theme/app_theme.dart';
import 'active_session_page.dart';
import '../utils/responsive.dart';

class WorkoutProgramPage extends StatelessWidget {
  final AppDb db;
  final AppPrefs prefs;

  const WorkoutProgramPage({super.key, required this.db, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => WorkoutProgramViewModel(db: db, prefs: prefs)..loadProgram(),
      child: const _WorkoutProgramContent(),
    );
  }
}

class _WorkoutProgramContent extends StatelessWidget {
  const _WorkoutProgramContent();

  Future<void> _regenerateProgram(
    BuildContext context,
    WorkoutProgramViewModel vm,
  ) async {
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
      if (context.mounted) {
        try {
          await vm.regenerateProgram();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
          }
        }
      }
    }
  }

  Future<void> _startSession(
    BuildContext context,
    ProgramDaySession day,
    WorkoutProgramViewModel vm,
  ) async {
    final userId = vm.currentUserId;

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
              db: vm.db,
              userId: userId,
              programDayId: day.programDayId,
              dayName: day.dayName,
            ),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Séance enregistrée et programme mis à jour !'),
          backgroundColor: AppTheme.gold,
        ),
      );
      await vm.updateAfterSession();
    }
  }

  Future<void> _handleGenerateClick(
    BuildContext context,
    WorkoutProgramViewModel vm,
  ) async {
    // 1. Récupérer ou définir les jours d'entraînement
    List<int> selectedDays = await vm.getUserTrainingDays();

    if (selectedDays.isEmpty) {
      if (!context.mounted) return;
      final result = await showDialog<List<int>>(
        context: context,
        builder: (ctx) => const TrainingDaysDialog(selectedDays: []),
      );

      if (result != null && result.isNotEmpty) {
        selectedDays = result;
        await vm.saveTrainingDays(result);
      } else {
        return; // Annulation par l'utilisateur
      }
    }

    // 2. Vérifier si aujourd'hui correspond à un jour d'entraînement
    bool startToday = false;
    final int todayIndex = DateTime.now().weekday;

    if (context.mounted && selectedDays.contains(todayIndex)) {
      final shouldStartToday = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                "C'est aujourd'hui !",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Vous avez sélectionné le jour actuel pour vos entraînements.\nVoulez-vous commencer votre programme dès aujourd'hui ?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    "Non, semaine prochaine",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Oui, commencer aujourd'hui"),
                ),
              ],
            ),
      );
      startToday = shouldStartToday ?? false;
    }

    // 3. Générer le programme
    if (context.mounted) {
      try {
        await vm.generateNewProgram(startToday: startToday);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Programme généré avec succès !'),
              backgroundColor: AppTheme.gold,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Consumer<WorkoutProgramViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                _buildHeader(context, responsive, vm),
                if (vm.programDays.isNotEmpty)
                  _buildDaySelector(context, responsive, vm),
                Expanded(
                  child:
                      vm.isLoading || vm.isGenerating
                          ? _buildLoading(vm)
                          : vm.error != null
                          ? _buildError(context, vm)
                          : vm.programDays.isEmpty
                          ? _buildEmpty(context, responsive, vm)
                          : _buildDayContent(context, responsive, vm),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Responsive responsive,
    WorkoutProgramViewModel vm,
  ) {
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
                    if (vm.currentProgram != null) ...[
                      SizedBox(height: responsive.rh(8)),
                      Text(
                        vm.currentProgram!.name,
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: responsive.rsp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (vm.currentProgram!.description != null) ...[
                        SizedBox(height: responsive.rh(4)),
                        Text(
                          vm.currentProgram!.description!,
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
                onPressed:
                    vm.isGenerating
                        ? null
                        : () => _regenerateProgram(context, vm),
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

  Widget _buildLoading(WorkoutProgramViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.gold),
          const SizedBox(height: 16),
          Text(
            vm.isGenerating ? 'Génération du programme...' : 'Chargement...',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WorkoutProgramViewModel vm) {
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
              vm.error ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: vm.loadProgram,
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

  Widget _buildEmpty(
    BuildContext context,
    Responsive responsive,
    WorkoutProgramViewModel vm,
  ) {
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
                onPressed: () => _handleGenerateClick(context, vm),
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

  Widget _buildDaySelector(
    BuildContext context,
    Responsive responsive,
    WorkoutProgramViewModel vm,
  ) {
    return Container(
      height: responsive.rh(90),
      margin: EdgeInsets.symmetric(horizontal: responsive.rw(24)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vm.programDays.length,
        itemBuilder: (context, index) {
          final day = vm.programDays[index];
          final isSelected = vm.selectedDayIndex == index;
          final isCompleted = vm.completedSessions.containsKey(
            day.programDayId,
          );
          return Padding(
            padding: EdgeInsets.only(right: responsive.rw(12)),
            child: GestureDetector(
              onTap: () => vm.selectDay(index),
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

  Widget _buildDayContent(
    BuildContext context,
    Responsive responsive,
    WorkoutProgramViewModel vm,
  ) {
    if (vm.programDays.isEmpty) return const SizedBox();

    final currentDay = vm.programDays[vm.selectedDayIndex];
    final isCompleted = vm.completedSessions.containsKey(
      currentDay.programDayId,
    );
    final completedSession = vm.completedSessions[currentDay.programDayId];

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
                onPressed:
                    isCompleted
                        ? null
                        : () => _startSession(context, currentDay, vm),
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
              return _buildExerciseCard(
                context,
                exercise,
                responsive,
                vm,
                currentDay,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ProgramExerciseDetail exercise,
    Responsive responsive,
    WorkoutProgramViewModel vm,
    ProgramDaySession day,
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
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: AppTheme.gold),
                onPressed:
                    () => _showSwapReasonSheet(context, vm, exercise, day),
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
                responsive: responsive,
              ),
              _buildInfoColumn(
                icon: Icons.fitness_center,
                label: 'Reps',
                value: exercise.repsSuggestion ?? '-',
                responsive: responsive,
              ),
              _buildInfoColumn(
                icon: Icons.timer,
                label: 'Repos',
                value:
                    exercise.restSuggestionSec != null
                        ? '${exercise.restSuggestionSec}s'
                        : '-',
                responsive: responsive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSwapReasonSheet(
    BuildContext context,
    WorkoutProgramViewModel vm,
    ProgramExerciseDetail exercise,
    ProgramDaySession day,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder:
          (_) => ChangeNotifierProvider.value(
            value: vm,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pourquoi remplacer cet exercice ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.no_stroller,
                      color: AppTheme.gold,
                    ),
                    title: const Text(
                      'Aucun équipement disponible',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAlternativesSheet(
                        context,
                        vm,
                        exercise,
                        day,
                        SwapReason.noEquipment,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.personal_injury_outlined,
                      color: AppTheme.gold,
                    ),
                    title: const Text(
                      'Douleur ou inconfort',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAlternativesSheet(
                        context,
                        vm,
                        exercise,
                        day,
                        SwapReason.pain,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }

  void _showAlternativesSheet(
    BuildContext context,
    WorkoutProgramViewModel vm,
    ProgramExerciseDetail exercise,
    ProgramDaySession day,
    SwapReason reason,
  ) {
    vm.getSmartAlternatives(
      originalExerciseId: exercise.exerciseId,
      reason: reason,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder:
          (_) => ChangeNotifierProvider.value(
            value: vm,
            child: Consumer<WorkoutProgramViewModel>(
              builder: (modalContext, model, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choisissez une alternative',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAlternativesContent(modalContext, model, day),
                    ],
                  ),
                );
              },
            ),
          ),
    ).whenComplete(() => vm.resetSwapState());
  }

  Widget _buildAlternativesContent(
    BuildContext context,
    WorkoutProgramViewModel model,
    ProgramDaySession day,
  ) {
    switch (model.swapState) {
      case SwapState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.gold),
        );
      case SwapState.error:
        return Center(
          child: Text(
            model.swapError ?? 'Erreur',
            style: const TextStyle(color: Colors.red),
          ),
        );
      case SwapState.success:
        if (model.swapAlternatives.isEmpty) {
          return const Center(
            child: Text(
              'Aucune alternative trouvée.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return Column(
          children:
              model.swapAlternatives.map((alt) {
                return ListTile(
                  title: Text(
                    alt.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Poids du corps',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    model.applySwap(day.dayOrder - 1, alt);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exercice remplacé par ${alt.name}'),
                      ),
                    );
                  },
                );
              }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
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
}
