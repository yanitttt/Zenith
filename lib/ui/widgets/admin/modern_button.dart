import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isCompact;
  final bool isDanger;

  const ModernButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.isCompact = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDanger
            ? Colors.red.shade900.withOpacity(0.3)
            : const Color(0xFF0F0F1E);
    final borderColor = isDanger ? Colors.red.shade700 : AppTheme.gold;
    final textColor = isDanger ? Colors.red.shade300 : AppTheme.gold;

    return Container(
      width: double.infinity,
      height: isCompact ? 42 : 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
