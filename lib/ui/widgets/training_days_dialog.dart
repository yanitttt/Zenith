import 'package:flutter/material.dart';

class TrainingDaysDialog extends StatefulWidget {
  final List<int> selectedDays;

  const TrainingDaysDialog({super.key, required this.selectedDays});

  @override
  State<TrainingDaysDialog> createState() => _TrainingDaysDialogState();
}

class _TrainingDaysDialogState extends State<TrainingDaysDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedDays);
  }

  void _toggleDay(int dayNum) {
    setState(() {
      if (_tempSelected.contains(dayNum)) {
        _tempSelected.remove(dayNum);
      } else {
        _tempSelected.add(dayNum);
      }
      _tempSelected.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return Dialog(
      backgroundColor: const Color(0xFF020216),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD9BE77), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFD9BE77),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Jours d\'entraînement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD9BE77),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez les jours où vous souhaitez vous entraîner',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _tempSelected.contains(dayNum);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _toggleDay(dayNum),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFD9BE77).withOpacity(0.2)
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFD9BE77)
                                : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color:
                              isSelected
                                  ? const Color(0xFFD9BE77)
                                  : Colors.white54,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD9BE77),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, _tempSelected),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
