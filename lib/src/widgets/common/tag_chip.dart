import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';

/// The one chip style: skills, technologies, periods.
class TagChip extends StatelessWidget {
  final String label;
  final bool emphasized;

  const TagChip(this.label, {super.key, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized ? null : p.brandSoft,
        gradient: emphasized
            ? LinearGradient(
                colors: p.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: emphasized ? p.onBrand : p.brand,
            ),
      ),
    );
  }
}
