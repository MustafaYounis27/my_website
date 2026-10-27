import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';

/// Floating "back to top" button that fades in once the page is scrolled
/// past the first screen.
class BackToTopButton extends StatelessWidget {
  final ScrollController controller;

  const BackToTopButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visible = controller.hasClients && controller.offset > 800;
        return AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 0.4),
          duration: AppMotion.base,
          curve: AppMotion.standard,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: AppMotion.base,
            child: IgnorePointer(
              ignoring: !visible,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: p.gradientStrong,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: p.gradientStrong.first.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: 'Back to top',
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_upward_rounded),
                  onPressed: () => controller.animateTo(
                    0,
                    duration: AppMotion.slow,
                    curve: AppMotion.standard,
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
