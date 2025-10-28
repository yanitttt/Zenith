// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/db/app_db.dart';
import 'core/prefs/app_prefs.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/root_shell.dart';
import 'ui/pages/onboarding/onboarding_flow.dart';
import 'data/db/daos/user_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDb();
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);

  // Normalise la table: garde au plus 1 ligne (ne touche pas à des colonnes optionnelles)
  final userDao = UserDao(db);
  await userDao.ensureSingleton();

  // Décision basée sur la BDD
  final count = await userDao.countUsers();
  if (count > 0) {
    final existing = await userDao.firstUser();
    if (existing != null) {
      await prefs.setCurrentUserId(existing.id);
      await prefs.setOnboarded(true);
    } else {
      await prefs.clearCurrentUserId();
      await prefs.setOnboarded(false);
    }
  } else {
    await prefs.clearCurrentUserId();
    await prefs.setOnboarded(false);
  }

  final home = prefs.onboarded ? RootShell(db: db) : OnboardingFlow(db: db, prefs: prefs);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: home,
  ));
}
