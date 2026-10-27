import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'nav_bar.dart';

class SiteFooter extends StatelessWidget {
  /// Scrolls the home page to a section; null on other pages.
  final void Function(String sectionId)? onSelectSection;

  const SiteFooter({super.key, this.onSelectSection});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    final theme = Theme.of(context);
    final p = context.palette;
    final year = DateTime.now().year;
    final isMobile = context.isMobile;

    final brand = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(cv?.name ?? '', style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins')),
        const SizedBox(height: AppSpace.xxs),
        Text(
          cv?.title ?? '',
          style: theme.textTheme.bodyMedium,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cv != null) ...[
              _Social(Icons.mail_outline_rounded, 'Email', 'mailto:${cv.email}', 'email'),
              _Social(Icons.business_center_rounded, 'LinkedIn', cv.linkedin, 'linkedin'),
              _Social(Icons.code_rounded, 'GitHub', cv.github, 'github'),
            ],
          ],
        ),
      ],
    );

    final links = Wrap(
      spacing: AppSpace.xxs,
      runSpacing: AppSpace.xxs,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
      children: [
        for (final item in navItems.where((i) => i.route == null && i.id != 'home'))
          TextButton(
            onPressed: onSelectSection == null ? null : () => onSelectSection!(item.id),
            style: TextButton.styleFrom(foregroundColor: p.inkMuted),
            child: Text(item.label),
          ),
        if (onSelectSection != null)
          TextButton.icon(
            onPressed: () => onSelectSection!('home'),
            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
            label: const Text('Back to top'),
          ),
      ],
    );

    return Column(
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [p.hairline, p.brand.withValues(alpha: 0.5), p.hairline]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
          child: isMobile
              ? Column(children: [brand, const SizedBox(height: AppSpace.md), links])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: brand), Expanded(child: links)],
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.lg),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpace.xs,
            children: [
              Text('© $year ${cv?.name ?? ''}'.trim(), style: theme.textTheme.bodySmall),
              Text('·', style: theme.textTheme.bodySmall),
              Text('Designed & built with Flutter', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Social extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  final String network;

  const _Social(this.icon, this.tooltip, this.url, this.network);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      color: context.palette.brand,
      icon: Icon(icon, size: 20),
      onPressed: url.isEmpty
          ? null
          : () {
              trackEvent('outbound_click', params: {'network': network, 'from': 'footer'});
              launchUrlString(url, webOnlyWindowName: '_blank');
            },
    );
  }
}
