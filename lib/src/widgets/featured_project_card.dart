import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../models/cv.dart';
import 'common/glass_card.dart';
import 'common/hover_lift.dart';
import 'common/tag_chip.dart';
import 'project_card.dart';

class FeaturedProjectCard extends StatelessWidget {
  final Project project;

  const FeaturedProjectCard({super.key, required this.project});

  static String storeName(String url) {
    if (url.contains('apple.com')) return 'App Store';
    if (url.contains('play.google.com')) return 'Play Store';
    if (url.contains('appgallery.huawei.com')) return 'AppGallery';
    if (url.contains('apps.microsoft.com')) return 'Microsoft Store';
    if (url.contains('pub.dev')) return 'pub.dev';
    if (url.contains('github.com')) return 'GitHub';
    return Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
  }

  static IconData storeIcon(String url) {
    if (url.contains('apple.com')) return Icons.phone_iphone;
    if (url.contains('play.google.com')) return Icons.shop;
    if (url.contains('appgallery.huawei.com')) return Icons.apps;
    if (url.contains('apps.microsoft.com')) return Icons.window;
    if (url.contains('pub.dev')) return Icons.inventory_2_outlined;
    if (url.contains('github.com')) return Icons.code_rounded;
    return Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final shots = project.screenshots ?? const <String>[];
    final showFan = context.isDesktop && shots.length >= 3;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ProjectIcon(project: project, size: 64),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TagChip('FEATURED PROJECT', emphasized: true),
                  const SizedBox(height: AppSpace.xs),
                  Text(project.name, style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          project.period,
          style: theme.textTheme.bodySmall?.copyWith(
            color: p.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(project.description, style: theme.textTheme.bodyLarge),
        for (final point in project.highlights) ...[
          const SizedBox(height: AppSpace.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(Icons.check_circle_rounded, size: 16, color: p.brand),
              ),
              const SizedBox(width: AppSpace.xs),
              Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
            ],
          ),
        ],
        if (project.technologies.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [for (final tech in project.technologies) TagChip(tech)],
          ),
        ],
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: [
            FilledButton.icon(
              onPressed: () => showProjectDetails(context, project),
              icon: const Icon(Icons.photo_library_outlined, size: 16),
              label: const Text('See screenshots'),
            ),
            for (final store in project.allLinks)
              OutlinedButton.icon(
                onPressed: () {
                  trackEvent('project_link_click', params: {
                    'project': project.name,
                    'url': store,
                    'store': storeName(store),
                  });
                  launchUrlString(store, webOnlyWindowName: '_blank');
                },
                icon: Icon(storeIcon(store), size: 16),
                label: Text(storeName(store)),
              ),
          ],
        ),
      ],
    );

    return HoverLift(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: showFan
            ? Row(
                children: [
                  Expanded(flex: 3, child: details),
                  const SizedBox(width: AppSpace.xl),
                  Expanded(
                    flex: 2,
                    child: _ScreenshotFan(
                      shots: shots.take(3).toList(),
                      onTap: () => showProjectDetails(context, project),
                    ),
                  ),
                ],
              )
            : details,
      ),
    );
  }
}

/// Three phone screenshots fanned out like a hand of cards; the centre one
/// sits on top. Spreads a little further on hover.
class _ScreenshotFan extends StatefulWidget {
  final List<String> shots;
  final VoidCallback onTap;

  const _ScreenshotFan({required this.shots, required this.onTap});

  @override
  State<_ScreenshotFan> createState() => _ScreenshotFanState();
}

class _ScreenshotFanState extends State<_ScreenshotFan> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final phoneWidth = (constraints.maxWidth * 0.46).clamp(120.0, 190.0);
            final phoneHeight = phoneWidth * 1.75;
            final spread = _hovered ? 0.13 : 0.09;
            final shift = phoneWidth * (_hovered ? 0.62 : 0.52);

            Widget phone(String path) => Container(
                  width: phoneWidth,
                  height: phoneHeight,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: p.hairline, width: 1.5),
                    boxShadow: [BoxShadow(color: p.shadow, blurRadius: 30, offset: const Offset(0, 16))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(path, fit: BoxFit.cover, alignment: Alignment.topCenter),
                );

            Widget placed(int i, double turns, double dx) => AnimatedContainer(
                  duration: AppMotion.base,
                  curve: AppMotion.standard,
                  transformAlignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..translateByDouble(dx, 0, 0, 1)
                    ..rotateZ(turns),
                  child: phone(widget.shots[i]),
                );

            return SizedBox(
              height: phoneHeight + 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  placed(0, -spread, -shift),
                  placed(2, spread, shift),
                  placed(1, 0, 0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
