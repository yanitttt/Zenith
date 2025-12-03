import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class HeightPage extends StatefulWidget {
  final double? initialHeight;
  final VoidCallback? onBack;
  final Function(double height)? onNext;

  const HeightPage({
    super.key,
    this.initialHeight,
    this.onBack,
    this.onNext,
  });

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _height;

  @override
  void initState() {
    super.initState();
    _height = TextEditingController(
      text: widget.initialHeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _height.dispose();
    super.dispose();
  }

  void _handle() {
    if (!_formKey.currentState!.validate()) return;
    final h = double.tryParse(_height.text.trim());
    if (h == null) return;
    widget.onNext?.call(h);
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


              const Text(
                'Quelle est ta taille ?',
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


              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: _dec('Taille (cm)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Taille requise';
                    }
                    final height = double.tryParse(v.trim());
                    if (height == null) {
                      return 'Taille invalide';
                    }
                    if (height < 50 || height > 250) {
                      return 'Taille doit être entre 50 et 250 cm';
                    }
                    return null;
                  },
                ),
              ),

              const Spacer(),


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
