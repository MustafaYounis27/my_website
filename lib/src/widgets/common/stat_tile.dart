import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';
import 'glass_card.dart';
import 'gradient_text.dart';

/// A number and its label, in a frosted tile. The leading number counts up
/// once on first build ("250K+" counts 0→250 and keeps its "K+" suffix).
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const StatTile({super.key, required this.value, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final match = RegExp(r'^(\d+)(.*)$').firstMatch(value);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final style = theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.1);

    Widget number = GradientText(value, style: style);
    if (match != null && !reduceMotion) {
      final target = int.parse(match.group(1)!);
      final suffix = match.group(2)!;
      number = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target.toDouble()),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => GradientText('${v.round()}$suffix', style: style),
      );
    }

    final iconBox = icon == null
        ? null
        : Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.brandSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: p.brand, size: 20),
          );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: number),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );

    return GlassCard(
      blur: true,
      raised: false,
      padding: const EdgeInsets.all(AppSpace.md),
      // Narrow tiles (two per row on phones) stack the icon above the
      // number so neither gets squeezed.
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (iconBox == null) return text;
          if (constraints.maxWidth < 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [iconBox, const SizedBox(height: AppSpace.sm), text],
            );
          }
          return Row(children: [iconBox, const SizedBox(width: AppSpace.sm), Expanded(child: text)]);
        },
      ),
    );
  }
}
