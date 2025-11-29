import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<String, int> weeklyData; // e.g., {'Lun': 1, 'Mar': 0, ...}

  const WeeklyBarChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    // Convert map to list of BarChartGroupData
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    List<BarChartGroupData> barGroups = [];
    
    int index = 0;
    for (var day in days) {
      final count = weeklyData[day] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: count > 0 ? AppTheme.gold : const Color.fromRGBO(158, 158, 158, 0.3),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxY(), // Max height background
                color: const Color.fromRGBO(255, 255, 255, 0.05),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return AspectRatio(
      aspectRatio: 2.0, // More wide
      child: Container(
        padding: const EdgeInsets.all(8), // Less padding
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => const Color(0xFF2C2C2C),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} séances',
                    const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= days.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10, // Smaller font
                        ),
                      ),
                    );
                  },
                  reservedSize: 20, // Less reserved size
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    int max = 0;
    for (var val in weeklyData.values) {
      if (val > max) max = val;
    }
    return (max < 5 ? 5 : max + 1).toDouble();
  }
}
