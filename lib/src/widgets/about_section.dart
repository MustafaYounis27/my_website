import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final p = context.palette;

    final story = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CardHeading(icon: Icons.person_outline_rounded, title: 'My story'),
          const SizedBox(height: AppSpace.md),
          Text(cv.summary, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    final education = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CardHeading(icon: Icons.school_outlined, title: 'Education'),
          const SizedBox(height: AppSpace.md),
          Text(cv.education.degree, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpace.xxs),
          Text(
            cv.education.university,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: p.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: p.inkSubtle),
              const SizedBox(width: AppSpace.xxs),
              Expanded(
                child: Text(
                  '${cv.education.period} · ${cv.education.location}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return SectionShell(
      index: '01',
      label: 'ABOUT',
      title: 'About me',
      subtitle: 'Who I am and where I studied',
      child: Reveal(
        child: context.isDesktop
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: story),
                    const SizedBox(width: AppSpace.md),
                    Expanded(flex: 2, child: education),
                  ],
                ),
              )
            : Column(children: [story, const SizedBox(height: AppSpace.md), education]),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.xs),
          decoration: BoxDecoration(
            color: p.brandSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: p.brand),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      ],
    );
  }
}
