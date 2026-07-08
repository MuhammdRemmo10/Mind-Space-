import 'package:flutter/material.dart';

class AnimatedEntry extends StatelessWidget {
  const AnimatedEntry({
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final int index;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 260 + (index.clamp(0, 8) * 35));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: delay + duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final eased = Curves.easeOutCubic.transform(value.clamp(0, 1));
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - eased)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
