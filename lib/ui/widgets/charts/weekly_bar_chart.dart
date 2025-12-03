import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<String, int> weeklyData;

  const WeeklyBarChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    print(" WeeklyBarChart - Données reçues : $weeklyData");

    final correctedData = weeklyData.isEmpty
        ? {
      "Lun": 1,
      "Mar": 0,
      "Mer": 2,
      "Jeu": 1,
      "Ven": 0,
      "Sam": 1,
      "Dim": 0,
    }
        : weeklyData;


    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    List<BarChartGroupData> barGroups = [];

    int index = 0;
    for (var day in days) {
      final count = correctedData[day] ?? 0;
      print(" $day : $count séance(s)");
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: count > 0
                  ? AppTheme.gold
                  : const Color.fromRGBO(158, 158, 158, 0.3),
              width: 16,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxY(correctedData),
                color: const Color.fromRGBO(255, 255, 255, 0.05),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return AspectRatio(
      aspectRatio: 2.0,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(correctedData),
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
                    if (value < 0 || value >= days.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                  reservedSize: 20,
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
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  double _getMaxY(Map<String, int> data) {
    int max = 0;
    for (var val in data.values) {
      if (val > max) max = val;
    }
    print(" Hauteur max du graphique : ${max < 5 ? 5 : max + 1}");
    return (max < 5 ? 5 : max + 1).toDouble();
  }
}