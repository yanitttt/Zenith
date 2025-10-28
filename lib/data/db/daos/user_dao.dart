// lib/data/db/daos/user_dao.dart
import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [AppUser, Session])
class UserDao extends DatabaseAccessor<AppDb> with _$UserDaoMixin {
  UserDao(AppDb db) : super(db);

  Future<AppUserData?> find(int id) =>
      (select(appUser)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<AppUserData?> firstUser() =>
      (select(appUser)..limit(1)).getSingleOrNull();

  Future<int> countUsers() async {
    final row = await customSelect('SELECT COUNT(*) AS c FROM app_user;').getSingle();
    return (row.data['c'] as int?) ?? 0;
  }

  Future<void> ensureSingleton() async {
    await transaction(() async {
      await customStatement('DELETE FROM app_user WHERE id NOT IN (SELECT MIN(id) FROM app_user);');
    });
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table);').get();
    for (final r in rows) {
      if ((r.data['name'] ?? '').toString() == column) return true;
    }
    return false;
  }

  Future<int> insertOne(AppUserCompanion data) => into(appUser).insert(data);
  Future<bool> updateOne(AppUserData u) => update(appUser).replace(u);
  Future<int> deleteById(int id) =>
      (delete(appUser)..where((t) => t.id.equals(id))).go();

  Future<SessionData?> lastSessionForUser(int userId) {
    return (select(session)
      ..where((s) => s.userId.equals(userId))
      ..orderBy([(s) => OrderingTerm.desc(s.dateTs)])
      ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<AppUserData>> watchAllOrdered() {
    final q = select(appUser)
      ..orderBy([
            (t) => OrderingTerm.asc(t.nom),
            (t) => OrderingTerm.asc(t.prenom),
            (t) => OrderingTerm.asc(t.id),
      ]);
    return q.watch();
  }
}


/// Helpers d’affichage sur le modèle AppUser
extension AppUserDataX on AppUserData {
  /// Construit "prenom nom" si possible, sinon utilise les fallbacks.
  String get fullName {
    final p = (prenom ?? '').trim();
    final n = (nom ?? '').trim();
    if (p.isNotEmpty && n.isNotEmpty) return '$p $n';
    if (p.isNotEmpty) return p;
    if (n.isNotEmpty) return n;
    return (nom ?? '').trim(); // fallback legacy
  }
}


