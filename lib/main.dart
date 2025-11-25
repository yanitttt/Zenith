// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ⬅️ +++
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/db/app_db.dart';
import 'core/prefs/app_prefs.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/root_shell.dart';
import 'ui/pages/onboarding/onboarding_flow.dart';
import 'data/db/daos/user_dao.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

  final db = AppDb();
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);

  await initializeDateFormatting('fr_FR', null);

  // Initialiser le widget avec les données
  final widgetService = HomeWidgetService(db);
  await widgetService.initializeWidget();
  
  // Initialiser le Service de Notifications
  await NotificationService().init();

  // Garde au plus 1 ligne dans app_user
  final userDao = UserDao(db);
  await userDao.ensureSingleton();

  // Décision basée sur la BDD (source de vérité)
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

  final home = prefs.onboarded
      ? RootShell(db: db)
      : OnboardingFlow(db: db, prefs: prefs);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,

    // ⬇️ Localisations nécessaires au DatePicker & co.
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('fr'),
      Locale('en'),
    ],
    locale: const Locale('fr'), // optionnel: force l'UI en français

    home: home,
  ));
}
