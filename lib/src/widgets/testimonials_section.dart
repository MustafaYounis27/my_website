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

/// Quotes from managers and clients. Renders nothing until `cv.testimonials`
/// has entries, so the section can ship before the quotes are collected.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null || cv.testimonials.isEmpty) return const SizedBox.shrink();

    final columns = context.isDesktop ? 2 : 1;

    return SectionShell(
      index: '05',
      label: 'KIND WORDS',
      title: 'What people say',
      subtitle: 'From managers and clients I have worked with',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpace.md;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < cv.testimonials.length; i++)
                SizedBox(
                  width: width,
                  child: Reveal(
                    delay: AppMotion.stagger * i,
                    child: _TestimonialCard(testimonial: cv.testimonials[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.format_quote_rounded, size: 32, color: p.brand),
          const SizedBox(height: AppSpace.xs),
          Text(testimonial.quote, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpace.md),
          Text(testimonial.author, style: theme.textTheme.titleSmall),
          if (testimonial.role.isNotEmpty)
            Text(testimonial.role, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
