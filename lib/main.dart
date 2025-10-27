import 'package:flutter/material.dart';
import 'ui/pages/dashboard_page.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const DashboardPage(),
    );
  }
}
