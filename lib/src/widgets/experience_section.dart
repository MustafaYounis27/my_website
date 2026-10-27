import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../models/cv.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'common/tag_chip.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null || cv.experience.isEmpty) return const SizedBox.shrink();

    return SectionShell(
      index: '03',
      label: 'EXPERIENCE',
      title: "Where I've worked",
      subtitle: 'Most recent first',
      child: Column(
        children: [
          for (var i = 0; i < cv.experience.length; i++)
            Reveal(
              delay: AppMotion.stagger * i,
              child: _TimelineEntry(
                experience: cv.experience[i],
                isCurrent: i == 0,
                isLast: i == cv.experience.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final Experience experience;
  final bool isCurrent;
  final bool isLast;

  const _TimelineEntry({
    required this.experience,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    const rail = 34.0;
    const dotSize = 14.0;
    const dotTop = AppSpace.lg;

    // A Stack sized by the card: the rail line and dot are positioned against
    // it, so no intrinsic-height pass is needed. (IntrinsicHeight under-measured
    // text that falls back to another font, e.g. "★", and clipped the card.)
    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: (dotSize - 2) / 2,
            top: dotTop + dotSize + AppSpace.xs,
            bottom: AppSpace.xs,
            child: Container(width: 2, color: p.hairline),
          ),
        Positioned(
          left: 0,
          top: dotTop,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? null : p.inkSubtle,
              gradient: isCurrent ? LinearGradient(colors: p.gradient) : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: p.gradient.first.withValues(alpha: 0.55),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: rail),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.md),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The period chip sits beside the role when there's room
                        // and drops above it on phones. (No LayoutBuilder: this
                        // lives inside IntrinsicHeight, which can't measure one.)
                        Builder(
                          builder: (context) {
                            final header = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  experience.role,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpace.xxs),
                                Text(
                                  '${experience.company} · ${experience.location}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: p.brand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                            final chip = TagChip(
                              experience.period,
                              emphasized: isCurrent,
                            );
                            if (context.isMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  chip,
                                  const SizedBox(height: AppSpace.xs),
                                  header,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: header),
                                const SizedBox(width: AppSpace.xs),
                                chip,
                              ],
                            );
                          },
                        ),
                        if (experience.highlights.isNotEmpty)
                          const SizedBox(height: AppSpace.sm),
                        for (final highlight in experience.highlights)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpace.xxs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 7,
                                    right: AppSpace.xs,
                                  ),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: p.brand,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
