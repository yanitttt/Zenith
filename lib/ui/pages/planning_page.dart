import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/db/app_db.dart';
import '../../services/planning_service.dart';
import '../../ui/viewmodels/planning_view_model.dart';
import '../widgets/planning/scale_button.dart';

class PlanningPage extends StatelessWidget {
  final AppDb db;

  const PlanningPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanningViewModel(db)..init(),
      child: const _PlanningView(),
    );
  }
}

class _PlanningView extends StatefulWidget {
  const _PlanningView();

  @override
  State<_PlanningView> createState() => _PlanningViewState();
}

enum PlanningViewMode { week, month }

class _PlanningViewState extends State<_PlanningView> {
  final Color kBackground = const Color(0xFF020216);
  final Color kCardColor = const Color(0xFF0F112B);
  final Color kGold = const Color(0xFFE4C87F);

  ScrollController? _scrollController;
  PlanningViewMode _viewMode = PlanningViewMode.week;

  @override
  void initState() {
    super.initState();
    // Le VM est initialisé dans le create du Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureScrollController(context.read<PlanningViewModel>().startOfWeek);
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _ensureScrollController(DateTime startOfWeek) {
    if (_scrollController != null && _scrollController!.hasClients) return;

    final now = DateTime.now();
    // On veut centrer ou positionner sur le jour actuel si on est dans la semaine courante
    // Sinon on reste au début.
    // Logique simplifiée : si la semaine affichée contient aujourd'hui, on scroll vers aujourd'hui.

    final isCurrentWeek =
        now.difference(startOfWeek).inDays >= 0 &&
        now.difference(startOfWeek).inDays < 7;

    final dayIndex = isCurrentWeek ? (now.weekday - 1) : 0;
    final double initialOffset = (dayIndex * 77.0);

    _scrollController = ScrollController(
      initialScrollOffset: initialOffset > 50 ? initialOffset - 50 : 0,
    );
  }

  void _scrollToIndex(int index) {
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        (index * 77.0) -
            50, // 77 = largeur approx item + espace, 50 = marge gauche
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlanningViewModel>();

    if (_scrollController == null) {
      _ensureScrollController(vm.startOfWeek);
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, vm),
              const SizedBox(height: 24),
              Expanded(
                child:
                    _viewMode == PlanningViewMode.week
                        ? _buildWeekView(context, vm)
                        : _buildMonthView(context, vm),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleButton(
        onTap: () => _showAddSessionSheet(context),
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
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, PlanningViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekSelector(context, vm),
        const SizedBox(height: 30),
        _buildListTitle(vm),
        const SizedBox(height: 16),
        Expanded(
          child:
              vm.isLoading
                  ? Center(child: CircularProgressIndicator(color: kGold))
                  : vm.sessionsDuJour.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    itemCount: vm.sessionsDuJour.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(
                        context,
                        vm.sessionsDuJour[index],
                        index + 1,
                        kCardColor,
                        kGold,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildMonthView(BuildContext context, PlanningViewModel vm) {
    // Jours de la semaine
    final weekDays = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];

    // Calculs pour le grid
    // On veut afficher le mois de vm.selectedDate

    // Premier jour du mois
    final firstDayOfMonth = DateTime(
      vm.selectedDate.year,
      vm.selectedDate.month,
      1,
    );
    // Dernier jour du mois (pour savoir combien de jours)
    final lastDayOfMonth = DateTime(
      vm.selectedDate.year,
      vm.selectedDate.month + 1,
      0,
    );

    final daysInMonth = lastDayOfMonth.day;
    // Offset : le 1er du mois est quel jour ? (Lundi = 1, donc offset = weekday - 1)
    final startOffset = firstDayOfMonth.weekday - 1;

    // Total cells = offset + days
    final totalCells = startOffset + daysInMonth;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              // On utilise un scroll view pour éviter l'overflow sur petits écrans
              // même si le grid n'est pas scrollable.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-têtes Jours - Alignés avec la grille
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                    ), // Match grid alignment
                    child: Row(
                      children:
                          weekDays
                              .map(
                                (d) => Expanded(
                                  child: Center(
                                    child: Text(
                                      d,
                                      style: TextStyle(
                                        color: kGold,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grille
                  AspectRatio(
                    aspectRatio: 0.85, // Un peu plus haut
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 12, // Espacement vertical
                            crossAxisSpacing: 8, // Espacement horizontal
                            childAspectRatio: 0.85, // Ratio des cellules
                          ),
                      itemCount: totalCells,
                      itemBuilder: (context, index) {
                        if (index < startOffset) {
                          return const SizedBox();
                        }

                        final dayNum = index - startOffset + 1;
                        final currentDate = DateTime(
                          vm.selectedDate.year,
                          vm.selectedDate.month,
                          dayNum,
                        );

                        final isToday =
                            DateTime.now().day == dayNum &&
                            DateTime.now().month == vm.selectedDate.month &&
                            DateTime.now().year == vm.selectedDate.year;

                        final isSelected = dayNum == vm.selectedDate.day;
                        final hasActivity = vm.daysWithActivityMonth.contains(
                          dayNum,
                        );

                        return ScaleButton(
                          onTap: () {
                            vm.selectDate(currentDate, updateWeek: true);
                            final sessionsForDay =
                                vm.sessionsDuMois
                                    .where(
                                      (s) =>
                                          s.date.day == dayNum &&
                                          s.date.month ==
                                              vm.selectedDate.month &&
                                          s.date.year == vm.selectedDate.year,
                                    )
                                    .toList();

                            if (sessionsForDay.isNotEmpty) {
                              _showDayDetailsDialog(
                                context,
                                currentDate,
                                sessionsForDay,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? kGold
                                      : (isToday
                                          ? Colors.white10
                                          : Colors.transparent),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? kGold
                                        : (isToday
                                            ? kGold.withOpacity(0.5)
                                            : Colors.white12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$dayNum",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.white,
                                    fontWeight:
                                        isToday || isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                if (hasActivity) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.black : kGold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDayDetailsDialog(
    BuildContext context,
    DateTime date,
    List<PlanningItem> sessions,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'EEEE d',
                            'fr_FR',
                          ).format(date).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMMM yyyy',
                            'fr_FR',
                          ).format(date).toUpperCase(),
                          style: TextStyle(
                            color: kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCompactSessionCard(
                        context,
                        sessions[index],
                        index + 1,
                        Colors.black26,
                        kGold,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PlanningViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_viewMode == PlanningViewMode.month)
                  InkWell(
                    onTap: () => vm.changeMonth(-1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.chevron_left, color: kGold, size: 20),
                    ),
                  ),
                Text(
                  DateFormat(
                    'MMMM yyyy',
                    'fr_FR',
                  ).format(vm.selectedDate).toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kGold,
                  ),
                ),
                if (_viewMode == PlanningViewMode.month)
                  InkWell(
                    onTap: () => vm.changeMonth(1),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.chevron_right, color: kGold, size: 20),
                    ),
                  ),
              ],
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
        // Toggle Switch & DatePicker
        Row(
          children: [
            if (_viewMode == PlanningViewMode.week) ...[
              ScaleButton(
                onTap: () => _selectDateFromCalendar(context, vm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              "Mois",
              style: TextStyle(
                color:
                    _viewMode == PlanningViewMode.month
                        ? Colors.white
                        : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: _viewMode == PlanningViewMode.month,
              activeColor: kGold,
              activeTrackColor: kGold.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.white10,
              onChanged: (val) {
                setState(() {
                  _viewMode =
                      val ? PlanningViewMode.month : PlanningViewMode.week;
                });
                // Si on passe en mode mois, on reload
                if (_viewMode == PlanningViewMode.month) {
                  vm.loadMonthData();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekSelector(BuildContext context, PlanningViewModel vm) {
    return Row(
      children: [
        ScaleButton(
          onTap: () {
            vm.changeWeek(-1);
            _scrollToIndex(0); // Reset scroll pour UX
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.chevron_left, color: Colors.white),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = vm.startOfWeek.add(Duration(days: index));
                final isSelected =
                    date.day == vm.selectedDate.day &&
                    date.month == vm.selectedDate.month;
                final hasActivity = vm.joursAvecActivite.contains(date.weekday);

                return _buildDayButton(
                  context,
                  vm,
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
            _scrollToIndex(0);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDayButton(
    BuildContext context,
    PlanningViewModel vm,
    DateTime date,
    bool isSelected,
    bool hasActivity,
  ) {
    return ScaleButton(
      onTap: () => vm.selectDate(date),
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

  Widget _buildListTitle(PlanningViewModel vm) {
    return Row(
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
        if (vm.sessionsDuJour.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${vm.sessionsDuJour.length} prévues",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 60, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            "Aucune séance prévue",
            style: TextStyle(
              color: Colors.white30,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    PlanningItem item,
    int index,
    Color bg,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
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
                  color: accent,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                            "MUSCU", // À dynamiser si l'info est dispo plus précisément
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (item.duration > 0) ...[
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${item.duration} min",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Colonne de droite : Actions + Badge Terminé
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ligne des boutons (Edit / Delete)
                  Row(
                    mainAxisSize:
                        MainAxisSize
                            .min, // Important pour ne pas prendre toute la largeur
                    children: [
                      if (item.sessionId != null)
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white54,
                            size: 20,
                          ),
                          onPressed:
                              () => _showDurationPickerDialog(
                                context,
                                item.title,
                                initialDuration: item.duration,
                                sessionId: item.sessionId,
                              ),
                          padding: EdgeInsets.zero, // Réduire padding
                          constraints:
                              const BoxConstraints(), // Réduire constraints
                        ),
                      if (item.sessionId != null) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed:
                              () => _confirmDelete(context, item.sessionId!),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),

                  // Badge Terminé en dessous
                  if (item.isDone) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey, // Filled grey
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white, // White check for visibility
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Terminé",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int sessionId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: kCardColor,
            title: const Text(
              "Supprimer ?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Voulez-vous vraiment supprimer cette séance ?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context
                      .read<PlanningViewModel>()
                      .deleteSession(sessionId)
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Séance supprimée",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      });
                },
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _selectDateFromCalendar(
    BuildContext context,
    PlanningViewModel vm,
  ) async {
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
            dialogTheme: DialogThemeData(backgroundColor: kBackground),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      vm.selectDate(picked, updateWeek: true);
      // On reste sur la vue semaine si on utilise le date picker
    }
  }

  void _showAddSessionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
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
                  Navigator.pop(
                    context,
                  ); // Fermer le sheet avant d'ouvrir le dialog
                  // Attention : context ici peut être instable si async, mais pop est ok.
                  // Utiliser le context parent (celui de build) pour le dialog suivante
                  _showDurationPickerDialog(context, "Cardio libre");
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
                  Navigator.pop(context);
                  _showDurationPickerDialog(context, "Muscu libre");
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
    BuildContext parentContext, // Context de la page pour le VM
    String type, {
    int? initialDuration,
    int? sessionId,
  }) async {
    int selectedDuration = (initialDuration ?? 45).clamp(10, 180);
    print(
      "[DEBUG] Opening dialog with duration: $selectedDuration (Initial: $initialDuration)",
    );
    String selectedType = type;

    await showDialog(
      context: parentContext,
      builder: (context) {
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
                    data: SliderTheme.of(parentContext).copyWith(
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final vm =
                        parentContext
                            .read<
                              PlanningViewModel
                            >(); // accès via parentContext !

                    if (sessionId == null) {
                      vm.addSession(selectedDuration, selectedType).then((_) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Séance ajoutée : $selectedType !",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: kGold,
                          ),
                        );
                      });
                    } else {
                      vm
                          .updateSession(
                            sessionId,
                            selectedDuration,
                            selectedType,
                          )
                          .then((_) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Séance modifiée !",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: kGold,
                              ),
                            );
                          });
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

  Widget _buildCompactSessionCard(
    BuildContext context,
    PlanningItem item,
    int index,
    Color bg,
    Color accent,
  ) {
    // Version plus compacte et épurée pour la liste mensuelle
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status icon instead of big index
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.isDone ? accent.withOpacity(0.2) : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isDone ? Icons.check : Icons.fitness_center,
              size: 16,
              color: item.isDone ? accent : Colors.white54,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.duration > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "${item.duration} min • Muscu", // Mock category
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),

          // Edit button (small)
          if (item.sessionId != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white30),
              onPressed:
                  () => _showDurationPickerDialog(
                    context,
                    item.title,
                    initialDuration: item.duration,
                    sessionId: item.sessionId,
                  ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
}
