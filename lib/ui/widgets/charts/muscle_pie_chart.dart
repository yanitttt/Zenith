import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../services/dashboard_service.dart';

class MusclePieChart extends StatefulWidget {
  final List<MuscleStat> muscleStats;

  const MusclePieChart({super.key, required this.muscleStats});

  @override
  State<MusclePieChart> createState() => _MusclePieChartState();
}

class _MusclePieChartState extends State<MusclePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.muscleStats.isEmpty) {
      return const SizedBox(); // Or a placeholder
    }

    return AspectRatio(
      aspectRatio: 1.0, // Square
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30, // Smaller center
                sections: _showingSections(),
              ),
            ),
            // Center Text if needed, or leave empty
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(widget.muscleStats.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final stat = widget.muscleStats[i];
      
      return PieChartSectionData(
        color: _getColor(i),
        value: stat.count.toDouble(),
        title: '${stat.count}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }



  Color _getColor(int index) {
    const colors = [
      AppTheme.gold,
      Color(0xFF2C123A), // Purple from dashboard
      Color(0xFF4A90E2), // Blue
      Color(0xFF50E3C2), // Teal
      Color(0xFFE57373), // Red
      Colors.grey,
    ];
    return colors[index % colors.length];
  }
}
