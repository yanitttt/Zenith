import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:recommandation_mobile/data/db/app_db.dart';
import 'package:recommandation_mobile/services/planning_service.dart';
import 'package:recommandation_mobile/ui/widgets/planning/scale_button.dart';

class PlanningPage extends StatefulWidget {
  final AppDb db;
  const PlanningPage({super.key, required this.db});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late PlanningService _service;


  final Color kBackground = const Color(0xFF020216);
  final Color kCardColor = const Color(0xFF0F112B);
  final Color kGold = const Color(0xFFE4C87F);
  final Color kTextGrey = const Color(0xFF9E9E9E);

  DateTime _selectedDate = DateTime.now();
  DateTime _startOfWeek = DateTime.now();
  int? _currentUserId;

  List<PlanningItem> _sessionsDuJour = [];
  Set<int> _joursAvecActivite = {};
  bool _isLoading = true;

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _service = PlanningService(widget.db);

    final now = DateTime.now();
    _startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _startOfWeek = DateTime(
      _startOfWeek.year,
      _startOfWeek.month,
      _startOfWeek.day,
    );

    _initData();
  }

  void _ensureScrollController() {
    if (_scrollController != null) return;

    final now = DateTime.now();

    final dayIndex = now.weekday - 1;
    final double initialOffset = (dayIndex * 77.0);

    _scrollController = ScrollController(
      initialScrollOffset: initialOffset > 50 ? initialOffset - 50 : 0,
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final user = await widget.db.select(widget.db.appUser).getSingleOrNull();
    if (user != null) {
      _currentUserId = user.id;
    } else {
      _currentUserId = 1;
    }
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    if (_currentUserId == null) return;
    setState(() => _isLoading = true);

    try {
      final activites = await _service.getDaysWithActivity(
        _currentUserId!,
        _startOfWeek,
      );
      final sessions = await _service.getSessionsForDate(
        _currentUserId!,
        _selectedDate,
      );

      if (mounted) {
        setState(() {
          _joursAvecActivite = activites;
          _sessionsDuJour = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur chargement: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeWeek(int offset) {
    setState(() {
      _startOfWeek = _startOfWeek.add(Duration(days: 7 * offset));

      _ensureScrollController();
      if (_scrollController!.hasClients) {
        _scrollController!.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    _chargerDonnees();
  }

  Future<void> _selectDateFromCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      setState(() {
        _selectedDate = picked;
        _startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
        _startOfWeek = DateTime(
          _startOfWeek.year,
          _startOfWeek.month,
          _startOfWeek.day,
        );


        _ensureScrollController();
        final dayIndex = picked.weekday - 1;
        if (_scrollController!.hasClients) {
          _scrollController!.animateTo(
            (dayIndex * 77.0) - 50,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      _chargerDonnees();
    }
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _chargerDonnees();
  }


  void _showAddSessionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  Navigator.pop(context);
                  _showDurationPickerDialog("Cardio libre");
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
                  _showDurationPickerDialog("Muscu libre");
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
    String type, {
    int? initialDuration,
    int? sessionId,
  }) async {
    int selectedDuration = initialDuration ?? 45;
    String selectedType = type;

    await showDialog(
      context: context,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (sessionId == null) {
                      _ajouterSeanceLibre(selectedDuration, selectedType);
                    } else {
                      _modifierSeanceLibre(
                        sessionId,
                        selectedDuration,
                        selectedType,
                      );
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


  Future<void> _ajouterSeanceLibre(int duree, String name) async {
    if (_currentUserId == null) return;

    final ts =
        DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        ).millisecondsSinceEpoch ~/
        1000;

    await widget.db
        .into(widget.db.session)
        .insert(
          SessionCompanion.insert(
            userId: _currentUserId!,
            programDayId: const drift.Value(null),
            dateTs: ts,
            durationMin: drift.Value(duree),
            name: drift.Value(name),
          ),
        );

    _chargerDonnees();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Séance ajoutée : $name ($duree min) !",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> _modifierSeanceLibre(
    int sessionId,
    int duree,
    String name,
  ) async {
    await (widget.db.update(widget.db.session)
      ..where((t) => t.id.equals(sessionId))).write(
      SessionCompanion(
        durationMin: drift.Value(duree),
        name: drift.Value(name),
      ),
    );

    _chargerDonnees();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Séance modifiée !",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> _supprimerSession(int sessionId) async {
    await (widget.db.delete(widget.db.session)
      ..where((t) => t.id.equals(sessionId))).go();

    _chargerDonnees();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Séance supprimée",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    _ensureScrollController();
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                        ).format(_selectedDate).toUpperCase(),
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
                  ScaleButton(
                    onTap: _selectDateFromCalendar,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  ScaleButton(
                    onTap: () => _changeWeek(-1),
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
                          final date = _startOfWeek.add(Duration(days: index));
                          final isSelected =
                              date.day == _selectedDate.day &&
                              date.month == _selectedDate.month;
                          final hasActivity = _joursAvecActivite.contains(
                            date.weekday,
                          );
                          return _buildDayButton(date, isSelected, hasActivity);
                        },
                      ),
                    ),
                  ),
                  ScaleButton(
                    onTap: () => _changeWeek(1),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                  if (_sessionsDuJour.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_sessionsDuJour.length} prévues",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: kGold))
                        : _sessionsDuJour.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          itemCount: _sessionsDuJour.length,
                          itemBuilder: (context, index) {
                            return _buildSessionCard(
                              _sessionsDuJour[index],
                              index + 1,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleButton(
        onTap: () => _showAddSessionSheet(),
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

  Widget _buildDayButton(DateTime date, bool isSelected, bool hasActivity) {
    return ScaleButton(
      onTap: () => _onDaySelected(date),
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

  Widget _buildSessionCard(PlanningItem item, int index) {
    final bool isActuallyDone = item.duration > 0 || item.isDone;
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
                            "MUSCU",
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
                            color: kTextGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${item.duration} min",
                            style: TextStyle(color: kTextGrey, fontSize: 12),
                          ),
                        ] else ...[
                          Text(
                            "-- min",
                            style: TextStyle(color: kTextGrey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isActuallyDone
                  ? _buildMiniStat(
                    Icons.check_circle,
                    "Terminée",
                    Colors.greenAccent,
                  )
                  : item.isScheduled
                  ? _buildMiniStat(
                    Icons.calendar_today,
                    "Planifiée",
                    Colors.blueAccent,
                  )
                  : _buildMiniStat(Icons.schedule, "À faire", kGold),
              _buildMiniStat(Icons.fitness_center, "Programme", Colors.white70),
            ],
          ),

          if (item.sessionId != null && item.programDayId == null) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.white12, height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showDurationPickerDialog(
                      item.title,
                      initialDuration: item.duration,
                      sessionId: item.sessionId,
                    );
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.blueAccent,
                  ),
                  label: const Text(
                    "Modifier",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _supprimerSession(item.sessionId!),
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    "Supprimer",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bed, size: 40, color: Colors.white24),
          ),
          const SizedBox(height: 20),
          const Text(
            "Repos",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucune séance prévue pour ce jour.",
            style: TextStyle(color: kTextGrey),
          ),
        ],
      ),
    );
  }
}
