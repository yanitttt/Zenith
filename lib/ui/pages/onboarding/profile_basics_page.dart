import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/ruler_picker.dart';

enum Gender { femme, homme }

class ProfileBasicsPage extends StatefulWidget {
  final Future<void> Function({
    required String prenom,
    required String nom,
    required DateTime birthDate,
    required double weight,
    required double height,
    required Gender gender,
  })
  onNext;

  final String initialPrenom;
  final String initialNom;
  final DateTime? initialBirthDate;
  final double? initialWeight;
  final double? initialHeight;
  final Gender? initialGender;

  const ProfileBasicsPage({
    super.key,
    required this.onNext,
    this.initialPrenom = "",
    this.initialNom = "",
    this.initialBirthDate,
    this.initialWeight,
    this.initialHeight,
    this.initialGender,
  });

  @override
  State<ProfileBasicsPage> createState() => _ProfileBasicsPageState();
}

class _ProfileBasicsPageState extends State<ProfileBasicsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prenom;
  late TextEditingController _nom;

  late double _weightVal;
  late double _heightVal;

  DateTime? _dob;
  Gender? _gender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prenom = TextEditingController(text: widget.initialPrenom);
    _nom = TextEditingController(text: widget.initialNom);

    _weightVal = widget.initialWeight ?? 75.0;
    _heightVal = widget.initialHeight ?? 175.0;
    _dob = widget.initialBirthDate;
    _gender = widget.initialGender;
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFF1E1E1E), // Fond sombre
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 0,
    ), // Compact
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day),
      locale: const Locale('fr'),
      builder: (c, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _handle() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne ta date de naissance')),
      );
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sélectionne ton genre')));
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.onNext(
        prenom: _prenom.text.trim(),
        nom: _nom.text.trim(),
        birthDate: _dob!,
        weight: _weightVal,
        height: _heightVal,
        gender: _gender!,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Styles de texte
  final TextStyle _sectionTitleStyle = const TextStyle(
    color: Colors.white,
    fontSize: 18, // Augmenté selon feedback
    fontWeight: FontWeight.w800, // Plus gras
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    final dobText =
        _dob == null
            ? 'JJ/MM/ANNÉE'
            : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}';

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER (Fixe) ---
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'À propos de toi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pour personnaliser ton expérience',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- FORMULAIRE (Expanded) ---
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // IDENTITÉ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IDENTITÉ',
                            style: _sectionTitleStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _prenom,
                              decoration: _dec('Prénom'),
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.next,
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? '!'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _nom,
                              decoration: _dec('Nom'),
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.done,
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? '!'
                                          : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // DATE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATE DE NAISSANCE',
                            style: _sectionTitleStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          height: 44, // Compact
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dobText,
                                style: TextStyle(
                                  color:
                                      _dob == null
                                          ? Colors.white54
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(), // Espace flexible
                      // POIDS
                      Column(
                        children: [
                          Text('TON POIDS', style: _sectionTitleStyle),
                          // Spacer retiré pour coller le titre
                        ],
                      ),
                      Expanded(
                        flex: 4, // Donne de l'importance
                        child: RulerPicker(
                          min: 30,
                          max: 200,
                          initialValue: _weightVal,
                          step: 0.1,
                          unit: 'kg',
                          onChanged: (val) => _weightVal = val,
                        ),
                      ),

                      const Spacer(),

                      // TAILLE
                      Column(
                        children: [
                          Text('TA TAILLE', style: _sectionTitleStyle),
                        ],
                      ),
                      Expanded(
                        flex: 4,
                        child: RulerPicker(
                          min: 100,
                          max: 250,
                          initialValue: _heightVal,
                          step: 1.0,
                          unit: 'cm',
                          onChanged: (val) => _heightVal = val,
                        ),
                      ),

                      const Spacer(),

                      // GENRE
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GENRE',
                            style: _sectionTitleStyle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _genderButton(
                              label: 'Femme',
                              selected: _gender == Gender.femme,
                              icon: Icons.female,
                              onTap:
                                  () => setState(() => _gender = Gender.femme),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _genderButton(
                              label: 'Homme',
                              selected: _gender == Gender.homme,
                              icon: Icons.male,
                              onTap:
                                  () => setState(() => _gender = Gender.homme),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- BOUTON SUIVANT (Fixe) ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Suivant',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderButton({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52, // Compact
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.gold : Colors.white10,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.black : Colors.white60,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
