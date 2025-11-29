import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../theme/app_theme.dart';

class ObjectivesPage extends StatefulWidget {
  final AppDb db;
  final List<int> initialGoalIds;
  final Future<void> Function(List<int> objectiveIds)? onNext;

  const ObjectivesPage({
    super.key,
    required this.db,
    required this.initialGoalIds,
    this.onNext,
  });

  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  List<ObjectiveData> _objectives = [];
  int? _selectedObjectiveId;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadObjectives();
    if (widget.initialGoalIds.isNotEmpty) {
      _selectedObjectiveId = widget.initialGoalIds.first;
    }
  }

  Future<void> _loadObjectives() async {
    try {
      final objectives = await (widget.db.select(widget.db.objective)).get();
      if (mounted) {
        setState(() {
          _objectives = objectives;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[OBJECTIVES] Erreur chargement: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _toggleObjective(int id) {
    setState(() {
      if (_selectedObjectiveId == null) {
        _selectedObjectiveId = id;      
        } else {
          _selectedObjectiveId = id;
      }
    });
  }

  Future<void> _handleNext() async {
    if (_selectedObjectiveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne un objectif'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final List<int> resultIds = [_selectedObjectiveId!];
    if (widget.onNext != null) {
      try {
        await widget.onNext!(resultIds);
      } catch (e) {
        debugPrint('Erreur lors de la sauvegarde onNext: $e');
      }
      } else {
        if (!mounted) return;
      Navigator.pop(context, resultIds);
    }
    if (mounted){
        setState(() => _submitting = false);
        }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Ton objectif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choisis ce que tu veux atteindre en priorité',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.gold,
                        ),
                      )
                    : _objectives.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun objectif disponible',
                              style: TextStyle(color: Colors.white60),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _objectives.length,
                            itemBuilder: (context, index) {
                              final objective = _objectives[index];
                              final isSelected =
                                  _selectedObjectiveId == objective.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _objectiveCard(
                                  objective: objective,
                                  isSelected: isSelected,
                                  onTap: () => _toggleObjective(objective.id),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _handleNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_submitting ? '...' : 'Suivant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _objectiveCard({
    required ObjectiveData objective,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gold.withOpacity(0.2) : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.gold : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objective.name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.gold : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
