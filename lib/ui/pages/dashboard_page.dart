import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository(widget.db);
    _exerciseRepo = ExerciseRepository(widget.db);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _userRepo.current();
      final prenom = user?.prenom?.trim() ?? "Athlète";
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
      if (mounted) {
        setState(() {
          _userName = "Athlète";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Séance",
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.settings, color: Colors.white, size: 26),
                ],
              ),

              const SizedBox(height: 20),

              // IMC + BMR buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _goldButton("IMC"),
                  const SizedBox(width: 16),
                  _goldButton("BMR"),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  "objectif choisi",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // List of generated exercises
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F1624),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFD9BE77), width: 1.5),
                  ),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.amber))
                      : ListView.builder(
                          itemCount: _randomExercises.length,
                          itemBuilder: (context, index) {
                            final exo = _randomExercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 22,
                                    child: Icon(Icons.fitness_center, color: Colors.black),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      exo.name,
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  Icon(Icons.close, color: Color(0xFFD9BE77), size: 22),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD9BE77),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("Séance finie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Color(0xFFD9BE77), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: Color(0xFFD9BE77), fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
