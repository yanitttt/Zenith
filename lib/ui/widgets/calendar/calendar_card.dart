import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF2B2B2B);

    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppTheme.calendarBg,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Header(textColor: textColor),
          SizedBox(height: 6),
          _WeekDays(),
          SizedBox(height: 4),
          Expanded(child: _MonthGrid()),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color textColor;
  const _Header({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Janvier",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        Text(
          "2022",
          style: TextStyle(
            color: textColor.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WeekDays extends StatelessWidget {
  const _WeekDays();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _CalHead("Lu"),
        _CalHead("Ma"),
        _CalHead("Me"),
        _CalHead("Je"),
        _CalHead("Ve"),
        _CalHead("Sa", weekend: true),
        _CalHead("Di", weekend: true),
      ],
    );
  }
}


class _CalHead extends StatelessWidget {
  final String label;
  final bool weekend;
  const _CalHead(this.label, {this.weekend = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: weekend ? const Color(0xFFB83A3A) : const Color(0xFF2B2B2B),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid();

  @override
  Widget build(BuildContext context) {

    const startOffset = 5;
    final cells = <Widget>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= 31; day++) {
      final index = startOffset + day - 1;
      final weekday = index % 7;
      final isSat = weekday == 5;
      final isSun = weekday == 6;
      final color = isSun
          ? const Color(0xFFB83A3A)
          : isSat
          ? const Color(0xFF3B62C7)
          : const Color(0xFF2B2B2B);
      cells.add(Center(
        child: Text(
          "$day",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ));
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }
}
