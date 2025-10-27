import 'package:flutter/material.dart';
import 'data/db/app_db.dart';
import 'data/db/daos/exercise_dao.dart';
import 'data/db/daos/user_dao.dart';
import 'data/db/daos/session_dao.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb();
  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  final AppDb db;
  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final exerciseDao = ExerciseDao(db);
    final userDao = UserDao(db);
    final sessionDao = SessionDao(db);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Fitness + Drift + DB packagée')),
        body: FutureBuilder<List<ExerciseData>>(
          future: _loadExercises(exerciseDao, userDao),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erreur : ${snapshot.error}', textAlign: TextAlign.center),
                ),
              );
            }
            final exercises = snapshot.data ?? [];
            if (exercises.isEmpty) {
              return const Center(child: Text('Aucun exercice trouvé.'));
            }
            return ListView.separated(
              itemCount: exercises.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = exercises[i];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(e.name),
                  subtitle: Text('type=${e.type}, diff=${e.difficulty}, cardio=${e.cardio}'),
                  dense: true,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<ExerciseData>> _loadExercises(
      ExerciseDao exerciseDao,
      UserDao userDao,
      ) async {
    final all = await exerciseDao.all();

    // Optionnel : suggestions si user #1 existe
    try {
      final u1 = await userDao.find(1);
      if (u1 != null) {
        final sugg = await exerciseDao.suggestForUser(1);
        // ignore: avoid_print
        print('Suggestions for user#1: ${sugg.map((e) => e.name).toList()}');
      }
    } catch (_) {}
    return all;
  }
}
