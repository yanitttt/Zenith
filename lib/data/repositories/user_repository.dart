import 'package:drift/drift.dart';

import '../db/app_db.dart';
import '../db/daos/user_dao.dart';

class UserRepository {
  final UserDao _dao;
  UserRepository(AppDb db) : _dao = UserDao(db);

  Future<AppUserData?> current() => _dao.firstUser();

  /// Insère un profil UNIQUEMENT si la table est vide.
  /// Retourne l'id créé ou jette une Exception si rien n'a été inséré.
  Future<int> createProfileStrict({required String prenom, required String nom}) async {
    return _dao.transaction(() async {
      await _dao.ensureSingleton();
      final before = await _dao.countUsers();
      if (before > 0) {
        final u = await _dao.firstUser();
        return u!.id; // déjà un user → on renvoie son id
      }

      final newId = await _dao.insertOne(AppUserCompanion(
        prenom: Value(prenom),
        nom: Value(nom),
      ));

      final after = await _dao.countUsers();
      if (after != before + 1) {
        // rien n’a été ajouté → on annule et on lève une erreur
        throw Exception('Aucun profil créé (count $before → $after)');
      }
      return newId;
    });
  }
}
