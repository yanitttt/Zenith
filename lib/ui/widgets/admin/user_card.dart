import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/db/app_db.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../pages/edit_user_page.dart';
import '../../pages/onboarding/onboarding_flow.dart';
import '../../widgets/training_days_dialog.dart';
import '../../theme/app_theme.dart';
import 'stat_card.dart';
import 'modern_button.dart';

class UserCard extends StatelessWidget {
  final AppUserData u;

  const UserCard({super.key, required this.u});

  @override
  Widget build(BuildContext context) {
    // Accès au ViewModel sans écoute directe (sauf via select plus bas)
    final vm = context.read<AdminViewModel>();

    // Préparation des données d'affichage via le ViewModel (helpers)
    final fullName = vm.getFullName(u);
    final ageLabel = vm.getAgeLabel(u.birthDate);
    final genderLabel = vm.getGenderLabel(u.gender);
    final genderIcon = vm.getGenderIcon(u.gender);
    final (imcVal, imcCat) = vm.calculateImc(u);

    // Initialisation du chargement des jours si nécessaire
    // Note: On peut faire ceci dans un addPostFrameCallback ou ici si c'est léger.
    // Pour éviter de déclencher un setState pendant le build, on diffère légèrement
    // ou on utilise un FutureBuilder si on veut être puriste.
    // Ici, vm.loadTrainingDaysIfNeeded vérifie le cache avant de lancer l'async.
    vm.loadTrainingDaysIfNeeded(u.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9BE77), width: 1.5),
      ),
      child: Column(
        children: [
          // En-tête (Avatar + Nom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD9BE77),
                  ),
                  child: Icon(
                    genderIcon,
                    size: 28,
                    color: const Color(0xFF0F0F1E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Utilisateur ${u.id}' : fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$genderLabel$ageLabel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenu (Stats + Actions)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Taille / Poids
                Row(
                  children: [
                    if (u.height != null)
                      Expanded(
                        child: StatCard(
                          icon: Icons.height,
                          label: 'Taille',
                          value: '${u.height}',
                          unit: 'cm',
                        ),
                      ),
                    if (u.height != null && u.weight != null)
                      const SizedBox(width: 8),
                    if (u.weight != null)
                      Expanded(
                        child: StatCard(
                          icon: Icons.monitor_weight,
                          label: 'Poids',
                          value: '${u.weight}',
                          unit: 'kg',
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // IMC / Niveau
                Row(
                  children: [
                    if (imcVal != null)
                      Expanded(
                        child: StatCard(
                          icon: Icons.analytics_outlined,
                          label: 'IMC',
                          value: '$imcVal',
                          unit: imcCat ?? '',
                          isLarge: true,
                        ),
                      ),
                    if (imcVal != null && u.level != null)
                      const SizedBox(width: 8),
                    if (u.level != null)
                      Expanded(
                        child: StatCard(
                          icon: Icons.fitness_center,
                          label: 'Niveau',
                          value: u.level!,
                          unit: '',
                        ),
                      ),
                  ],
                ),

                // Métabolisme
                if (u.metabolism != null &&
                    u.metabolism!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Métabolisme',
                    value: u.metabolism!.trim(),
                    unit: '',
                    isWide: true,
                  ),
                ],

                const SizedBox(height: 12),

                // Boutons d'action (Modifier / Supprimer)
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        icon: Icons.edit_outlined,
                        label: 'Modifier',
                        isCompact: true,
                        onPressed: () => _navigateToEdit(context, vm, u),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ModernButton(
                        icon: Icons.delete_outline,
                        label: 'Supprimer',
                        isCompact: true,
                        isDanger: true,
                        onPressed: () => _confirmAndDelete(context, vm, u.id),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Jours d'entraînement (Observation sélective du cache)
                Selector<AdminViewModel, List<int>?>(
                  selector: (_, vm) => vm.getCachedTrainingDays(u.id),
                  builder: (context, days, _) {
                    final label =
                        days == null
                            ? "Chargement..."
                            : vm.getFormattedDays(days);
                    return ModernButton(
                      icon: Icons.calendar_today_outlined,
                      label: label,
                      isCompact: true,
                      onPressed:
                          days != null
                              ? () => _showTrainingDaysDialog(
                                context,
                                vm,
                                u.id,
                                days,
                              )
                              : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(
    BuildContext context,
    AdminViewModel vm,
    AppUserData user,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => EditProfilePage(
              user: user,
              db: vm.db,
              userDao: vm.userDao,
              goalDao: vm.goalDao,
              equipmentDao: vm.equipmentDao,
            ),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    AdminViewModel vm,
    int userId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer le profil ?'),
            content: const Text(
              'Cette action effacera entièrement votre profil et vos données. '
              'Voulez-vous continuer ?',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppTheme.gold),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (ok == true) {
      // Appel au ViewModel pour la suppression logique
      final isCurrentUser = await vm.deleteUser(userId);

      if (isCurrentUser && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => OnboardingFlow(db: vm.db, prefs: vm.prefs),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _showTrainingDaysDialog(
    BuildContext context,
    AdminViewModel vm,
    int userId,
    List<int> currentDays,
  ) async {
    final result = await showDialog<List<int>>(
      context: context,
      builder:
          (ctx) => TrainingDaysDialog(selectedDays: List.from(currentDays)),
    );

    if (result != null) {
      await vm.updateTrainingDays(userId, result);
    }
  }
}
