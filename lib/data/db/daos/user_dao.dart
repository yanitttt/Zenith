// lib/data/db/daos/user_dao.dart
import 'package:drift/drift.dart';
import '../app_db.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [AppUser, Session])
class UserDao extends DatabaseAccessor<AppDb> with _$UserDaoMixin {
  UserDao(AppDb db) : super(db);

  Future<AppUserData?> find(int id) {
    return (select(appUser)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<AppUserData>> all() {
    return (select(appUser)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
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
}
