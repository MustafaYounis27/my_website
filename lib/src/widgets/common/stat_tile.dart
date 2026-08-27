import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';
import 'glass_card.dart';

/// A number and its label, in a frosted tile.
class StatTile extends StatelessWidget {
  final String value;
  final String label;

  const StatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return GlassCard(
      blur: true,
      raised: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: p.brand,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
