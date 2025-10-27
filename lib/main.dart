import 'package:flutter/material.dart';
import 'data/db/app_db.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/root_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb();
  runApp(App(db: db));
}

class App extends StatelessWidget {
  final AppDb db;
  const App({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: RootShell(db: db),
    );
  }
}
