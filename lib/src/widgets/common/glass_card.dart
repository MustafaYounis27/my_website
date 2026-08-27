import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';

/// The one card style in the app: surface, hairline border, radius, shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;
  final bool raised;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.radius = AppRadius.md,
    this.blur = false,
    this.raised = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final corners = BorderRadius.circular(radius);

    Widget body = Padding(padding: padding, child: child);

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: corners, onTap: onTap, child: body),
      );
    }

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: blur ? p.surfaceGlass : p.surface,
        borderRadius: corners,
        border: Border.all(color: p.hairline),
      ),
      child: body,
    );

    surface = ClipRRect(
      borderRadius: corners,
      child: blur
          ? BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: surface)
          : surface,
    );

    if (!raised) return surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: corners,
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 34, offset: const Offset(0, 14))],
      ),
      child: surface,
    );
  }
}
