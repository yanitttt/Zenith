import 'package:flutter/material.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../data/db/app_db.dart';
import '../../../data/repositories/user_repository.dart';
import '../root_shell.dart';
import 'name_page.dart';
import 'dob_page.dart';
import 'gender_page.dart';
import 'weight_page.dart';
import 'height_page.dart';
import 'level_page.dart';
import 'metabolism_page.dart';

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
  FitnessLevel? _level;
  Metabolism? _metabolism;

  @override
  void initState() {
    super.initState();
    _users = UserRepository(widget.db);
  }

  void _goToName() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NamePage(onSubmit: ({required prenom, required nom}) async {
        _prenom = prenom;
        _nom = nom;
        if (!mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DobPage(
            initial: _dob,
            onNext: (d) async {
              _dob = d;
              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GenderPage(
                  initial: _gender,
                  onNext: (g) async {
                    _gender = g;
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => WeightPage(
                        initialWeight: _weight,
                        onNext: (w) async {
                          _weight = w;
                          if (!mounted) return;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => HeightPage(
                              initialHeight: _height,
                              onNext: (h) async {
                                _height = h;
                                if (!mounted) return;
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => LevelPage(
                                    initialLevel: _level,
                                    onNext: (l) async {
                                      _level = l;
                                      if (!mounted) return;
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => MetabolismPage(
                                          initialMetabolism: _metabolism,
                                          onNext: (m) async {
                                            _metabolism = m;
                                            await _finish(); // insertion finale
                                          },
                                          onBack: () => Navigator.of(context).pop(),
                                        ),
                                      ));
                                    },
                                    onBack: () => Navigator.of(context).pop(),
                                  ),
                                ));
                              },
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ));
                        },
                        onBack: () => Navigator.of(context).pop(),
                      ),
                    ));
                  },
                  onBack: () => Navigator.of(context).pop(),
                ),
              ));
            },
            onBack: () => Navigator.of(context).pop(),
          ),
        ));
      }),
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

      if (prenom.isEmpty || nom.isEmpty || dob == null || gender == null ||
          weight == null || height == null || level == null || metabolism == null) {
        throw Exception('Champs manquants');
      }

      final id = await _users.createProfileStrict(
        prenom: prenom,
        nom: nom,
        birthDate: dob,
        gender: gender == Gender.female ? 'female' : 'male',
        weight: weight,
        height: height,
        level: level.name, // 'debutant', 'intermediaire', 'avance'
        metabolism: metabolism.name, // 'rapide', 'lent'
      );

      await widget.prefs.setCurrentUserId(id);
      await widget.prefs.setOnboarded(true);

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
    // Écran de bienvenue -> lance le flow
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          onPressed: _goToName,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          child: const Text('Commencer'),
        ),
      ),
    );
  }
}
