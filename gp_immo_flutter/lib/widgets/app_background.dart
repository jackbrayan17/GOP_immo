import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.sand,
                Color(0xFFF9F1E6),
                Color(0xFFF2EEE6),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _BlurBubble(
            color: AppTheme.gold.withOpacity(0.35),
            size: 240,
          ),
        ),
        Positioned(
          bottom: -160,
          left: -60,
          child: _BlurBubble(
            color: AppTheme.coral.withOpacity(0.2),
            size: 260,
          ),
        ),
      ],
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
