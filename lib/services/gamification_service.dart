import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../data/db/app_db.dart';
import 'notification_service.dart';

class GamificationService {
  final AppDb db;

  GamificationService(this.db);

  // --- XP & LEVEL LOGIC ---

  // Formula: Level = sqrt(XP / 50)
  // Inverse: XP needed = 50 * Level^2
  static int calculateLevel(int xp) {
    if (xp < 0) return 1;
    final level = sqrt(xp / 50);
    return max(1, level.floor());
  }

  static int xpForNextLevel(int currentLevel) {
    return 50 * (currentLevel + 1) * (currentLevel + 1);
  }

  static double progressToNextLevel(int xp) {
    final currentLevel = calculateLevel(xp);
    final nextLevelXp = xpForNextLevel(currentLevel);
    final currentLevelBaseXp = 50 * currentLevel * currentLevel;

    final range = nextLevelXp - currentLevelBaseXp;
    final progress = xp - currentLevelBaseXp;

    return (progress / range).clamp(0.0, 1.0);
  }

  static String getTitleForLevel(int level) {
    if (level >= 100) return "Dieu de la Fonte";
    if (level >= 90) return "Demi-Dieu";
    if (level >= 70) return "Titan";
    if (level >= 50) return "Légende";
    if (level >= 40) return "Maître";
    if (level >= 30) return "Vétéran";
    if (level >= 20) return "Guerrier";
    if (level >= 10) return "Apprenti";
    return "Novice"; // Levels 1-9
  }

  /// Awards XP. Returns true if level up.
  Future<bool> awardXp(int userId, int amount) async {
    final user =
        await (db.select(db.appUser)
          ..where((u) => u.id.equals(userId))).getSingle();
    final newXp = (user.xp ?? 0) + amount;
    final newLevel = calculateLevel(newXp);
    final newTitle = getTitleForLevel(newLevel);
    final oldLevel = calculateLevel(user.xp ?? 0);

    await (db.update(db.appUser)..where((u) => u.id.equals(userId))).write(
      AppUserCompanion(
        xp: Value(newXp),
        userLevel: Value(newLevel),
        title: Value(newTitle),
      ),
    );

    return newLevel > oldLevel;
  }

  // --- BADGE LOGIC ---

  /// Ensures DB badge definitions exist (migration safety).
  Future<void> ensureBadgesExist() async {
    Future<void> addBadge(String id, String name, String desc, int xp) async {
      final exists =
          await (db.select(db.gamificationBadge)
            ..where((b) => b.id.equals(id))).getSingleOrNull();
      if (exists == null) {
        await db
            .into(db.gamificationBadge)
            .insert(
              GamificationBadgeCompanion.insert(
                id: id,
                name: name,
                description: desc,
                xpReward: Value(xp),
              ),
            );
      }
    }

    // Default V41 Badges
    await addBadge(
      'first_steps',
      'Premier Pas',
      'Terminer la première séance',
      50,
    );
    await addBadge('early_bird', 'Lève-tôt', 'S\'entraîner avant 8h', 100);
    await addBadge('night_owl', 'Nocturne', 'S\'entraîner après 22h', 100);
    await addBadge(
      'spartan',
      'Spartiate',
      'Faire plus de 300 reps en une séance',
      200,
    );
    await addBadge('marathon', 'Marathonien', 'Séance de plus de 2h', 300);

    // V42 Badges
    await addBadge(
      'sunday_warrior',
      'Guerrier du Dimanche',
      'S\'entraîner le dimanche',
      150,
    );
    await addBadge(
      'hulk',
      'Hulk',
      'Soulever plus de 5 tonnes (volume total)',
      500,
    );
    await addBadge('high_voltage', 'Survolté', 'Intensité moyenne > 8/10', 300);
  }

