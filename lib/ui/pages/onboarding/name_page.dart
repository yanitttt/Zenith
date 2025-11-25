import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NamePage extends StatefulWidget {
  final Future<void> Function({required String prenom, required String nom}) onSubmit;
  const NamePage({super.key, required this.onSubmit});

  @override
  State<NamePage> createState() => _NamePageState();
}


class _NamePageState extends State<NamePage> {
  final _form = GlobalKey<FormState>();
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    super.dispose();
  }

  Future<void> _handle() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.onSubmit(prenom: _prenom.text.trim(), nom: _nom.text.trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45),
    filled: true,
    fillColor: const Color(0xFFE6E6E6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text('A propos de toi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Pour personnaliser ton expérience', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text('Ton nom', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _prenom,
                      decoration: _dec('Ton prénom'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Prénom requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nom,
                      decoration: _dec('Ton nom'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handle,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_loading ? '...' : 'Suivant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
