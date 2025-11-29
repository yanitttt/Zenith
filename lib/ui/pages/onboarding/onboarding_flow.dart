import 'package:flutter/material.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../data/db/app_db.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../services/home_widget_service.dart';
import '../root_shell.dart';
import 'profile_basics_page.dart';
import 'metabolism_page.dart' as metabolism_page;
import 'level_page.dart' as level_page;
import 'objectives_page.dart';
import 'equipment_page.dart';
import 'package:drift/drift.dart' as drift;


class OnboardingFlow extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;
  const OnboardingFlow({super.key, required this.db, required this.prefs});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final UserRepository _users;

  String? _prenom;
  String? _nom;
  DateTime? _dob;
  Gender? _gender;
  double? _weight;
  double? _height;
  level_page.FitnessLevel? _level;
  metabolism_page.Metabolism? _metabolism;
  List<int>? _objectiveIds;
  List<int>? _equipmentIds;

  @override
  void initState() {
    super.initState();
    _users = UserRepository(widget.db);
  }

  void _startOnboarding() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          ProfileBasicsPage(
            onNext: ({
              required String prenom,
              required String nom,
              required DateTime birthDate,
              required double weight,
              required double height,
              required Gender gender,
            }) async {
              _prenom = prenom;
              _nom = nom;
              _dob = birthDate;
              _gender = gender;
              _weight = weight;
              _height = height;

              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    metabolism_page.MetabolismPage(
                      initialMetabolism: _metabolism,
                      onBack: () => Navigator.of(context).pop(),
                      onNext: (m) async {
                        _metabolism = m;
                        if (!mounted) return;
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              level_page.LevelPage(
                                initialLevel: _level,
                                onBack: () => Navigator.of(context).pop(),
                                onNext: (l) async {
                                  _level = l;
                                  if (!mounted) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        ObjectivesPage(
                                          db: widget.db,
                                          initialGoalIds: [],  
                                          onNext: (objectiveIds) async {
                                            _objectiveIds = objectiveIds;
                                            if (!mounted) return;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EquipmentPage(
                                                        db: widget.db,
                                                        initialEquipmentIds: [], 
                                                        onNext: (
                                                            equipmentIds) async {
                                                          _equipmentIds =
                                                              equipmentIds;
                                                          await _finish();
                                                        },
                                                      ),
                                                ));
                                          },
                                        ),
                                  ));
                                },
                              ),
                        ));
                      },
                    ),
              ));
            },
          ),
    ));
  }

  Future<void> _finish() async {
    try {
      final prenom = _prenom?.trim() ?? '';
      final nom = _nom?.trim() ?? '';
      final dob = _dob;
      final gender = _gender;
      final weight = _weight;
      final height = _height;
      final level = _level;
      final metabolism = _metabolism;
      final objectiveIds = _objectiveIds;
      final equipmentIds = _equipmentIds;

      if (prenom.isEmpty ||
          nom.isEmpty ||
          dob == null ||
          gender == null ||
          weight == null ||
          height == null ||
          level == null ||
          metabolism == null ||
          objectiveIds == null ||
          objectiveIds.isEmpty ||
          equipmentIds == null ||
          equipmentIds.isEmpty) {
        throw Exception('Champs manquants');
      }

      final id = await _users.createProfileStrict(
        prenom: prenom,
        nom: nom,
        birthDate: dob,
        gender: gender == Gender.femme ? 'female' : 'male',
        weight: weight,
        height: height,
        level: level.name,
        metabolism: metabolism.name,
      );

      // Insérer les objectifs dans user_goal
      for (final objectiveId in objectiveIds) {
        await widget.db.into(widget.db.userGoal).insert(
          UserGoalCompanion(
            userId: drift.Value(id),
            objectiveId: drift.Value(objectiveId),
            weight: const drift.Value(1.0),
          ),
        );
      }

      // Insérer l'équipement dans user_equipment
      for (final equipmentId in equipmentIds) {
        await widget.db.into(widget.db.userEquipment).insert(
          UserEquipmentCompanion(
            userId: drift.Value(id),
            equipmentId: drift.Value(equipmentId),
          ),
        );
      }

      await widget.prefs.setCurrentUserId(id);
      await widget.prefs.setOnboarded(true);

      // Mettre à jour le widget avec les données du profil
      final widgetService = HomeWidgetService(widget.db);
      await widgetService.updateHomeWidget();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RootShell(db: widget.db)),
            (_) => false,
      );
    } catch (e, st) {
      debugPrint('[ONBOARD][ERROR] $e');
      debugPrint(st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Création du profil impossible : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0b0f1a),

      body: Column(
        children: [
          const SizedBox(height: 80),


          const Text(
            "Bienvenue !",
            style: TextStyle(
              color: Color(0xFFD9BE77),
              fontSize: 45,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),


          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/exercises/image.jpg', // ton image
                width: 500,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ), 


          const SizedBox(height: 20),
        ],
      ),

      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _startOnboarding,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD9BE77),
            foregroundColor: const Color(0xFF0b0f1a),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Commencer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}