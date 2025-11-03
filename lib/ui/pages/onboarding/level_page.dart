import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum FitnessLevel { debutant, intermediaire, avance }

class LevelPage extends StatefulWidget {
  final FitnessLevel? initialLevel;
  final VoidCallback? onBack;
  final Function(FitnessLevel level)? onNext;

  const LevelPage({
    super.key,
    this.initialLevel,
    this.onBack,
    this.onNext,
  });

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  FitnessLevel? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialLevel;
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
                'Quel est ton niveau ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cela nous aide à adapter les exercices',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),

              // Level buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _levelButton(
                      label: 'Débutant',
                      subtitle: 'Je commence ou je reprends',
                      selected: _value == FitnessLevel.debutant,
                      icon: Icons.emoji_events_outlined,
                      onTap: () => setState(() => _value = FitnessLevel.debutant),
                    ),
                    const SizedBox(height: 20),
                    _levelButton(
                      label: 'Intermédiaire',
                      subtitle: "J'ai de l'expérience",
                      selected: _value == FitnessLevel.intermediaire,
                      icon: Icons.emoji_events,
                      onTap: () => setState(() => _value = FitnessLevel.intermediaire),
                    ),
                    const SizedBox(height: 20),
                    _levelButton(
                      label: 'Avancé',
                      subtitle: "Je suis un athlète confirmé",
                      selected: _value == FitnessLevel.avance,
                      icon: Icons.military_tech,
                      onTap: () => setState(() => _value = FitnessLevel.avance),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Next button
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

  Widget _levelButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold : Colors.black,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.gold : Colors.grey.shade800,
            width: 2,
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: selected ? Colors.black : AppTheme.gold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppTheme.gold : Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
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
