import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum Metabolism { rapide, lent }

class MetabolismPage extends StatefulWidget {
  final Metabolism? initialMetabolism;
  final VoidCallback? onBack;
  final Function(Metabolism metabolism)? onNext;

  const MetabolismPage({
    super.key,
    this.initialMetabolism,
    this.onBack,
    this.onNext,
  });

  @override
  State<MetabolismPage> createState() => _MetabolismPageState();
}

class _MetabolismPageState extends State<MetabolismPage> {
  Metabolism? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialMetabolism;
  }

  void _handle() {
    if (_value == null) return;
    widget.onNext?.call(_value!);
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
                'Quel est ton métabolisme ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cela nous aide à personnaliser ton programme',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 80),


              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _metabolismButton(
                      label: 'Rapide',
                      subtitle: 'Je brûle facilement les calories',
                      selected: _value == Metabolism.rapide,
                      icon: Icons.bolt,
                      onTap: () => setState(() => _value = Metabolism.rapide),
                    ),
                    const SizedBox(height: 30),
                    _metabolismButton(
                      label: 'Lent',
                      subtitle: 'Je prends du poids facilement',
                      selected: _value == Metabolism.lent,
                      icon: Icons.eco,
                      onTap: () => setState(() => _value = Metabolism.lent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),


              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _value == null ? null : _handle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Terminer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check, size: 20),
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

  Widget _metabolismButton({
    required String label,
    required String subtitle,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold : Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.gold : Colors.grey.shade800,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: selected ? Colors.black : AppTheme.gold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppTheme.gold : Colors.black,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? Colors.black87 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
