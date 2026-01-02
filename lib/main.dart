// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ⬅️ +++
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/db/app_db.dart';
import 'core/prefs/app_prefs.dart';
import 'core/perf/perf_service.dart'; //  Module Perf
import 'core/theme/app_theme.dart';
import 'ui/pages/root_shell.dart';
import 'ui/pages/onboarding/onboarding_flow.dart';
import 'data/db/daos/user_dao.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

  // Initialisation du service de performance (si flag activé)
  PerfService().init();

  final db = AppDb();
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);

  final widgetService = HomeWidgetService(db);
  await widgetService.initializeWidget();

  await NotificationService().init();
  await BackgroundService().init();
  // DECOMMENTER LIGNE CI-DESSOUS POUR TESTER IMMEDIATEMENT (PUIS RE-COMMENTER)
  // await BackgroundService().triggerImmediateCheck();

  final userDao = UserDao(db);
  await userDao.ensureSingleton();

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

  final home =
      prefs.onboarded
          ? RootShell(db: db)
          : OnboardingFlow(db: db, prefs: prefs);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('en')],
      locale: const Locale('fr'),

      home: home,
    ),
  );
}
