// lib/ui/pages/onboarding/onboarding_flow.dart
import 'package:flutter/material.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../data/db/app_db.dart';
import '../../../data/repositories/user_repository.dart';
import '../root_shell.dart';
import 'name_page.dart';
import 'welcome_page.dart';

class OnboardingFlow extends StatefulWidget {
  final AppDb db;
  final AppPrefs prefs;
  const OnboardingFlow({super.key, required this.db, required this.prefs});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final UserRepository _users;

  @override
  void initState() {
    super.initState();
    _users = UserRepository(widget.db);
  }

  void _goToName() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NamePage(onSubmit: _finish)),
    );
  }

  Future<void> _finish({required String prenom, required String nom}) async {
    try {
      // 1) tentative d’insertion STRICTE
      final id = await _users.createProfileStrict(prenom: prenom, nom: nom);

      // 2) succès → on persiste et on navigue
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
      // 3) échec → on RESTE sur la page nom/prénom et on affiche une erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Création du profil impossible : $e')),
      );
    }
  }


  Future<void> _logDbState({String tag = ''}) async {
    try {
      // integrity + user_version
      final integrity = await widget.db.integrityCheck();
      final userVersion = await widget.db.pragmaUserVersion();
      debugPrint('[DB][$tag] integrity_check=$integrity user_version=$userVersion');

      // schéma de la table app_user
      final cols = await widget.db.customSelect('PRAGMA table_info(app_user);').get();
      final colList = cols.map((r) => r.data['name']).join(', ');
      debugPrint('[DB][$tag] app_user columns = [$colList]');

      // quelques lignes de contrôle
      final rows = await widget.db.customSelect('SELECT id, prenom, nom FROM app_user LIMIT 5;').get();
      debugPrint('[DB][$tag] first rows app_user = ${rows.map((r) => r.data).toList()}');
    } catch (e, st) {
      debugPrint('[DB][$tag][ERROR] $e');
      debugPrint(st.toString());
    }
  }

  Future<int> _countUsers() async {
    final res = await widget.db.customSelect('SELECT COUNT(*) AS c FROM app_user;').getSingle();
    final c = (res.data['c'] as int?) ?? 0;
    return c;
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) => WelcomePage(onStart: _goToName);
}
