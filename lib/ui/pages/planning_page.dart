import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/planning_service.dart';
import 'package:recommandation_mobile/ui/widgets/planning/scale_button.dart';
import '../viewmodels/planning_viewmodel.dart';
import '../../services/performance_monitor_service.dart';
import 'dart:convert';
import '../theme/app_theme.dart';

class PlanningPage extends StatelessWidget {
  final AppDb db;
  const PlanningPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanningViewModel(db),
      child: const _PlanningPageContent(),
    );
  }
}

class _PlanningPageContent extends StatefulWidget {
  const _PlanningPageContent();

  @override
  State<_PlanningPageContent> createState() => _PlanningPageContentState();
}

class _PlanningPageContentState extends State<_PlanningPageContent> {
  final Color kBackground = const Color(0xFF020216);
  final Color kCardColor = const Color(0xFF0F112B);
  final Color kGold = const Color(0xFFE4C87F);

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);

    // Initial scroll setup logic (needs data from VM which is loading...)
    // We'll wrap the listview in a builder that knows when to attach controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollController();
    });
  }

  void _setupScrollController() {
    final now = DateTime.now();
    final dayIndex = now.weekday - 1;
    final double initialOffset = (dayIndex * 77.0);

    _scrollController = ScrollController(
      initialScrollOffset: initialOffset > 50 ? initialOffset - 50 : 0,
    );
    // Force rebuild to attach controller if needed, or just let it be used in build
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  // --- UI Helpers ---

  void _ensureScrollController(int offsetDays) {
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        0, // Reset to start when changing week? Original logic did this.
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToSelected(int dayIndex) {
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        (dayIndex * 77.0) - 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _selectDateFromCalendar(BuildContext context) async {
    final vm = context.read<PlanningViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: kGold,
              onPrimary: Colors.black,
              surface: kCardColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: kBackground,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      vm.selectDate(picked);
      _scrollToSelected(picked.weekday - 1);
    }
  }

  void _showAddSessionSheet(BuildContext context, PlanningViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Use local context
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajouter une activité",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              ScaleButton(
                onTap: () {
                  Navigator.pop(ctx);
                  _showDurationPickerDialog(context, vm, "Cardio libre");
                },
                child: ListTile(
                  leading: _buildIcon(Icons.directions_run, Colors.blueAccent),
                  title: const Text(
                    "Séance Cardio",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "Durée personnalisable",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              ScaleButton(
                onTap: () {
                  Navigator.pop(ctx);
                  _showDurationPickerDialog(context, vm, "Muscu libre");
                },
                child: ListTile(
                  leading: _buildIcon(Icons.fitness_center, kGold),
                  title: const Text(
                    "Séance Muscu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "Durée personnalisable",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDurationPickerDialog(
    BuildContext context,
    PlanningViewModel vm,
    String type, {
    int? initialDuration,
    int? sessionId,
  }) async {
    int selectedDuration = initialDuration ?? 45;
    String selectedType = type;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: kCardColor,
              title: Text(
                sessionId == null ? "Nouvelle séance" : "Modifier la séance",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypeSelector(
                        "Cardio",
                        Icons.directions_run,
                        Colors.blueAccent,
                        selectedType == "Cardio libre",
                        () =>
                            setStateDialog(() => selectedType = "Cardio libre"),
                      ),
                      _buildTypeSelector(
                        "Muscu",
                        Icons.fitness_center,
                        kGold,
                        selectedType == "Muscu libre",
                        () =>
                            setStateDialog(() => selectedType = "Muscu libre"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$selectedDuration min",
                    style: TextStyle(
                      color: kGold,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: kGold,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: kGold.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: selectedDuration.toDouble(),
                      min: 10,
                      max: 180,
                      divisions: 34,
                      label: "$selectedDuration min",
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedDuration = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (sessionId == null) {
                      await vm.addFreeSession(selectedDuration, selectedType);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Séance ajoutée : $selectedType !"),
                            backgroundColor: kGold,
                          ),
                        );
                      }
                    } else {
                      await vm.updateFreeSession(
                        sessionId,
                        selectedDuration,
                        selectedType,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Séance modifiée !"),
                            backgroundColor: kGold,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    sessionId == null ? "Ajouter" : "Enregistrer",
                    style: TextStyle(color: kGold, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTypeSelector(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.white12,
                width: 2,
              ),
            ),
            child: Icon(icon, color: isSelected ? color : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  void _showPerformanceDialog(BuildContext context) async {
    final perfService = PerformanceMonitorService();
    final report = perfService.lastReport; // Get LAST report

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

  @override
  Widget build(BuildContext context) {
    // We access VM for date display in header
    final selectedDate = context.select<PlanningViewModel, DateTime>(
      (vm) => vm.selectedDate,
    );

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight:
            0, // Hidden app bar, we use custom header below or we can add actions here?
        // Original design didn't have AppBar. We'll stick to body structure but add the perf button in the custom header.
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // HEADER ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                          'fr_FR',
                        ).format(selectedDate).toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Mon Planning",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Perf Button
                      IconButton(
                        onPressed: () => _showPerformanceDialog(context),
                        icon: const Icon(Icons.analytics_outlined),
                        color: Colors.white70,
                        tooltip: 'Performance',
                      ),
                      const SizedBox(width: 8),
                      // Calendar Button
                      ScaleButton(
                        onTap: () => _selectDateFromCalendar(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // WEEK SELECTOR
              Consumer<PlanningViewModel>(
                builder: (context, vm, child) {
                  return Row(
                    children: [
                      ScaleButton(
                        onTap: () {
                          vm.changeWeek(-1);
                          _ensureScrollController(-1);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.chevron_left, color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 70,
                          child:
                              _scrollController == null
                                  ? const SizedBox()
                                  : ListView.separated(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 7,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final date = vm.startOfWeek.add(
                                        Duration(days: index),
                                      );
                                      final isSelected =
                                          date.day == vm.selectedDate.day &&
                                          date.month == vm.selectedDate.month;
                                      final hasActivity = vm.joursAvecActivite
                                          .contains(date.weekday);
                                      return _buildDayButton(
                                        context,
                                        date,
                                        isSelected,
                                        hasActivity,
                                      );
                                    },
                                  ),
                        ),
                      ),
                      ScaleButton(
                        onTap: () {
                          vm.changeWeek(1);
                          _ensureScrollController(1);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.chevron_right, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // SESSIONS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Séances du jour",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Selector<PlanningViewModel, int>(
                    selector: (_, vm) => vm.sessionsDuJour.length,
                    builder: (context, count, _) {
                      if (count == 0) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$count prévues",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SESSIONS LIST
              Expanded(
                child: Consumer<PlanningViewModel>(
                  builder: (context, vm, child) {
                    if (vm.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: kGold),
                      );
                    }
                    if (vm.sessionsDuJour.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      itemCount: vm.sessionsDuJour.length,
                      itemBuilder: (context, index) {
                        return _buildSessionCard(
                          context,
                          vm.sessionsDuJour[index],
                          index + 1,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<PlanningViewModel>(
        builder: (context, vm, child) {
          if (vm.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Info: ${vm.error}"),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
          return ScaleButton(
            onTap: () => _showAddSessionSheet(context, vm),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: kGold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayButton(
    BuildContext context,
    DateTime date,
    bool isSelected,
    bool hasActivity,
  ) {
    return ScaleButton(
      onTap: () => context.read<PlanningViewModel>().selectDate(date),
      child: Container(
        width: 65,
        decoration: BoxDecoration(
          color: isSelected ? kGold : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected ? null : Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.E('fr_FR').format(date).substring(0, 3).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${date.day}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                if (hasActivity && !isSelected) ...[
                  const SizedBox(width: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle, size: 14, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 48, color: Colors.white12),
          SizedBox(height: 16),
          Text("Aucune séance prévue", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, PlanningItem item, int index) {
    // isActuallyDone logic: if duration > 0 OR manually marked done (if we tracked that property fully) -> we use item properties.
    // PlanningItem has duration and isDone.

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$index",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "MUSCU", // Could be dynamic based on Type
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (item.duration > 0) ...[
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${item.duration} min",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ] else ...[
                          Text(
                            "Prévue",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Option menu for delete/edit
              // Only if sessionId is present (Free Session)
              if (item.sessionId != null)
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white38),
                  color: kCardColor,
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await context.read<PlanningViewModel>().deleteSession(
                        item.sessionId!,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Séance supprimée'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (value == 'edit') {
                      _showDurationPickerDialog(
                        context,
                        context
                            .read<
                              PlanningViewModel
                            >(), // Safe here in widget tree
                        item.title,
                        initialDuration: item.duration,
                        sessionId: item.sessionId,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Modifier',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