  /// Retroactive badge check.
  Future<void> checkRetroactiveBadges(int userId) async {
    await ensureBadgesExist();

    // 1. First Steps Badge
    final sessionCount = await (db.select(db.session)
      ..where((s) => s.userId.equals(userId))).get().then((l) => l.length);

    if (sessionCount > 0) {
      final hasBadge =
          await (db.select(db.userBadge)..where(
            (b) => b.userId.equals(userId) & b.badgeId.equals('first_steps'),
          )).getSingleOrNull();
      if (hasBadge == null) {
        // Manually award without re-triggering everything
        await awardXp(userId, 50); // XP for badge
        await db
            .into(db.userBadge)
            .insert(
              UserBadgeCompanion.insert(
                userId: userId,
                badgeId: 'first_steps',
                earnedDateTs: DateTime.now().millisecondsSinceEpoch,
              ),
            );

        await NotificationService().showNotification(
          id: Random().nextInt(100000),
          title: 'Nouveau Badge !',
          body: 'Bravo ! Succès "Premier Pas" débloqué !',
          channelId: NotificationService.badgeChannelId,
        );
      }
    }
  }

  Future<List<String>> checkAndAwardBadges({
    required int userId,
    required SessionData session, // Drift Table Data Class
    required List<SessionExerciseData> exercises, // Drift Table Data Class
  }) async {
    // Ensure badges exist before checking
    await ensureBadgesExist();

    List<String> newBadges = [];

    // Base XP award
    await awardXp(userId, 50);

    // Badge Grant Helper
    Future<void> tryGrant(String badgeId) async {
      final hasBadge =
          await (db.select(db.userBadge)..where(
            (b) => b.userId.equals(userId) & b.badgeId.equals(badgeId),
          )).getSingleOrNull();

      if (hasBadge == null) {
        // Award badge
        final badgeDef =
            await (db.select(db.gamificationBadge)
              ..where((b) => b.id.equals(badgeId))).getSingleOrNull();
        if (badgeDef != null) {
          await db
              .into(db.userBadge)
              .insert(
                UserBadgeCompanion.insert(
                  userId: userId,
                  badgeId: badgeId,
                  earnedDateTs: DateTime.now().millisecondsSinceEpoch,
                ),
              );
          // Grant XP for badge
          await awardXp(userId, badgeDef.xpReward);
          newBadges.add(badgeDef.name);
          debugPrint('[GAMIFICATION] Earned: ${badgeDef.name}');

          await NotificationService().showNotification(
            id: Random().nextInt(100000),
            title: 'Nouveau Badge !',
            body: 'Bravo ! Succès "${badgeDef.name}" débloqué !',
            channelId: NotificationService.badgeChannelId,
          );
        }
      }
    }

    await tryGrant('first_steps');

    final date = DateTime.fromMillisecondsSinceEpoch(session.dateTs * 1000);
    final hour = date.hour;

    // Day of week badges
    if (date.weekday == DateTime.sunday) {
      await tryGrant('sunday_warrior');
    }

    if (hour < 8) {
      await tryGrant('early_bird');
    }

    if (hour >= 22) {
      await tryGrant('night_owl');
    }

    int totalReps = 0;
    double totalVolume = 0;
    double totalRpe = 0;
    int rpeCount = 0;

    for (var ex in exercises) {
      final reps = ex.reps ?? 0;
      final sets = ex.sets ?? 0;
      final load = ex.load ?? 0;
      final rpe = ex.rpe ?? 0;

      totalReps += reps * sets;
      totalVolume += reps * sets * load;

      if (rpe > 0) {
        totalRpe += rpe;
        rpeCount++;
      }
    }

    if (totalReps >= 300) {
      await tryGrant('spartan');
    }

    if (totalVolume >= 5000) {
      await tryGrant('hulk');
    }

    if (rpeCount > 0 && (totalRpe / rpeCount) >= 8.0) {
      await tryGrant('high_voltage');
    }

    // Session duration is in minutes
    if ((session.durationMin ?? 0) > 120) {
      await tryGrant('marathon');
    }

    return newBadges;
  }
}
