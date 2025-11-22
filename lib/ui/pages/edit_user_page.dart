import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/db/app_db.dart';
import '../../data/db/daos/user_dao.dart';
import '../../services/ImcService.dart';

class EditProfilePage extends StatefulWidget {
  final AppUserData user;
  final UserDao userDao;

  const EditProfilePage({
    super.key,
    required this.user,
    required this.userDao,
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

  @override
  void initState() {
    super.initState();
    nomCtrl = TextEditingController(text: widget.user.nom ?? "");
    prenomCtrl = TextEditingController(text: widget.user.prenom ?? "");
    poidsCtrl = TextEditingController(text: widget.user.weight?.toString() ?? "");
    tailleCtrl = TextEditingController(text: widget.user.height?.toString() ?? "");

    // 🔥 Uniformisation automatique
    gender = _normalizeGender(widget.user.gender);
    niveau = widget.user.level;
    metabolism = widget.user.metabolism;
    birthDate = widget.user.birthDate;
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

    if (!mounted) return;
    Navigator.pop(context, true);
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

            // Genre
            _selector(
              label: "Genre",
              value: gender,
              items: const ["Homme", "Femme"],
              onChanged: (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 12),

            // Niveau
            _selector(
              label: "Niveau",
              value: niveau,
              items: const ["Débutant", "Intermédiaire", "Avancé"],
              onChanged: (v) => setState(() => niveau = v),
            ),
            const SizedBox(height: 12),

            // Métabolisme
            _selector(
              label: "Métabolisme",
              value: metabolism,
              items: const ["Lent", "Normal", "Rapide"],
              onChanged: (v) => setState(() => metabolism = v),
            ),
            const SizedBox(height: 12),

            // Date naissance
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
                )
              ],
            ),

            const SizedBox(height: 20),

            if (poidsCtrl.text.isNotEmpty && tailleCtrl.text.isNotEmpty)
              Text(
                "IMC actuel : $currentIMC",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
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

  Widget _input(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
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
      value: items.contains(value) ? value : null,
      onChanged: onChanged,
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white)),
              ))
          .toList(),
    );
  }
}