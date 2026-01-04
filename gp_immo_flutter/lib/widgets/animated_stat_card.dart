import 'package:flutter/material.dart';

class AnimatedStatCard extends StatelessWidget {
  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.valueLabel,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _PulseIcon(icon: icon, color: color),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: value),
                    builder: (context, animatedValue, child) {
                      final display = valueLabel ??
                          animatedValue.toStringAsFixed(animatedValue % 1 == 0 ? 0 : 1);
                      return Text(
                        display,
                        style: Theme.of(context).textTheme.titleLarge,
                      );
                    },
                  ),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: widget.color.withOpacity(0.12),
        child: Icon(widget.icon, color: widget.color),
      ),
    );
  }
}
