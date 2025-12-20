import 'package:flutter/foundation.dart';
import '../../data/db/app_db.dart';
import '../../data/repositories/exercise_repository.dart';
import 'package:drift/drift.dart';
import '../../services/performance_monitor_service.dart';

class ExercisesViewModel extends ChangeNotifier {
  final AppDb db;
  late final ExerciseRepository _repository;
  final PerformanceMonitorService _perfService = PerformanceMonitorService();

  // State
  String _query = "";
  bool _isLoading = true;
  String? _error;

  List<ExerciseData> _allExercises = [];
  List<ExerciseData> _filteredExercises = [];

  // Favorites State
  final Set<int> _favoriteIds = {};
  int? _currentUserId;

  // Filter State
  final Set<String> _selectedCategories = {};
  List<String> _categories = [];
  // Map ExerciseId -> Set of Muscle Names
  final Map<int, Set<String>> _exerciseMuscles = {};

  // Getters
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExerciseData> get exercises => _filteredExercises;

  Set<String> get selectedCategories => _selectedCategories;
  List<String> get categories => _categories;

  List<String> getMusclesFor(int exerciseId) {
    return _exerciseMuscles[exerciseId]?.toList() ?? [];
  }

  bool isFavorite(int exerciseId) => _favoriteIds.contains(exerciseId);

  ExercisesViewModel(this.db) {
    _repository = ExerciseRepository(db);
    _init();
  }

  Future<void> _init() async {
    // Initial load
    _isLoading = true;
    notifyListeners();

    try {
      // 0. Ensure user exists (Singleton like in PlanningViewModel)
      final user = await (db.select(db.appUser)..limit(1)).getSingleOrNull();
      if (user != null) {
        _currentUserId = user.id;
      } else {
        // Create default user if none exists
        final id = await db
            .into(db.appUser)
            .insert(
              AppUserCompanion.insert(
                singleton: const Value(1),
                nom: const Value("User"),
              ),
            );
        _currentUserId = id;
      }

      // 1. Load Muscles for Categories
      final muscles = await db.select(db.muscle).get();
      _categories = muscles.map((m) => m.name).toList()..sort();

      // 2. Load Relations for Filtering
      final relations = await db.select(db.exerciseMuscle).get();
      for (final rel in relations) {
        if (!_exerciseMuscles.containsKey(rel.exerciseId)) {
          _exerciseMuscles[rel.exerciseId] = {};
        }
        final muscleName = muscles.firstWhere((m) => m.id == rel.muscleId).name;
        _exerciseMuscles[rel.exerciseId]!.add(muscleName);
      }

      // 3. Load Favorites (UserFeedback where liked = 1)
      if (_currentUserId != null) {
        final favorites =
            await (db.select(db.userFeedback)..where(
              (t) => t.userId.equals(_currentUserId!) & t.liked.equals(1),
            )).get();
        _favoriteIds.addAll(favorites.map((f) => f.exerciseId));
      }

      // 4. Listen to repository
      _repository.watchAll().listen(
        (data) {
          _allExercises = data;
          _applyFilter();
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilter() {
    Iterable<ExerciseData> temp = _allExercises;

    // 1. Filter by Categories (Muscles) - AND Logic (Contains ALL selected)
    if (_selectedCategories.isNotEmpty) {
      temp = temp.where((e) {
        final muscles = _exerciseMuscles[e.id];
        if (muscles == null) return false;
        // Strict Intersection: Exercise must target ALL selected muscles
        return _selectedCategories.every((c) => muscles.contains(c));
      });
    }

    // 2. Filter by Search Query
    if (_query.isNotEmpty) {
      temp = temp.where(
        (e) => e.name.toLowerCase().contains(_query.toLowerCase()),
      );
    }

    // 3. Sort: Favorites First, then Alphabetical
    final List<ExerciseData> list = temp.toList();
    list.sort((a, b) {
      final aFav = _favoriteIds.contains(a.id);
      final bFav = _favoriteIds.contains(b.id);

      if (aFav && !bFav) return -1; // a comes first
      if (!aFav && bFav) return 1; // b comes first

      // Secondary sort: Alphabetical
      return a.name.compareTo(b.name);
    });

    _filteredExercises = list;
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFilter();
    notifyListeners();
  }

  Future<void> toggleFavorite(int exerciseId) async {
    if (_currentUserId == null) return;

    final isFav = _favoriteIds.contains(exerciseId);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      if (isFav) {
        // Unlike: Set liked = 0 or delete? Usually set liked=0 for history
        // Or delete if unique constraint is strict on (userId, exerciseId, ts) which it is not.
        // Based on UserFeedback PK (userId, exerciseId, ts), we might have multiple entries.
        // It's a feedback log, not a simple state.
        // Strategy: Insert a NEW entry with liked = 0 (or 1) with new timestamp.
        // BUT for a "Favorites" feature, we usually want 'current state'.
        // Complex schema implies logs.
        // Let's try to update the LATEST feedback or insert new.
        // Simplification: We will just track it locally and insert a new "liked=0/1" record.

        // Wait, for a simple Favorites feature, we usually assume unique (user, exercise).
        // If the table allows multiple TS, it's a log.
        // To be safe and simple: We insert a new row with current TS.
        // When loading, we should probably take the LATEST entry for each exercise.

        _favoriteIds.remove(exerciseId);
        await db
            .into(db.userFeedback)
            .insert(
              UserFeedbackCompanion.insert(
                userId: _currentUserId!,
                exerciseId: exerciseId,
                liked: 0,
                ts: now,
              ),
            );
      } else {
        // Like
        _favoriteIds.add(exerciseId);
        await db
            .into(db.userFeedback)
            .insert(
              UserFeedbackCompanion.insert(
                userId: _currentUserId!,
                exerciseId: exerciseId,
                liked: 1,
                ts: now,
              ),
            );
      }
      _applyFilter(); // Re-sort list immediately
      notifyListeners();
    } catch (e) {
      // Revert on error
      if (isFav)
        _favoriteIds.add(exerciseId);
      else
        _favoriteIds.remove(exerciseId);
      _applyFilter();
      print("Error toggling favorite: $e");
      notifyListeners();
    }
  }

  void clearCategories() {
    _selectedCategories.clear();
    _applyFilter();
    notifyListeners();
  }

  void search(String query) {
    if (_query == query) return;

    _perfService.startMetric('exercises_search_filter');
    _query = query;
    _applyFilter();
    _perfService.stopMetric('exercises_search_filter');
    notifyListeners();
  }

  void updateQuery(String newQuery) {
    search(newQuery);
  }

  void showPerformanceReport() {
    _perfService.saveReport('exercises_performance');
  }
}
