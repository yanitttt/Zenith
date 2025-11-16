import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

enum Gender { femme, homme }

class ProfileBasicsPage extends StatefulWidget {
  final Future<void> Function({
    required String prenom,
    required String nom,
    required DateTime birthDate,
    required double weight,
    required double height,
    required Gender gender,
  }) onNext;

  const ProfileBasicsPage({super.key, required this.onNext});

  @override
  State<ProfileBasicsPage> createState() => _ProfileBasicsPageState();
}

class _ProfileBasicsPageState extends State<ProfileBasicsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prenom;
  late TextEditingController _nom;
  late TextEditingController _weight;
  late TextEditingController _height;

  DateTime? _dob;
  Gender? _gender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prenom = TextEditingController();
    _nom = TextEditingController();
    _weight = TextEditingController();
    _height = TextEditingController();
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45),
    filled: true,
    fillColor: const Color(0xFFE6E6E6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne ton genre')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await widget.onNext(
        prenom: _prenom.text.trim(),
        nom: _nom.text.trim(),
        birthDate: _dob!,
        weight: double.parse(_weight.text.trim()),
        height: double.parse(_height.text.trim()),
        gender: _gender!,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobText = _dob == null
        ? 'JJ/MM/ANNÉE'
        : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}';

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'À propos de toi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Pour personnaliser ton expérience',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prénom et Nom
                        const Text(
                          'Identité',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _prenom,
                                decoration: _dec('Prénom'),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _nom,
                                decoration: _dec('Nom'),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requis'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Date de naissance
                        const Text(
                          'Date de naissance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E6E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              dobText,
                              style: TextStyle(
                                color:
                                    _dob == null ? Colors.black45 : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Poids et Taille
                        const Text(
                          'Mesures',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _weight,
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                decoration: _dec('Poids (kg)'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Requis';
                                  }
                                  final w = double.tryParse(v.trim());
                                  if (w == null || w < 20 || w > 300) {
                                    return 'Entre 20 et 300';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _height,
                                keyboardType: const TextInputType
                                    .numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                decoration: _dec('Taille (cm)'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Requis';
                                  }
                                  final h = double.tryParse(v.trim());
                                  if (h == null || h < 50 || h > 250) {
                                    return 'Entre 50 et 250';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Genre
                        const Text(
                          'Genre',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _genderButton(
                                label: 'Femme',
                                selected: _gender == Gender.femme,
                                icon: Icons.female,
                                onTap: () =>
                                    setState(() => _gender = Gender.femme),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _genderButton(
                                label: 'Homme',
                                selected: _gender == Gender.homme,
                                icon: Icons.male,
                                onTap: () =>
                                    setState(() => _gender = Gender.homme),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handle,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_loading ? '...' : 'Suivant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.gold : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.black : AppTheme.gold,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
