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
      StatTile(value: '${stats.years}+', label: 'Years experience', icon: Icons.workspace_premium_rounded),
      StatTile(value: '${stats.appsShipped}', label: 'Apps shipped', icon: Icons.rocket_launch_rounded),
      if (stats.usersReached != null)
        StatTile(value: stats.usersReached!, label: 'Users reached', icon: Icons.groups_rounded),
      StatTile(value: '${stats.stores}', label: 'Store platforms', icon: Icons.storefront_rounded),
    ];
    final columns = context.isMobile ? 2 : tiles.length;

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
