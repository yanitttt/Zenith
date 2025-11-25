import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class WeightPage extends StatefulWidget {
  final double? initialWeight;
  final VoidCallback? onBack;
  final Function(double weight)? onNext;

  const WeightPage({
    super.key,
    this.initialWeight,
    this.onBack,
    this.onNext,
  });

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    _weight = TextEditingController(
      text: widget.initialWeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  void _handle() {
    if (!_formKey.currentState!.validate()) return;
    final w = double.tryParse(_weight.text.trim());
    if (w == null) return;
    widget.onNext?.call(w);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              InkResponse(
                onTap: widget.onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Quel est ton poids ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cela nous aide à personnaliser tes recommandations',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: _dec('Poids (kg)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Poids requis';
                    }
                    final weight = double.tryParse(v.trim());
                    if (weight == null) {
                      return 'Poids invalide';
                    }
                    if (weight < 20 || weight > 300) {
                      return 'Poids doit être entre 20 et 300 kg';
                    }
                    return null;
                  },
                ),
              ),

              const Spacer(),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Suivant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFE6E6E6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      );
}
