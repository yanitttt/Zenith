import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/db/app_db.dart';
import '../../core/theme/app_theme.dart';
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
  List<ExerciseData> _allExercises = [];
  List<ExerciseData> _cardStack = [];
  final List<ExerciseData> _history = [];
  final _random = Random();
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    repo = ExerciseRepository(widget.db);
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      debugPrint('[MATCH] Début du chargement des exercices...');
      final exercises = await repo.all();
      debugPrint('[MATCH] Exercices chargés: ${exercises.length}');

      if (!mounted) return;

      if (exercises.isEmpty) {
        debugPrint('[MATCH] Aucun exercice dans la base de données');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Aucun exercice trouvé dans la base de données';
        });
        return;
      }

      debugPrint('[MATCH] Génération de la pile de cartes...');

      _allExercises = exercises;
      _allExercises.shuffle(_random);
      final stack = _generateInitialStack();
      debugPrint('[MATCH] Pile générée avec ${stack.length} cartes');

      setState(() {
        _cardStack = stack;
        _isLoading = false;
      });
      debugPrint(
        '[MATCH] État mis à jour, isLoading=$_isLoading, cardStack=${_cardStack.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('[MATCH] Erreur: $e');
      debugPrint('[MATCH] StackTrace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  List<ExerciseData> _generateInitialStack() {
    debugPrint(
      '[MATCH] _generateInitialStack called, _allExercises.length=${_allExercises.length}',
    );
    if (_allExercises.isEmpty) {
      debugPrint('[MATCH] _allExercises is empty, returning empty stack');
      return [];
    }

    final shuffled = List.of(_allExercises)..shuffle(_random);
    return shuffled.take(3).toList();
  }

  void _onSwipe() {
    setState(() {
      _currentIndex++;

      if (_cardStack.isNotEmpty) {
        final removed = _cardStack.removeAt(0);
        _history.add(removed);
        _allExercises.remove(removed);
      }
      if (_allExercises.isNotEmpty) {
        _cardStack.add(_allExercises.removeAt(0));
      }
    });
  }

  void _onUndo() {
    if (_history.isEmpty) return;

    setState(() {
      final last = _history.removeLast();
      _cardStack.insert(0, last);
      _currentIndex = (_currentIndex - 1).clamp(0, 999999);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '[MATCH] Building widget, isLoading=$_isLoading, errorMessage=$_errorMessage, cardStack.length=${_cardStack.length}',
    );
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
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

              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.gold,
                          ),
                        )
                        : _errorMessage != null
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.gold,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : _cardStack.isEmpty
                        ? const Center(
                          child: Text(
                            'Aucun exercice disponible',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : LayoutBuilder(
                          builder: (context, constraints) {
                            debugPrint(
                              '[MATCH] Building Stack with ${_cardStack.length} cards',
                            );
                            debugPrint(
                              '[MATCH] Available space: ${constraints.maxWidth}x${constraints.maxHeight}',
                            );

                            if (_cardStack.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Pile vide',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_cardStack.length > 1)
                                  Positioned(
                                    top: 8,
                                    left: 4,
                                    right: 4,
                                    bottom: 0,
                                    child: IgnorePointer(
                                      child: Transform.scale(
                                        scale: 0.95,
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: ExerciseSwipeCard(
                                            key: ValueKey(
                                              '${_cardStack[1].id}_${_currentIndex + 1}',
                                            ),
                                            exercise: _cardStack[1],
                                            imageProvider: const AssetImage(
                                              'assets/images/exercises/default.jpg',
                                            ),
                                            onLike: () {},
                                            onDislike: () {},
                                            onUndo: () {},
                                            onSwipeComplete: () {},
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ExerciseSwipeCard(
                                  key: ValueKey(
                                    '${_cardStack[0].id}_$_currentIndex',
                                  ),
                                  exercise: _cardStack[0],
                                  imageProvider: const AssetImage(
                                    'assets/images/exercises/default.jpg',
                                  ),
                                  onLike: () {
                                    debugPrint(
                                      '[MATCH] onLike called for exercise ${_cardStack[0].id}',
                                    );
                                  },
                                  onDislike: () {
                                    debugPrint(
                                      '[MATCH] onDislike called for exercise ${_cardStack[0].id}',
                                    );
                                  },
                                  onUndo: _onUndo,
                                  onSwipeComplete: () {
                                    debugPrint(
                                      '[MATCH] onSwipeComplete called',
                                    );
                                    _onSwipe();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
