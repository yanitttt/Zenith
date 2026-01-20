import 'package:flutter/material.dart';
import '../../../data/db/app_db.dart';
import '../../../core/theme/app_theme.dart';

class ExerciseSwipeCard extends StatefulWidget {
  final ExerciseData exercise;
  final ImageProvider imageProvider;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onUndo;
  final VoidCallback onSwipeComplete;

  const ExerciseSwipeCard({
    super.key,
    required this.exercise,
    required this.imageProvider,
    required this.onLike,
    required this.onDislike,
    required this.onUndo,
    required this.onSwipeComplete,
  });

  @override
  State<ExerciseSwipeCard> createState() => _ExerciseSwipeCardState();
}

class _ExerciseSwipeCardState extends State<ExerciseSwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isAnimating = false;

  static const double _swipeThreshold = 100.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSwipeComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    setState(() {
      _isDragging = false;
    });

    if (_dragOffset.dx.abs() > _swipeThreshold) {
      _animateSwipe(_dragOffset.dx > 0);
    } else {
      _resetPosition();
    }
  }

  void _resetPosition() {
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  void _animateSwipe(bool isLike) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isLike ? screenWidth * 1.5 : -screenWidth * 1.5;
    final targetY = 50.0;

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(targetX, targetY),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx * 0.0003,
      end: isLike ? 0.3 : -0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (isLike) {
      widget.onLike();
    } else {
      widget.onDislike();
    }

    _controller.forward(from: 0);
  }

  void _handleLikeButton() {
    if (_isAnimating) return;
    _animateSwipe(true);
  }

  void _handleDislikeButton() {
    if (_isAnimating) return;
    _animateSwipe(false);
  }

  String get _longDescription {
    return "Description : Cet exercice fait blabla blabla blabla blabla blabla blabla "
        "blabla blabla blabla blabla blabla blabla blabla blabla blabla blabla.";
  }

  @override
  Widget build(BuildContext context) {
    final offset = _isDragging ? _dragOffset : _offsetAnimation.value;
    final rotation =
        _isDragging ? _dragOffset.dx * 0.0003 : _rotationAnimation.value;
    final scale = _isAnimating ? _scaleAnimation.value : 1.0;

    final likeOpacity =
        (_isDragging || _isAnimating)
            ? (offset.dx > 0
                ? (offset.dx / _swipeThreshold).clamp(0.0, 1.0)
                : 0.0)
            : 0.0;
    final dislikeOpacity =
        (_isDragging || _isAnimating)
            ? (offset.dx < 0
                ? (offset.dx.abs() / _swipeThreshold).clamp(0.0, 1.0)
                : 0.0)
            : 0.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(
                      color: const Color(0xFF111111),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image(
                                  image: widget.imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              if (likeOpacity > 0)
                                Positioned.fill(
                                  child: _SwipeOverlay(
                                    opacity: likeOpacity,
                                    isLike: true,
                                  ),
                                ),

                              if (dislikeOpacity > 0)
                                Positioned.fill(
                                  child: _SwipeOverlay(
                                    opacity: dislikeOpacity,
                                    isLike: false,
                                  ),
                                ),

                              Positioned(
                                top: 14,
                                left: 14,
                                child: _RoundIcon(
                                  icon: Icons.refresh,
                                  onTap: widget.onUndo,
                                ),
                              ),

                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 240,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black87,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 18,
                                right: 18,
                                bottom: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.exercise.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _longDescription,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                left: 36,
                                right: 36,
                                bottom: 18,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _ActionButton(
                                      icon: Icons.close,
                                      iconColor: const Color(0xFFB54135),
                                      onTap: _handleDislikeButton,
                                    ),
                                    _ActionButton(
                                      icon: Icons.favorite_border,
                                      iconColor: const Color(0xFF4E7A57),
                                      onTap: _handleLikeButton,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SwipeOverlay extends StatelessWidget {
  final double opacity;
  final bool isLike;

  const _SwipeOverlay({required this.opacity, required this.isLike});

  @override
  Widget build(BuildContext context) {
    final color =
        isLike
            ? const Color(0xFF4E7A57).withOpacity(opacity * 0.6)
            : const Color(0xFFB54135).withOpacity(opacity * 0.6);
    final icon = isLike ? Icons.favorite : Icons.close;
    final alignment = isLike ? Alignment.topRight : Alignment.topLeft;

    return Container(
      color: color,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IconPatternPainter(
                icon: icon,
                color: Colors.white.withOpacity(opacity * 0.3),
                isLike: isLike,
              ),
            ),
          ),

          Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Transform.rotate(
                angle: isLike ? -0.3 : 0.3,
                child: Icon(
                  icon,
                  size: 120,
                  color: Colors.white.withOpacity(opacity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconPatternPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  final bool isLike;

  _IconPatternPainter({
    required this.icon,
    required this.color,
    required this.isLike,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final iconSize = 60.0;
    final spacing = 100.0;

    for (
      double x = isLike ? size.width - 300 : 0;
      isLike ? x < size.width : x < 300;
      x += spacing
    ) {
      for (double y = 50; y < size.height - 150; y += spacing) {
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            color: color,
          ),
        );
        textPainter.layout();

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(isLike ? -0.2 : 0.2);
        textPainter.paint(canvas, Offset(-iconSize / 2, -iconSize / 2));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 3),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 44,
        child: Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 46, color: iconColor),
        ),
      ),
    );
  }
}
