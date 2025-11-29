import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../theme/app_theme.dart';

class EquipmentPage extends StatefulWidget {
  final AppDb db;
  final List<int> initialEquipmentIds;
  final Future<void> Function(List<int> equipmentIds)? onNext;

  const EquipmentPage({
    super.key,
    required this.db,
    required this.initialEquipmentIds,
    this.onNext,
  });

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  List<EquipmentData> _equipment = [];
  Set<int> _selectedEquipmentIds = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
    _selectedEquipmentIds = widget.initialEquipmentIds.toSet();
  }

  Future<void> _loadEquipment() async {
    try {
      final equipment = await (widget.db.select(widget.db.equipment)).get();
      if (mounted) {
        setState(() {
          _equipment = equipment;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[EQUIPMENT] Erreur chargement: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _toggleEquipment(int id) {
    setState(() {
      if (_selectedEquipmentIds.contains(id)) {
        _selectedEquipmentIds.remove(id);
      } else {
        _selectedEquipmentIds.add(id);
      }
    });
  }

  Future<void> _handleNext() async {
    if (_selectedEquipmentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne au moins un équipement'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final List<int> resultIds = _selectedEquipmentIds.toList();
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
                      'Ton équipement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Sélectionne le matériel à ta disposition',
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
                    : _equipment.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun équipement disponible',
                              style: TextStyle(color: Colors.white60),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: _equipment.length,
                            itemBuilder: (context, index) {
                              final equipment = _equipment[index];
                              final isSelected = _selectedEquipmentIds
                                  .contains(equipment.id);
                              return _equipmentCard(
                                equipment: equipment,
                                isSelected: isSelected,
                                onTap: () => _toggleEquipment(equipment.id),
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
                  icon: const Icon(Icons.check),
                  label: Text(_submitting ? '...' : 'Terminer'),
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

  Widget _equipmentCard({
    required EquipmentData equipment,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gold.withOpacity(0.2) : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.fitness_center,
              color: isSelected ? AppTheme.gold : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              equipment.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppTheme.gold : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
