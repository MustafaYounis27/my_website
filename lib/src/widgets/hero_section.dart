import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/resume_download.dart';
import '../state/cv_provider.dart';
import 'common/gradient_text.dart';
import 'common/reveal.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onContactTap;
  final VoidCallback onWorkTap;

  const HeroSection({super.key, required this.onContactTap, required this.onWorkTap});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final p = context.palette;
    final isDesktop = context.isDesktop;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;

    final copy = Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 16, color: p.inkSubtle),
            const SizedBox(width: AppSpace.xxs),
            Text(cv.location, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          cv.name,
          textAlign: textAlign,
          style: isDesktop ? theme.textTheme.displayMedium : theme.textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpace.xs),
        GradientText(
          cv.title,
          textAlign: textAlign,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpace.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(cv.summary, textAlign: textAlign, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _GradientButton(
              icon: Icons.download_rounded,
              label: 'Download CV',
              onPressed: () {
                trackEvent('download_cv_click', params: {'from': 'hero'});
                downloadResume();
              },
            ),
            OutlinedButton.icon(
              onPressed: onWorkTap,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('View my work'),
            ),
            OutlinedButton.icon(
              onPressed: onContactTap,
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text('Get in touch'),
            ),
            _IconLink(
              icon: Icons.business_center_rounded,
              tooltip: 'LinkedIn',
              url: cv.linkedin,
              network: 'linkedin',
            ),
            _IconLink(
              icon: Icons.code_rounded,
              tooltip: 'GitHub',
              url: cv.github,
              network: 'github',
            ),
          ],
        ),
      ],
    );

    final portrait = _Portrait(size: isDesktop ? 260 : 180);

    return Reveal(
      child: isDesktop
          ? Row(
              children: [
                Expanded(flex: 3, child: copy),
                const SizedBox(width: AppSpace.xl),
                Expanded(flex: 2, child: Center(child: portrait)),
              ],
            )
          : Column(children: [portrait, const SizedBox(height: AppSpace.lg), copy]),
    );
  }
}

class _Portrait extends StatelessWidget {
  final double size;

  const _Portrait({required this.size});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.35),
            blurRadius: 42,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl - 3),
        child: Image.asset(
          'assets/images/cv_image.png',
          fit: BoxFit.cover,
          semanticLabel: 'Portrait photo',
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.34),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _IconLink extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  final String network;

  const _IconLink({
    required this.icon,
    required this.tooltip,
    required this.url,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: url.isEmpty
            ? null
            : () {
                trackEvent('outbound_click', params: {'network': network});
                launchUrlString(url, webOnlyWindowName: '_blank');
              },
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          foregroundColor: p.brand,
          side: BorderSide(color: p.hairline),
          padding: const EdgeInsets.all(AppSpace.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
