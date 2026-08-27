import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';

/// Lifts its child on pointer hover. No-op when reduced motion is requested.
class HoverLift extends StatefulWidget {
  final Widget child;
  final double lift;

  const HoverLift({super.key, required this.child, this.lift = 4});

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? Offset(0, -widget.lift / 100) : Offset.zero,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
