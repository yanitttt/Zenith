import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'donut_gauge.dart';

class ProgressCard extends StatelessWidget {
  final double percent;
  final String title;
  const ProgressCard({
    super.key,
    required this.percent,
    this.title = "Progression\nde l’objectif",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Spacer(),
          Center(child: DonutGauge(percent: percent)),
          const Spacer(),
        ],
      ),
    );
  }
}
