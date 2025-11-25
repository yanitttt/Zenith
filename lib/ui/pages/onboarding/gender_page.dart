import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum Gender { femme, homme }

class GenderPage extends StatefulWidget {
  final Gender? initial;
  final Future<void> Function(Gender gender) onNext;
  final VoidCallback onBack;
  const GenderPage({super.key, this.initial, required this.onNext, required this.onBack});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  Gender? _value;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  Future<void> _next() async {
    if (_value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne ton genre')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onNext(_value!);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          child: Column(
            children: [
              const Text('A propos de toi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Pour te fournir la meilleure expérience possible en fonction de ton genre', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),

              _genderButton(
                label: 'Femelle',
                selected: _value == Gender.femme,
                icon: Icons.female,
                primary: true,
                onTap: () => setState(() => _value = Gender.femme),
              ),
              const SizedBox(height: 18),
              _genderButton(
                label: 'Mâle',
                selected: _value == Gender.homme,
                icon: Icons.male,
                primary: false,
                onTap: () => setState(() => _value = Gender.homme),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(icon: Icons.arrow_back, onTap: widget.onBack),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _next,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_loading ? '...' : 'Suivant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                  ),
                ],
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
    required bool primary,
    required VoidCallback onTap,
  }) {
    final bg = primary ? AppTheme.gold : Colors.black;
    final border = primary ? AppTheme.gold : Colors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Column(
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 4),
              boxShadow: selected ? const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))] : null,
            ),
            child: Icon(icon, color: primary ? Colors.black : Colors.white, size: 64),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
