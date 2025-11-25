import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DobPage extends StatefulWidget {
  final DateTime? initial;
  final Future<void> Function(DateTime dob) onNext;
  final VoidCallback onBack;
  const DobPage({super.key, this.initial, required this.onNext, required this.onBack});

  @override
  State<DobPage> createState() => _DobPageState();
}

class _DobPageState extends State<DobPage> {
  DateTime? _dob;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dob = widget.initial;
  }

  Future<void> _pick() async {
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

  Future<void> _next() async {
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne ta date de naissance')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onNext(_dob!);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _dob == null
        ? 'JJ/MM/ANNÉE'
        : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}';

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
                    Text('Pour adapter les recommandations à ton profil', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text('Date de naissance', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),

              GestureDetector(
                onTap: _pick,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: _dob == null ? Colors.black45 : Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
