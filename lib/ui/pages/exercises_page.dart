import 'package:flutter/material.dart';
import '../../data/db/app_db.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/exercise_repository.dart';

class ExercisesPage extends StatefulWidget {
  final AppDb db;
  const ExercisesPage({super.key, required this.db});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  late final ExerciseRepository repo;
  String _query = '';

  @override
  void initState() {
    super.initState();
    repo = ExerciseRepository(widget.db);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.scaffold,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Mes Exercices',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(
              hint: 'Rechercher un exercice…',
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<ExerciseData>>(
              stream: repo.watchAll(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Erreur : ${snap.error}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }
                final list =
                    (snap.data ?? [])
                        .where(
                          (e) =>
                              _query.isEmpty ||
                              e.name.toLowerCase().contains(
                                _query.toLowerCase(),
                              ),
                        )
                        .toList();

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun exercice',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ExerciseTile(e: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      cursorColor: AppTheme.gold,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF2B2B2B),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.gold),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseData e;
  const _ExerciseTile({required this.e});

  Color _typeColor(String t) {
    switch (t.toLowerCase()) {
      case 'poly':
        return const Color(0xFFD9BE77);
      case 'iso':
        return const Color(0xFF9EC3FF);
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _ChipInfo(
                          icon: Icons.category_outlined,
                          label: e.type.toUpperCase(),
                          color: _typeColor(e.type),
                        ),
                        _ChipInfo(
                          icon: Icons.speed,
                          label: "Diff ${e.difficulty}",
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          
          Text(
            "DESC: ${e.description ?? 'VIDE (NULL)'}", 
            style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            "ETAPES: ${e.etapes ?? 'VIDE (NULL)'}", 
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
          ),
          // -------------------------------------
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ChipInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
