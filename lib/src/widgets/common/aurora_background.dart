import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';

/// Paints the canvas and the two radial aurora glows behind page content.
/// On pointer devices a soft spotlight follows the cursor.
class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> {
  // Only the spotlight layer listens, so moving the mouse never rebuilds the page.
  final _pointer = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final child = widget.child;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: reduceMotion ? null : (e) => _pointer.value = e.localPosition,
      onExit: (_) => _pointer.value = null,
      child: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, -1.0),
                    radius: 1.1,
                    colors: [
                      p.auroraPrimary,
                      p.auroraPrimary.withValues(alpha: 0),
                    ],
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
                    colors: [
                      p.auroraSecondary,
                      p.auroraSecondary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<Offset?>(
                  valueListenable: _pointer,
                  builder: (context, pos, _) {
                    if (pos == null) return const SizedBox.shrink();
                    return CustomPaint(
                      painter: _SpotlightPainter(pos, p.auroraPrimary),
                    );
                  },
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final Color color;

  _SpotlightPainter(this.center, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 420.0;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.center != center || old.color != color;
}
