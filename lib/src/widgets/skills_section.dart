import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/skill_categories.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'common/tag_chip.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final groups = SkillCategories.group(cv.skills);
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);

    return SectionShell(
      index: '02',
      label: 'SKILLS',
      title: 'What I work with',
      subtitle: 'Grouped by discipline',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpace.md;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < groups.length; i++)
                SizedBox(
                  width: width,
                  child: Reveal(
                    delay: AppMotion.stagger * i,
                    child: _SkillGroupCard(group: groups[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillGroupCard extends StatelessWidget {
  final SkillGroup group;

  const _SkillGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(group.icon, size: 18, color: p.brand),
              const SizedBox(width: AppSpace.xs),
              Expanded(
                child: Text(group.title, style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [for (final skill in group.skills) TagChip(skill)],
          ),
        ],
      ),
    );
  }
}
