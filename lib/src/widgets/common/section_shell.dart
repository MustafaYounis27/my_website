import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';
import 'reveal.dart';

/// Numbered section heading + content. Replaces the old SectionHeader.
class SectionShell extends StatelessWidget {
  final String index;
  final String label;
  final String title;
  final String subtitle;
  final Widget child;

  const SectionShell({
    super.key,
    required this.index,
    required this.label,
    required this.title,
    this.subtitle = '',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$index — $label', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpace.xs),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(color: p.ink),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSpace.xxs),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: p.inkSubtle)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        child,
      ],
    );
  }
}
