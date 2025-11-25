import 'package:flutter/material.dart';

class HeaderBanner extends StatelessWidget {
  final String title;
  final bool showSettings;
  const HeaderBanner({
    super.key,
    required this.title,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RightBevelClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 56, 20),
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (showSettings)
              const Positioned(
                right: 10,
                top: 4,
                child: Icon(Icons.settings, color: Colors.white70, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _RightBevelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const bevel = 42.0;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - bevel, 0)
      ..lineTo(size.width, bevel)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
