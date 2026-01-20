import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../data/db/app_db.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/admin_view_model.dart';
import '../widgets/admin/modern_button.dart';
import '../widgets/training_days_dialog.dart';
import 'edit_user_page.dart';
import 'onboarding/onboarding_flow.dart';
import '../widgets/admin/gamification_profile_widget.dart';

class AdminPage extends StatelessWidget {
  final AppDb db;
  final AppPrefs prefs;

  const AdminPage({super.key, required this.db, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(db: db, prefs: prefs),
      child: const _AdminPageView(),
    );
  }
}

class _AdminPageView extends StatelessWidget {
  const _AdminPageView();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: 8),

              // Rappel inactivité
              _buildCompactRappel(context),

              const SizedBox(height: 8),

              // Dashboard User principal
              Expanded(
                child: StreamBuilder<List<AppUserData>>(
                  stream: vm.usersStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          "Erreur: ${snap.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final users = snap.data ?? [];
                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucun profil",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    // Profil mono-utilisateur
                    final user = users.first;

                    // Mise à jour de la logique métier (Badges, jours)
                    vm.loadTrainingDaysIfNeeded(user.id);
                    vm.loadUserBadgesIfNeeded(user.id);
                    vm.checkRetroactiveBadges(user.id);

                    return _buildUserProfile(context, vm, user);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profil",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4B868),
          ),
        ),
        IconButton(
          tooltip: 'Rafraîchir',
          icon: const Icon(Icons.refresh, color: AppTheme.gold, size: 20),
          onPressed: () async {
            // Vérification forcée des badges
            final vm = context.read<AdminViewModel>();
            final users = await vm.usersStream.first;

            await vm.checkRetroactiveBadges(users.first.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profil mis à jour")),
              );
            }
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Rappel Compact
  // ---------------------------------------------------------------------------
  Widget _buildCompactRappel(BuildContext context) {
    return Builder(
      builder: (context) {
        final vm = context.watch<AdminViewModel>();
        final enabled = vm.prefs.reminderEnabled;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Rappel inactivité",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              // Switch
              SizedBox(
                height: 30,
                child: Switch(
                  value: enabled,
                  activeThumbColor: AppTheme.success,
                  onChanged: (v) {
                    vm.toggleReminder(v);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (enabled) ...[
                const SizedBox(width: 12),
                // Dropdown jours
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: vm.prefs.reminderDays,
                      dropdownColor: AppTheme.scaffold,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.gold,
                        size: 18,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text("3j")),
                        DropdownMenuItem(value: 5, child: Text("5j")),
                        DropdownMenuItem(value: 7, child: Text("7j")),
                        DropdownMenuItem(value: 10, child: Text("10j")),
                      ],
                      onChanged: (v) {
                        if (v != null) vm.updateReminderDays(v);
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // User Profile Dashboard
  // ---------------------------------------------------------------------------
  Widget _buildUserProfile(
    BuildContext context,
    AdminViewModel vm,
    AppUserData u,
  ) {
    return Column(
      children: [
        // Conteneur groupé : User + Stats + Métabolisme
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Fond unifié
              color: const Color(0xFF151525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUserHeaderCompact(context, vm, u),

                Expanded(child: _buildStatsGrid(vm, u)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        const SizedBox(height: 8),

        _buildBottomActions(context, vm, u),

        const SizedBox(height: 16),

        _buildDataManagementSection(context, vm),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context, AdminViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dataset_linked_outlined,
                color: AppTheme.gold,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                "Zone de Sauvegarde",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  icon: Icons.upload_file,
                  label: 'Exporter',
                  isCompact: true,
                  onPressed: () => _showExportOptions(context, vm),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ModernButton(
                  icon: Icons.download,
                  label: 'Importer',
                  isCompact: true,
                  onPressed: () => _confirmAndImport(context, vm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Options d'export : Partage ou Téléchargement local
  void _showExportOptions(BuildContext context, AdminViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151525),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Exporter les données",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.share, color: AppTheme.gold),
                  title: const Text(
                    "Partager le fichier",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Via Mail, Drive, WhatsApp...",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await vm.exportData();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),

                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.save_alt, color: AppTheme.gold),
                  title: const Text(
                    "Enregistrer sur l'appareil",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Dans le dossier Téléchargements",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final path = await vm.exportToDownloads();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sauvegardé : $path"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildUserHeaderCompact(
    BuildContext context,
    AdminViewModel vm,
    AppUserData u,
  ) {
    final genderIcon = vm.getGenderIcon(u.gender);
    final fullName = vm.getFullName(u);
    final infoLabel =
        "${vm.getGenderLabel(u.gender)} • ${vm.getAgeLabel(u.birthDate)}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold,
            ),
            child: Icon(genderIcon, color: const Color(0xFF0F0F1E), size: 24),
          ),
          const SizedBox(width: 12),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Utilisateur' : fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  infoLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
            ),
            child: Text(
              '#${u.id}',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatsGrid(AdminViewModel vm, AppUserData u) {
    final (imcVal, imcCat) = vm.calculateImc(u);
    final hasMetabolism =
        u.metabolism != null && u.metabolism!.trim().isNotEmpty;

    // Définition des cartes
    final cardTaille = _CompactStatRow(
      icon: Icons.height,
      label: 'Taille',
      value: u.height != null ? '${u.height}' : '-',
      unit: 'cm',
      iconSize: 28,
      valueFontSize: 24,
    );

    final cardPoids = _CompactStatRow(
      icon: Icons.monitor_weight,
      label: 'Poids',
      value: u.weight != null ? '${u.weight}' : '-',
      unit: 'kg',
      iconSize: 28,
      valueFontSize: 24,
    );

    final cardImc = _CompactStatRow(
      icon: Icons.analytics_outlined,
      label: 'IMC',
      value: imcVal != null ? '$imcVal' : '-',
      unit: imcCat ?? '',
      isLargeValue: true,
      iconSize: 28,
      valueFontSize: 24,
    );

    final cardNiveau = _CompactStatRow(
      icon: Icons.fitness_center,
      label: 'Niveau',
      value:
          (u.level != null && u.level!.isNotEmpty)
              ? u.level![0].toUpperCase() + u.level!.substring(1)
              : '-',
      unit: '',
      iconSize: 28,
      valueFontSize: 20, // Gestion text-overflow
    );

    final cardMetab =
        hasMetabolism
            ? _CompactStatRow(
              icon: Icons.local_fire_department,
              label: 'Métabolisme',
              value:
                  u.metabolism!.trim().substring(0, 1).toUpperCase() +
                  u.metabolism!.trim().substring(1),
              unit: '',
              // Ajustement taille
              iconSize: 28,
              valueFontSize: 20,
            )
            : null;

    // Carte Gamification (Badges + XP)
    final cardGamification =
        Selector<AdminViewModel, List<GamificationBadgeData>?>(
          selector: (_, vm) => vm.getCachedUserBadges(u.id),
          builder: (context, badges, _) {
            // Widget partagé (mode compact)
            return GamificationProfileWidget(
              user: u,
              badges: badges ?? [],
              isCompact: true,
            );
          },
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cardTaille),
                  const SizedBox(width: 8),
                  Expanded(child: cardPoids),
                ],
              )
              .animate()
              .fade(delay: 200.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
        ),
        Expanded(
          child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cardImc),
                  const SizedBox(width: 8),
                  Expanded(child: cardNiveau),
                ],
              )
              .animate()
              .fade(delay: 300.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
        ),
        Expanded(
          flex: 1,
          child:
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Layout adaptatif : Métabolisme (50%) ou Gamification étendu
                  if (hasMetabolism) ...[
                    Expanded(child: cardMetab!),
                    const SizedBox(width: 8),
                  ],

                  Expanded(child: cardGamification),
                ],
              ).animate().fade(delay: 400.ms, duration: 500.ms).scale(),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    AdminViewModel vm,
    AppUserData u,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Selector<AdminViewModel, List<int>?>(
          selector: (_, vm) => vm.getCachedTrainingDays(u.id),
          builder: (context, days, _) {
            final label =
                days == null
                    ? "Chargement..."
                    : days.isEmpty
                    ? "Cliquez pour définir vos jours"
                    : "Jours : ${vm.getFormattedDays(days)}";
            return SizedBox(
              width: double.infinity,
              child: ModernButton(
                icon: Icons.calendar_today_outlined,
                label: label,
                isCompact: true,
                onPressed:
                    days != null
                        ? () => _showTrainingDaysDialog(context, vm, u.id, days)
                        : null,
              ),
            );
          },
        ),

        const SizedBox(height: 8),

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
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Interaction Helpers
  // ---------------------------------------------------------------------------
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
      final navigator = Navigator.of(context);
      final isCurrentUser = await vm.deleteUser(userId);
      if (isCurrentUser) {
        navigator.pushAndRemoveUntil(
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

  Future<void> _confirmAndImport(
    BuildContext context,
    AdminViewModel vm,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Importer une sauvegarde ?'),
            content: const Text(
              'ATTENTION : Cette action va EFFACER toutes les données actuelles de l\'application pour les remplacer par celles du fichier de sauvegarde/nUne fois l\'import terminé, l\'application redémarrera sur le profil importé.\n\nVoulez-vous continuer ?',
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
                child: const Text('Écraser et Importer'),
              ),
            ],
          ),
    );

    if (ok == true) {
      if (context.mounted) {
        try {
          // Feedback visuel (Loader)
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          final success = await vm.importData();

          if (context.mounted) {
            Navigator.of(context).pop();

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Import effectué avec succès !"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Echec de l'import : $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}

/// Widget local optimisé pour l'affichage paysage dense (Grid)
class _CompactStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isLargeValue;
  final double? valueFontSize;
  final double? iconSize;

  const _CompactStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.isLargeValue = false,
    this.valueFontSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD9BE77).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFD9BE77), size: iconSize ?? 24),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: valueFontSize ?? 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        if (unit.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
