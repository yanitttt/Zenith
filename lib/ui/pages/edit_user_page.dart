import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_theme.dart';
import 'package:recommandation_mobile/data/db/daos/user_equipment_dao.dart';
import 'package:recommandation_mobile/data/db/daos/user_goal_dao.dart';
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../../services/ImcService.dart';
import 'package:recommandation_mobile/ui/pages/onboarding/objectives_page.dart';
import 'package:recommandation_mobile/ui/pages/onboarding/equipment_page.dart';

const Color _goldColor = AppTheme.gold;

class EditProfilePage extends StatefulWidget {
  final AppUserData user;
  final UserDao userDao;
  final AppDb db;
  final UserGoalDao goalDao;
  final UserEquipmentDao equipmentDao;

  const EditProfilePage({
    super.key,
    required this.user,
    required this.userDao,
    required this.db,
    required this.goalDao,
    required this.equipmentDao,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nomCtrl;
  late final TextEditingController prenomCtrl;
  late final TextEditingController poidsCtrl;
  late final TextEditingController tailleCtrl;

  String? gender;
  String? niveau;
  String? metabolism;
  DateTime? birthDate;
  int? selectedGoalId;
  List<int> selectedEquipmentIds = [];
  List<ObjectiveData> allObjectives = [];
  List<EquipmentData> allEquipments = [];

  @override
  void initState() {
    super.initState();
    nomCtrl = TextEditingController(text: widget.user.nom ?? "");
    prenomCtrl = TextEditingController(text: widget.user.prenom ?? "");
    poidsCtrl = TextEditingController(
      text: widget.user.weight?.toString() ?? "",
    );
    tailleCtrl = TextEditingController(
      text: widget.user.height?.toString() ?? "",
    );

    gender = _normalizeGender(widget.user.gender);
    niveau = widget.user.level;
    metabolism = widget.user.metabolism;
    birthDate = widget.user.birthDate;
    _loadGoalsAndEquipment();
  }

  String? _normalizeGender(String? g) {
    if (g == null) return null;
    switch (g.trim().toLowerCase()) {
      case "homme":
      case "h":
      case "m":
      case "male":
        return "Homme";
      case "femme":
      case "f":
      case "female":
        return "Femme";
    }
    return null;
  }

  Future<void> _loadGoalsAndEquipment() async {
    allObjectives = await widget.goalDao.allObjectivesList();
    allEquipments = await widget.equipmentDao.allEquipmentList();

    final userGoals = (await widget.goalDao.goalsOf(widget.user.id));
    selectedGoalId = userGoals.isNotEmpty ? userGoals.first.objectiveId : null;

    selectedEquipmentIds =
        (await widget.equipmentDao.equipmentOf(
          widget.user.id,
        )).map((e) => e.equipmentId).toList();

    setState(() {});
  }

  String _getSelectedGoalName() {
    if (selectedGoalId == null) {
      return "Non défini";
    }
    if (allObjectives.isEmpty) {
      return "Chargement des objectifs...";
    }

    final selected = allObjectives.firstWhere(
      (o) => o.id == selectedGoalId,
      orElse:
          () => ObjectiveData(id: -1, name: 'Objectif non trouvé', code: ''),
    );
    return selected.name;
  }

  Future<void> _navigateToObjectivesPage() async {
    final updatedGoals = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder:
            (context) => ObjectivesPage(
              db: widget.db,
              initialGoalIds: selectedGoalId != null ? [selectedGoalId!] : [],
            ),
      ),
    );

    if (updatedGoals != null) {
      setState(() {
        selectedGoalId = updatedGoals.isNotEmpty ? updatedGoals.first : null;
      });
      await widget.goalDao.replace(widget.user.id, updatedGoals);
    }
  }

  Future<void> _navigateToEquipmentPage() async {
    final updatedEquipment = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(
        builder:
            (context) => EquipmentPage(
              db: widget.db,
              initialEquipmentIds: selectedEquipmentIds,
            ),
      ),
    );

    if (updatedEquipment != null) {
      setState(() {
        selectedEquipmentIds = updatedEquipment;
      });
      await widget.equipmentDao.replace(widget.user.id, updatedEquipment);
    }
  }

  double get currentIMC {
    final h = double.tryParse(tailleCtrl.text);
    final w = double.tryParse(poidsCtrl.text);
    if (h == null || w == null) return 0;
    final calc = IMCcalculator(height: h, weight: w);
    return double.parse(calc.calculateIMC().toStringAsFixed(2));
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => birthDate = picked);
  }

  Future<void> _save() async {
    final updated = widget.user.copyWith(
      nom: Value(nomCtrl.text.trim()),
      prenom: Value(prenomCtrl.text.trim()),
      weight: Value(double.tryParse(poidsCtrl.text)),
      height: Value(double.tryParse(tailleCtrl.text)),
      gender: Value(gender),
      level: Value(niveau),
      metabolism: Value(metabolism),
      birthDate: Value(birthDate),
    );

    await widget.userDao.updateOne(updated);
    final List<int> goalsToSave =
        selectedGoalId != null ? [selectedGoalId!] : [];

    await widget.goalDao.replace(widget.user.id, goalsToSave);
    await widget.equipmentDao.replace(widget.user.id, selectedEquipmentIds);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _goldColor),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _goldColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _selector({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      onChanged: onChanged,
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _goldColor),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _goldColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      items:
          items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _input("Nom", nomCtrl),
            const SizedBox(height: 12),
            _input("Prénom", prenomCtrl),
            const SizedBox(height: 12),
            _input("Poids (kg)", poidsCtrl, isNumber: true),
            const SizedBox(height: 12),
            _input("Taille (cm)", tailleCtrl, isNumber: true),
            const SizedBox(height: 12),

            _selector(
              label: "Genre",
              value: gender,
              items: const ["Homme", "Femme"],
              onChanged: (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 12),
            _selector(
              label: "Niveau",
              value: niveau,
              items: const ["Débutant", "Intermédiaire", "Avancé"],
              onChanged: (v) => setState(() => niveau = v),
            ),
            const SizedBox(height: 12),
            _selector(
              label: "Métabolisme",
              value: metabolism,
              items: const ["Lent", "Normal", "Rapide"],
              onChanged: (v) => setState(() => metabolism = v),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.cake, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  birthDate == null
                      ? "Date de naissance : —"
                      : "Naissance : ${birthDate!.day}/${birthDate!.month}/${birthDate!.year}",
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectBirthDate,
                  child: const Text("Modifier"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.sports_gymnastics, color: _goldColor),
              title: const Text(
                "Modifier l'objectif",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _getSelectedGoalName(),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: _navigateToObjectivesPage,
            ),
            Divider(color: Colors.grey.shade800),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.fitness_center, color: _goldColor),
              title: const Text(
                "Modifier l'équipement",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${selectedEquipmentIds.length} équipement(s) sélectionné(s)",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: _navigateToEquipmentPage,
            ),
            Divider(color: Colors.grey.shade800),

            const SizedBox(height: 30),
            if (poidsCtrl.text.isNotEmpty && tailleCtrl.text.isNotEmpty)
              Text(
                "IMC actuel : $currentIMC",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
