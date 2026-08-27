import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'featured_project_card.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  static const double _cardHeight = 300;

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null || cv.projects.isEmpty) return const SizedBox.shrink();

    final featured = cv.projects.first;
    final rest = cv.projects.skip(1).toList();
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);

    return SectionShell(
      index: '04',
      label: 'WORK',
      title: 'Selected projects',
      subtitle: 'Tap a card for screenshots and store links',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: FeaturedProjectCard(project: featured)),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = AppSpace.md;
                final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < rest.length; i++)
                      SizedBox(
                        width: width,
                        height: _cardHeight,
                        child: Reveal(
                          delay: AppMotion.stagger * i,
                          child: ProjectCard(project: rest[i]),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
