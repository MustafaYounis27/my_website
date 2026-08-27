import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/cv_stats.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/reveal.dart';
import 'common/stat_tile.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final stats = CvStats.from(cv);
    final tiles = <Widget>[
      StatTile(value: '${stats.years}+', label: 'Years experience'),
      StatTile(value: '${stats.projects}', label: 'Projects shipped'),
      StatTile(value: '${stats.stores}', label: 'App stores'),
      StatTile(value: '${stats.technologies}', label: 'Technologies'),
    ];
    final columns = context.isMobile ? 2 : 4;

    return Reveal(
      delay: AppMotion.stagger,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpace.sm;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
          );
        },
      ),
    );
  }
}
