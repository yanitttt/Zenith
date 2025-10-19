import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // barre de statut visuelle (facultative) : espace
              const SizedBox(height: 12),

              // Illustration
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/illustrations/highfive.svg',
                    width: 220,
                    semanticsLabel: 'Illustration motivation musculation',
                    colorFilter: isDark
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),

              // Titre
              Text.rich(
                TextSpan(
                  text: 'Faire progresser ta musculation,\n',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: theme.colorScheme.onBackground,
                  ),
                  children: [
                    const TextSpan(text: 'c’est '),
                    TextSpan(
                      text: 'plus simple ',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    const TextSpan(text: 'que tu ne le penses !'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Sous-texte
              Text(
                'Inscription en 2 minutes.\nDes recommandations adaptées à tes objectifs.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // CTA principal (seul bouton demandé)
              PrimaryButton(
                label: 'Commencer',
                onPressed: () {
                  // TODO: Naviguer vers l’onboarding ou la création de compte
                  // Navigator.of(context).pushNamed('/onboardingGoals');
                },
              ),

              const SizedBox(height: 16), // marge basse
            ],
          ),
        ),
      ),
    );
  }
}
