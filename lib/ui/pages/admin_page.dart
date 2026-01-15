import 'package:flutter/material.dart';
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
              // 1. HEADER (Titre + Refresh)
              _buildHeader(context),

              const SizedBox(height: 8),

              // 2. RAPPEL COMPACT (Redesign prioritaire)
              _buildCompactRappel(context),

              const SizedBox(height: 8),

              // 3. DASHBOARD USER (Contenu principal Expanded)
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

                    // FOCUS SINGLE USER DASHBOARD
                    // On prend le premier utilisateur (scenario Profile standard)
                    final user = users.first;

                    // Trigger logic updates (badges, days training)
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
  // 1. HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Profil",
          style: TextStyle(
            fontSize: 24, // Légèrement réduit pour gagner de place
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4B868),
          ),
        ),
        IconButton(
          tooltip: 'Rafraîchir',
          icon: const Icon(Icons.refresh, color: AppTheme.gold, size: 20),
          onPressed: () async {
            // Force verify badges for current user
            final vm = context.read<AdminViewModel>();
            final users = await vm.usersStream.first;
            // Check for new badges (just in case)
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
  // 2. COMPACT RAPPEL (Redesign Majeur)
  // ---------------------------------------------------------------------------
  Widget _buildCompactRappel(BuildContext context) {
    // Utilisation de Builder pour accéder au context avec Provider/Prefs
    return Builder(
      builder: (context) {
        final vm = context.watch<AdminViewModel>();
        final enabled = vm.prefs.reminderEnabled;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E), // Fond sombre contraste
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
              // Switch compact
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
                // Dropdown très compact
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
  // 3. USER PROFILE DASHBOARD (Unifié)
  // ---------------------------------------------------------------------------
  Widget _buildUserProfile(
    BuildContext context,
    AdminViewModel vm,
    AppUserData u,
  ) {
    return Column(
      children: [
        // CONTENEUR UNIFIÉ (User + Stats + Metabolisme)
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Couleur de fond unifiée (légèrement plus claire ou différente du Scaffold)
              color: const Color(0xFF151525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A. User Info Header
                _buildUserHeaderCompact(context, vm, u),

                // Pas d'espace entre Header et Stats

                // B. Stats Grid + Métabolisme (Expanded pour tout remplir)
                Expanded(child: _buildStatsGrid(vm, u)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // C. Bottom Buttons (Hors du conteneur unifié)
        _buildBottomActions(context, vm, u),
      ],
    );
  }

  // --- 3.A User Info Header ---
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
          // Avatar
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

          // Infos Text
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

          // ID Tag
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
    );
  }

  // --- 3.B Stats Grid (Flex Version pour remplir l'espace) ---
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
      valueFontSize: 20, // Niveau peut être long
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
              // TAILLES RÉDUITEES POUR LE SPLIT 50/50
              iconSize: 28,
              valueFontSize: 20,
            )
            : null;

    // Carte Gamification (Badges + XP)
    final cardGamification =
        Selector<AdminViewModel, List<GamificationBadgeData>?>(
          selector: (_, vm) => vm.getCachedUserBadges(u.id),
          builder: (context, badges, _) {
            // Utilisation du widget partagé en mode compact
            return GamificationProfileWidget(
              user: u,
              badges: badges ?? [],
              isCompact: true,
            );
          },
        );

    // Layout Flex: Column avec Expanded pour forcer le remplissage vertical
    // Ligne 3 partagee : Metabolisme (Left) | Gamification (Right)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ligne 1 : Taille | Poids
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cardTaille),
              const SizedBox(width: 8),
              Expanded(child: cardPoids),
            ],
          ),
        ),
        // Ligne 2 : IMC | Niveau
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cardImc),
              const SizedBox(width: 8),
              Expanded(child: cardNiveau),
            ],
          ),
        ),
        // Ligne 3 : Métabolisme ET Gamification
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Si métabolisme existe, il prend 50%, sinon, on laisse la place pour autre chose ou on met Gamification en full
              if (hasMetabolism) ...[
                Expanded(child: cardMetab!),
                const SizedBox(width: 8),
              ],

              // La carte Gamification prend le reste
              Expanded(child: cardGamification),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3.C Bottom Actions ---
  Widget _buildBottomActions(
    BuildContext context,
    AdminViewModel vm,
    AppUserData u,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Jours entrainement (Row pour être compact)
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

        // Modifier / Supprimer
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
  // INTERACTION HELPERS (Ported from UserCard)
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
        // Centrage horizontal du bloc (Icone + Texte) pour équilibrer l'espace
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icone plus grande possible
          Icon(
            icon,
            color: const Color(0xFFD9BE77),
            size: iconSize ?? 24, // Taille dynamique ou défaut
          ),
          const SizedBox(width: 12),

          // Texte
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Important pour le centrage vertical
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Espace légèrement augmenté
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: valueFontSize ?? 20, // Plus gros (20 vs 16)
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }
}
