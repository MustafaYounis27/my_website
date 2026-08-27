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

class FeaturedProjectCard extends StatelessWidget {
  final Project project;

  const FeaturedProjectCard({super.key, required this.project});

  static String storeName(String url) {
    if (url.contains('apple.com')) return 'App Store';
    if (url.contains('play.google.com')) return 'Play Store';
    if (url.contains('appgallery.huawei.com')) return 'AppGallery';
    if (url.contains('apps.microsoft.com')) return 'Microsoft Store';
    return Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
  }

  static IconData storeIcon(String url) {
    if (url.contains('apple.com')) return Icons.phone_iphone;
    if (url.contains('play.google.com')) return Icons.shop;
    if (url.contains('appgallery.huawei.com')) return Icons.apps;
    if (url.contains('apps.microsoft.com')) return Icons.window;
    return Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    final artwork = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 96,
        height: 96,
        color: p.brandSoft,
        child: project.image != null && project.image!.isNotEmpty
            ? Image.asset(
                project.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    Icon(Icons.apps_rounded, size: 40, color: p.brand),
              )
            : Icon(Icons.apps_rounded, size: 40, color: p.brand),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const TagChip('FEATURED', emphasized: true),
            Text(project.name, style: theme.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpace.xxs),
        Text(
          project.period,
          style: theme.textTheme.bodySmall?.copyWith(
            color: p.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(project.description, style: theme.textTheme.bodyMedium),
        if (project.technologies.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [for (final tech in project.technologies) TagChip(tech)],
          ),
        ],
        if (project.stores.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [
              for (final store in project.stores)
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
      ],
    );

    return HoverLift(
      child: GlassCard(
        child: context.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [artwork, const SizedBox(height: AppSpace.md), details],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  artwork,
                  const SizedBox(width: AppSpace.lg),
                  Expanded(child: details),
                ],
              ),
      ),
    );
  }
}
