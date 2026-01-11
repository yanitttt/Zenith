import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class RulerPicker extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String unit;
  final double step; // E.g., 0.1 or 1.0

  const RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    required this.unit,
    this.step = 1.0,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late ScrollController _scrollController;
  late double _currentValue;
  final double _tickWidth = 10.0; // Espacement entre chaque trait

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;

    // Calcul de l'offset initial pour centrer la valeur
    // Offset = (Value - Min) / Step * TickWidth
    final initialOffset =
        ((widget.initialValue - widget.min) / widget.step) * _tickWidth;

    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Index calculé depuis l'offset
    final index = (offset / _tickWidth).round();

    // Valeur brute
    double value = widget.min + (index * widget.step);

    // Bornage
    if (value < widget.min) value = widget.min;
    if (value > widget.max) value = widget.max;

    if (value != _currentValue) {
      if (mounted) {
        setState(() => _currentValue = value);
      }
      widget.onChanged(value);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nombre total de gradations
    final int totalTicks =
        ((widget.max - widget.min) / widget.step).floor() + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        final maxHeight = constraints.maxHeight;

        // Calcul des hauteurs proportionnelles
        // On veut réserver ~50-60% pour la règle et le reste pour le texte
        final rulerHeight = maxHeight * 0.55;
        final textHeight = maxHeight * 0.45;

        // Ajustement de la taille de police en fonction de la hauteur dispo
        final fontSize = (textHeight * 0.8).clamp(20.0, 48.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Affichage de la valeur (RESPONSIVE)
            SizedBox(
              height: textHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentValue.toStringAsFixed(widget.step < 1 ? 1 : 0),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.unit,
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize:
                            fontSize *
                            0.4, // Taille proportionnelle à la valeur
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // La Règle (RESPONSIVE)
            SizedBox(
              height: rulerHeight,
              child: Stack(
                children: [
                  // Liste des graduations
                  ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: totalTicks,
                    padding: EdgeInsets.symmetric(horizontal: halfWidth),
                    itemBuilder: (context, index) {
                      final isMajor = (index % 10) == 0;
                      final isSemiMajor = (index % 5) == 0 && !isMajor;

                      final majorH = rulerHeight * 0.6;
                      final semiH = rulerHeight * 0.4;
                      final minH = rulerHeight * 0.25;

                      return Container(
                        width: _tickWidth,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: isMajor ? 2 : 1,
                          height:
                              isMajor ? majorH : (isSemiMajor ? semiH : minH),
                          color: isMajor ? Colors.white : Colors.white38,
                        ),
                      );
                    },
                  ),

                  // Curseur central fixe
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 4,
                      height: rulerHeight * 0.7, // Proportionnel
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gradient léger
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.scaffold.withOpacity(1),
                              AppTheme.scaffold.withOpacity(0),
                              AppTheme.scaffold.withOpacity(0),
                              AppTheme.scaffold.withOpacity(1),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
