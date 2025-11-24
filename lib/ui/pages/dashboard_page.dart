import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/bulle/bulle.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/progress/progress_card.dart';
import '../widgets/favorites/favorites_card.dart';
import '../widgets/stats/stats_card.dart';
import '../../services/ImcService.dart';
import '../../ui/pages/admin_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class DashboardPage extends StatefulWidget {
  final AppDb db;
  const DashboardPage({super.key, required this.db});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final UserRepository _userRepo;
  late final ExerciseRepository _exerciseRepo;

  String _userName = "...";
  List<ExerciseData> _randomExercises = [];
  bool _isLoading = true;
  double? _userWeight;
  double? _userHeight;
  double? _userIMC;
  String _todayDate = "";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      Intl.defaultLocale = 'fr_FR';

      final now = DateTime.now();
      final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

      setState(() {
        _todayDate = formatter.format(now);
      });
    });

    _userRepo = UserRepository(widget.db);
    _exerciseRepo = ExerciseRepository(widget.db);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _userRepo.current();
      final prenom = user?.prenom?.trim() ?? "Athlète";

      _userWeight = user?.weight;
      _userHeight = user?.height;

      if (_userWeight != null && _userHeight != null) {
        final calc = IMCcalculator(
          height: _userHeight!,
          weight: _userWeight!,
        );
        final imc = calc.calculateIMC();
        _userIMC = double.parse(imc.toStringAsFixed(2));
      }

      final allExercises = await _exerciseRepo.all();
      allExercises.shuffle();
      final randomExercises = allExercises.take(4).toList();

      if (mounted) {
        setState(() {
          _userName = prenom;
          _randomExercises = randomExercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[DASHBOARD] Erreur: $e');
      if (mounted) {
        setState(() {
          _userName = "Athlète";
          _isLoading = false;
        });
      }
    }
  }

  double? _imc;
  String? _imcCategory;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Container(
//          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//          decoration: BoxDecoration(
          //color: AppTheme.surface,
          //  border: Border.all(color: const Color(0xFF111111), width: 2),
         // ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              /// ---- HEADER ----
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bonjour $_userName !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Prêt pour ta séance ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _todayDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 16),

              /// ---- CONTENU SCROLLABLE ----
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatsBubble(
                            title: "Exercice \n complétés",
                            value: "8",
                            icon: Icons.fitness_center,
                            background: const Color(0xFF0A0F1F),
                            border: Color(0xFFD9BE77), // doré
                          ),

                          StatsBubble(
                            title: "Séances\ncomplétées",
                            value: "2",
                            icon: Icons.sports_gymnastics,
                            background: Color(0xFF2C123A),
                            border: Color(0xFFD9BE77),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatsBubble(
                            title: "Imc",
                            value: _userIMC?.toString() ?? "--",
                            icon: Icons.fitness_center,
                            background: const Color(0xFF0A0F1F),
                            border: Color(0xFFD9BE77), // doré
                          ),

                          StatsBubble(
                            title: "Poids",
                            value: _userWeight != null ? "${_userWeight!.toStringAsFixed(1)} kg" : "--",
                            icon: Icons.sports_gymnastics,
                            background: Color(0xFF2C123A),
                            border: Color(0xFFD9BE77),
                          ),
                        ],
                      ),

                      /// favoris / exercices recommandés


                      const SizedBox(height: 22),

                      /// statistiques

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
