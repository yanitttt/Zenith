import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../theme/app_theme.dart';
import '../../data/repositories/exercise_repository.dart';
import '../widgets/match/exercise_swipe_card.dart';

class MatchPage extends StatefulWidget {
  final AppDb db;
  const MatchPage({super.key, required this.db});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final ExerciseRepository repo;
  final PageController _controller = PageController();

  int _current = 0;

  @override
  void initState() {
    super.initState();
    repo = ExerciseRepository(widget.db);
  }

  void _next() {
    if (!_controller.hasClients) return;
    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _prev() {
    if (!_controller.hasClients) return;
    _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              // Header sombre avec engrenage (comme la maquette)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: const Color(0xFF111111), width: 2),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'MATCHEZ',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.settings, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Liste des cartes (tous les exos)
              Expanded(
                child: StreamBuilder<List<ExerciseData>>(
                  stream: repo.watchAll(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final exercises = snap.data ?? [];
                    if (exercises.isEmpty) {
                      return const Center(
                        child: Text('Aucun exercice', style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return PageView.builder(
                      controller: _controller,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemCount: exercises.length,
                      itemBuilder: (_, i) {
                        final e = exercises[i];
                        return ExerciseSwipeCard(
                          exercise: e,
                          // Image fixe pour l’instant
                          imageProvider: const AssetImage('assets/images/exercises/default.jpg'),
                          onLike: () {
                            // TODO: persister le like si tu veux (UserFeedback)
                            _next();
                          },
                          onDislike: () {
                            // TODO: persister le dislike si tu veux
                            _next();
                          },
                          onUndo: () {
                            _prev();
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Optionnel : petit indicateur (page X/Y)
              const SizedBox(height: 8),
              Text(
                '$_current',
                style: const TextStyle(color: Colors.transparent, fontSize: 1), // discret/placeholder
              ),
            ],
          ),
        ),
      ),
    );
  }
}
