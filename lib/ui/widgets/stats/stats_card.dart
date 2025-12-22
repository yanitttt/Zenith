import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../../data/db/daos/session_dao.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/theme/app_theme.dart';

class StatsCard extends StatefulWidget {
  final AppDb db;
  const StatsCard({super.key, required this.db});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  int _totalSessions = 0;
  int _thisWeekSessions = 0;
  int _totalMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userRepo = UserRepository(widget.db);
      final sessionDao = SessionDao(widget.db);

      final user = await userRepo.current();
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Charger toutes les sessions de l'utilisateur
      final allSessions = await sessionDao.allForUser(user.id);

      // Sessions de cette semaine
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekTimestamp = startOfWeek.millisecondsSinceEpoch ~/ 1000;

      final thisWeekSessions =
          allSessions.where((s) => s.dateTs >= startOfWeekTimestamp).length;

      // Total de minutes
      final totalMinutes = allSessions
          .where((s) => s.durationMin != null)
          .fold<int>(0, (sum, s) => sum + (s.durationMin ?? 0));

      if (mounted) {
        setState(() {
          _totalSessions = allSessions.length;
          _thisWeekSessions = thisWeekSessions;
          _totalMinutes = totalMinutes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[STATS_CARD] Erreur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppTheme.gold, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Tes statistiques",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: AppTheme.gold,
                    strokeWidth: 2,
                  ),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.calendar_today,
                    value: '$_totalSessions',
                    label: 'Séances',
                    color: AppTheme.gold,
                  ),
                  _StatItem(
                    icon: Icons.local_fire_department,
                    value: '$_thisWeekSessions',
                    label: 'Cette semaine',
                    color: AppTheme.error,
                  ),
                  _StatItem(
                    icon: Icons.timer,
                    value: '${(_totalMinutes / 60).toStringAsFixed(0)}h',
                    label: "Temps total",
                    color: AppTheme.success,
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
