import 'package:flutter/material.dart';
import '../../../../data/db/app_db.dart';
import '../../../../services/gamification_service.dart';
import '../../../../core/theme/app_theme.dart';

class GamificationProfileWidget extends StatelessWidget {
  final AppUserData user;
  final List<GamificationBadgeData> badges;

  final bool isCompact;

  const GamificationProfileWidget({
    super.key,
    required this.user,
    required this.badges,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView();
    }
    return _buildStandardView();
  }

  Widget _buildCompactView() {
    final currentXp = user.xp ?? 0;
    final progress = GamificationService.progressToNextLevel(currentXp);
    final userLevelId = user.userLevel ?? 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD9BE77).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header: Niveau (Circle) + XP
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.gold, Color(0xFFF9E496)],
                  ),
                ),
                child: Center(
                  child: Text(
                    '$userLevelId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.title ?? 'Novice',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "$currentXp XP",
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: AppTheme.success,
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 8),

          // Badges List (Compact Horizontal)
          Expanded(
            child:
                badges.isEmpty
                    ? const Center(
                      child: Text(
                        "À vous de jouer !",
                        style: TextStyle(fontSize: 10, color: Colors.white30),
                      ),
                    )
                    : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: badges.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        return Tooltip(
                          message: badges[index].description,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppTheme.gold,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardView() {
    final currentXp = user.xp ?? 0;
    final progress = GamificationService.progressToNextLevel(currentXp);
    final userLevel = user.userLevel ?? 1;
    final title = user.title ?? 'Novice';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Level Circle + Text Info
          Row(
            children: [
              // Level Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, Color(0xFFF9E496)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$userLevel',
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'xp: $currentXp',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color:
                  AppTheme.success, // Using success color (green) for progress
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau $userLevel',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                'Niveau ${userLevel + 1}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badges Section
          if (badges.isNotEmpty) ...[
            const Text(
              "Badges Réussis",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((b) => _buildBadgeChip(b)).toList(),
            ),
          ] else
            const Text(
              "Aucun badge pour le moment. Entraînez-vous !",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(GamificationBadgeData badge) {
    return Tooltip(
      message: badge.description,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppTheme.gold, size: 16),
            const SizedBox(width: 6),
            Text(
              badge.name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
