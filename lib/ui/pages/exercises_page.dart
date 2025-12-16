import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../viewmodels/exercises_viewmodel.dart';
import '../../services/performance_monitor_service.dart';
import 'dart:convert';

class ExercisesPage extends StatelessWidget {
  final AppDb db;
  const ExercisesPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExercisesViewModel(db),
      child: const _ExercisesPageContent(),
    );
  }
}

class _ExercisesPageContent extends StatefulWidget {
  const _ExercisesPageContent();

  @override
  State<_ExercisesPageContent> createState() => _ExercisesPageContentState();
}

class _ExercisesPageContentState extends State<_ExercisesPageContent> {
  void _showPerformanceDialog(BuildContext context) {
    final perfService = PerformanceMonitorService();
    final report = perfService.lastReport;

    if (report == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aucun rapport récent.')));
      return;
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(report);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Performance',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                jsonString,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: AppTheme.gold),
                ),
              ),
            ],
          ),
    );
  }

  void _showFilterSheet(BuildContext context, ExercisesViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF10141F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // Use ChangeNotifierProvider.value to pass the existing VM to the modal
        return ChangeNotifierProvider.value(
          value: vm,
          child: Consumer<ExercisesViewModel>(
            builder: (context, vm, _) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filtrer par muscle",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (vm.selectedCategories.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              vm.clearCategories();
                              // Navigator.pop(ctx); // Optional: close on clear? better to keep open
                            },
                            child: const Text(
                              "Effacer",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          vm.categories.map((category) {
                            final isSelected = vm.selectedCategories.contains(
                              category,
                            );
                            return FilterChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => vm.toggleCategory(category),
                              selectedColor: AppTheme.gold,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              checkmarkColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? AppTheme.gold
                                          : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold, // Official Dark BG
      body: SafeArea(
        child: Column(
          children: [
            // Stylish Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIBLIOTHÈQUE',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mes Exercices',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // Performance Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () => _showPerformanceDialog(context),
                      tooltip: 'Performance',
                    ),
                  ),
                ],
              ),
            ),

            // Stylish Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<ExercisesViewModel>(
                builder: (context, vm, _) {
                  return _StylishSearchField(
                    onChanged: (v) => vm.updateQuery(v.trim()),
                    onFilterTap: () => _showFilterSheet(context, vm),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Card List
            Expanded(
              child: Consumer<ExercisesViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading && vm.exercises.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold),
                    );
                  }

                  if (vm.error != null) {
                    return Center(
                      child: Text(
                        'Erreur : ${vm.error}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  if (vm.exercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 60,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun exercice trouvé',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: vm.exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final e = vm.exercises[i];
                      final muscles = vm.getMusclesFor(e.id);
                      return _StylishExerciseCard(
                        e: e,
                        muscles: muscles,
                        isFavorite: vm.isFavorite(e.id),
                        onToggleFavorite: () => vm.toggleFavorite(e.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylishSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _StylishSearchField({
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: AppTheme.gold,
        decoration: InputDecoration(
          hintText: "Rechercher...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.gold.withOpacity(0.8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            onPressed: onFilterTap,
            tooltip: 'Filtrer',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _StylishExerciseCard extends StatelessWidget {
  final ExerciseData e;
  final List<String> muscles;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _StylishExerciseCard({
    required this.e,
    required this.muscles,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isPoly = e.type.toLowerCase() == 'poly';
    // Use AppTheme surface for cards, but slightly elevated
    // A deep dark shade, very close to background but distinct enough
    final cardColor = const Color(0xFF10141F);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: AppTheme.gold.withOpacity(0.1),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.02)),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Stylish Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: AppTheme.gold,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Stronger font
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Muscle Tags
                      if (muscles.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            muscles.join(", ").toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Row(
                        children: [
                          // Type pill
                          _TagPill(
                            text: e.type.toUpperCase(),
                            color:
                                isPoly
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFF81C784),
                          ),
                          const SizedBox(width: 8),
                          // Difficulty pill
                          _TagPill(
                            text: "NIV ${e.difficulty}",
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavorite
                            ? Colors.redAccent
                            : Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TagPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
