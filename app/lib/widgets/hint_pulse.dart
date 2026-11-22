import 'package:flutter/material.dart';

class HintPulse extends StatefulWidget {
  const HintPulse({super.key, required this.color, required this.child});

  static const Duration halfPulseDuration = Duration(milliseconds: 900);
  static const Color deducibleCellColor = Color(0xFFFFD60A);

  final Color color;
  final Widget child;

  @override
  State<HintPulse> createState() => _HintPulseState();
}

class _HintPulseState extends State<HintPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: HintPulse.halfPulseDuration,
  )..repeat(reverse: true);

  late final CurvedAnimation _easedPulse = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _easedPulse.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _easedPulse,
      child: widget.child,
      builder: (context, child) {
        final glowStrength = 0.25 + 0.75 * _easedPulse.value;
        return Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha: glowStrength),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6 * glowStrength),
                blurRadius: 12 * glowStrength,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
