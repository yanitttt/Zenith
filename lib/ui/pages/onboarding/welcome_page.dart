import 'package:flutter/material.dart';
import 'package:recommandation_mobile/core/theme/app_theme.dart';
import '../../utils/responsive.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback? onImport;
  const WelcomePage({super.key, required this.onStart, this.onImport});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Phase 1 : Entrée (1000ms - Plus lent)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Phase 2 : Respiration (1.0s, boucle plus dynamique)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade : 0.0 -> 1.0
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    // Slide : Du bas (Offset(0, 1.0)) vers sa position (Offset.zero)
    // Plus de distance pour une entrée plus marquée
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    // Scale : 1.0 -> 1.1 (Plus grand)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Démarrage de la séquence d'animation
    _startAnimations();
  }

  void _startAnimations() async {
    // Délai initial de 800ms pour laisser le temps à l'utilisateur de se poser
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      await _entranceController.forward();
      // Une fois l'entrée finie, on lance la respiration
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.surface, // Bleu légèrement plus clair en haut
              AppTheme.scaffold, // Bleu nuit profond en bas
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;

            return Stack(
              children: [
                // Glow doré d'ambiance derrière l'image (subtil)
                Positioned(
                  top: h * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: w * 0.8,
                      height: w * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.gold.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Espace flexible haut
                    const Spacer(flex: 1),

                    // --- SECTION IMAGE HERO (Flex 4) ---
                    Expanded(
                      flex: 4,
                      child: ShaderMask(
                        // Masque Radial : Le centre est visible (noir de l'image),
                        // les bords deviennent transparents pour laisser voir le bleu du fond.
                        shaderCallback: (rect) {
                          return const RadialGradient(
                            center: Alignment.center,
                            radius: 0.7, // Ajuster pour ne pas couper le perso
                            colors: [
                              Colors.black, // Visible
                              Colors.transparent, // Transparent
                            ],
                            stops: [0.5, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ShaderMask(
                          // Masque Linéaire : Fondre le haut de l'image pour éviter la barre noire
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                              stops: [0.0, 0.2], // 20% du haut en fondu
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/exercises/acceuil1.png',
                            width: w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),

                    // --- SECTION TEXTE (Flex 2) ---
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ZÉNITH',
                              style: Theme.of(
                                context,
                              ).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: responsive.rsp(48),
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Atteignez votre apogée",
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                                fontSize: responsive.rsp(18),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Espace avant le bouton
                    const Spacer(flex: 1),

                    // --- SECTION BOUTON (Bottom) ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              height: responsive.rh(56),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.gold,
                                  foregroundColor: Colors.black,
                                  elevation: 4,
                                  shadowColor: AppTheme.gold.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: widget.onStart,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'COMMENCER',
                                      style: TextStyle(
                                        fontSize: responsive.rsp(18),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(Icons.arrow_forward_rounded, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (widget.onImport != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: TextButton.icon(
                          onPressed: widget.onImport,
                          icon: const Icon(
                            Icons.restore,
                            color: Colors.white54,
                            size: 20,
                          ),
                          label: const Text(
                            "Restaurer une sauvegarde",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white54,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
