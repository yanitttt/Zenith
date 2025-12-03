import 'package:drift/drift.dart';

import '../db/app_db.dart';
import '../db/daos/user_dao.dart';

class UserRepository {
  final UserDao _dao;
  UserRepository(AppDb db) : _dao = UserDao(db);

  Future<AppUserData?> current() => _dao.firstUser();


  Future<int> createProfileStrict({
    required String prenom,
    required String nom,
    required DateTime birthDate,
    required String gender,
    required double weight,
    required double height,
    required String level,
    required String metabolism,
  }) async {
    return _dao.transaction(() async {
      await _dao.ensureSingleton();
      final before = await _dao.countUsers();
      if (before > 0) {
        final u = await _dao.firstUser();
        return u!.id;
      }

      final id = await _dao.insertOne(AppUserCompanion(
        prenom: Value(prenom),
        nom: Value(nom),
        birthDate: Value(birthDate),
        gender: Value(gender),
        weight: Value(weight),
        height: Value(height),
        level: Value(level),
        metabolism: Value(metabolism),
      ));

      final after = await _dao.countUsers();
      if (after != before + 1) {
        throw Exception('Aucun profil créé (count $before → $after)');
      }
      return id;
    });
  }
}
