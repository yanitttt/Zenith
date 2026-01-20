import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../utils/responsive.dart';

class DashboardSkeleton extends StatefulWidget {
  final VoidCallback? onNavigate;

  const DashboardSkeleton({super.key, this.onNavigate});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Skeleton Layout
    final skeletonLayout = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Skeleton (Removed: rendered by parent)

          // Top Cards
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: _buildShimmerBox(
                    height: 100,
                    width: double.infinity,
                    responsive: responsive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShimmerBox(
                    height: 100,
                    width: double.infinity,
                    responsive: responsive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShimmerBox(
                    height: 100,
                    width: double.infinity,
                    responsive: responsive,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.rh(16)),

          // Chart Placeholder
          Expanded(
            flex: 3,
            child: _buildShimmerBox(
              width: double.infinity,
              height: double.infinity,
              responsive: responsive,
            ),
          ),
          SizedBox(height: responsive.rh(16)),

          // Bottom Row
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildShimmerBox(
                    height: double.infinity,
                    width: double.infinity,
                    responsive: responsive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildShimmerBox(
                    height: double.infinity,
                    width: double.infinity,
                    responsive: responsive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Skeleton + CTA Overlay
    return Stack(
      children: [
        // Background (Skeleton)
        Opacity(opacity: 0.3, child: skeletonLayout),

        // CTA Layer
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.rw(32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(responsive.rw(24)),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.gold.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.explore,
                    size: responsive.rsp(48),
                    color: AppTheme.gold,
                  ),
                ),
                SizedBox(height: responsive.rh(24)),

                // Title
                Text(
                  "Explore les exercices",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.rsp(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.rh(12)),

                // Subtitle
                Text(
                  "Ton tableau de bord est vide.\nDécouvre la bibliothèque d'exercices avant de créer ton programme.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: responsive.rsp(16),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: responsive.rh(32)),

                // Navigation Pointer
                GestureDetector(
                  onTap: widget.onNavigate,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.rh(12),
                          horizontal: responsive.rw(16),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.gold),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "C'est par ici",
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: responsive.rsp(16),
                              ),
                            ),
                            SizedBox(width: responsive.rw(8)),
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: AppTheme.gold,
                              size: responsive.rsp(24),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: responsive.rh(8)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.list_alt,
                              color: Colors.black,
                              size: responsive.rsp(18),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Voir les exercices",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: responsive.rsp(14),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required Responsive responsive,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height > 0 ? height : 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              stops: [0.0, 0.5 + 0.5 * _controller.value, 1.0],
            ),
          ),
        );
      },
    );
  }
}
