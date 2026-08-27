import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';

/// Paints the canvas and the two radial aurora glows behind page content.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(color: p.canvas),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -1.0),
                  radius: 1.1,
                  colors: [p.auroraPrimary, p.auroraPrimary.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.9, -0.85),
                  radius: 1.0,
                  colors: [p.auroraSecondary, p.auroraSecondary.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
