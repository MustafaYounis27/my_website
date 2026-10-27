import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import '../models/cv.dart';
import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import 'common/tag_chip.dart';
import 'featured_project_card.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final project = widget.project;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final corners = BorderRadius.circular(AppRadius.md);

    final techs = project.technologies;
    final extra = techs.length - 3;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered && !reduceMotion ? const Offset(0, -0.015) : Offset.zero,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: corners,
            border: Border.all(
              color: _hovered ? p.brand.withValues(alpha: 0.55) : p.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered ? p.gradientStrong.first.withValues(alpha: 0.22) : p.shadow,
                blurRadius: _hovered ? 40 : 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: corners,
              onTap: () => showProjectDetails(context, project),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProjectIcon(project: project, size: 48),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                project.period,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: p.brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: AppMotion.fast,
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hovered ? p.brand : p.brandSoft,
                          ),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 16,
                            color: _hovered ? p.onBrand : p.brand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.md),
                    // Fit as many whole lines as the card has room for, so the
                    // text ellipsizes instead of running under the chips.
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final style = theme.textTheme.bodyMedium!;
                          final lineHeight = style.fontSize! * (style.height ?? 1.2);
                          final lines = (constraints.maxHeight / lineHeight).floor();
                          if (lines < 1) return const SizedBox.shrink();
                          return Text(
                            project.description,
                            style: style,
                            maxLines: lines,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    if (techs.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final tech in techs.take(3)) TagChip(tech),
                          if (extra > 0) TagChip('+$extra'),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Divider(color: p.hairline, height: 1),
                    const SizedBox(height: AppSpace.sm),
                    Row(
                      children: [
                        for (final link in project.allLinks.take(4))
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpace.xs),
                            child: Tooltip(
                              message: FeaturedProjectCard.storeName(link),
                              child: Icon(FeaturedProjectCard.storeIcon(link), size: 16, color: p.inkSubtle),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          'View details',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A project's app icon on a soft tile, or a generic glyph when it has none.
class ProjectIcon extends StatelessWidget {
  final Project project;
  final double size;

  const ProjectIcon({super.key, required this.project, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fallback = Icon(Icons.widgets_rounded, size: size * 0.5, color: p.brand);
    final image = project.image;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.brandSoft,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(color: p.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null && image.isNotEmpty
          ? Image.asset(image, fit: BoxFit.cover, errorBuilder: (context, error, stack) => fallback)
          : fallback,
    );
  }
}

bool _isNetworkUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

/// The project's own screenshots, or the App Store's when it ships none.
Future<List<String>> _screenshotsFor(Project project) async {
  final own = project.screenshots ?? const [];
  if (own.isNotEmpty) return own;
  final apple = project.stores.where((u) => u.contains('apple.com')).firstOrNull;
  final appId = apple == null ? null : RegExp(r'id(\d+)').firstMatch(apple)?.group(1);
  if (appId == null) return const [];
  try {
    final response = await http.get(Uri.parse('https://itunes.apple.com/lookup?id=$appId&entity=software'));
    if (response.statusCode != 200) return const [];
    final results = (jsonDecode(response.body) as Map<String, dynamic>?)?['results'] as List<dynamic>?;
    final first = results?.isNotEmpty == true ? results!.first as Map<String, dynamic>? : null;
    final urls = first?['screenshotUrls'] as List<dynamic>?;
    return urls?.take(10).map((e) => e.toString()).toList() ?? const [];
  } catch (_) {
    return const [];
  }
}

Widget _image(String urlOrPath, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  Widget error(BuildContext context) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: context.palette.brandSoft,
        child: Icon(Icons.broken_image_outlined, color: context.palette.inkSubtle),
      );
  if (_isNetworkUrl(urlOrPath)) {
    return Image.network(
      urlOrPath,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              width: width,
              height: height,
              color: context.palette.brandSoft,
              alignment: Alignment.center,
              child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (context, _, _) => error(context),
    );
  }
  return Image.asset(urlOrPath, fit: fit, width: width, height: height, errorBuilder: (context, _, _) => error(context));
}

/// Full-screen, zoomable view of one screenshot.
void _showImagePreview(BuildContext context, String urlOrPath) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: InteractiveViewer(minScale: 0.5, maxScale: 4, child: _image(urlOrPath, fit: BoxFit.contain)),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              tooltip: 'Close',
              onPressed: () => Navigator.of(ctx).pop(),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Opens the project detail sheet: story, screenshots, stack and links.
/// Opens immediately; App Store screenshots load inside it.
Future<void> showProjectDetails(BuildContext context, Project project) {
  trackEvent('project_open', params: {'project': project.name});
  return showDialog(
    context: context,
    builder: (ctx) => _ProjectDetailsDialog(project: project, screenshots: _screenshotsFor(project)),
  );
}

class _ProjectDetailsDialog extends StatelessWidget {
  final Project project;
  final Future<List<String>> screenshots;

  const _ProjectDetailsDialog({required this.project, required this.screenshots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final size = MediaQuery.sizeOf(context);
    final links = project.allLinks;
    final shotHeight = context.isMobile ? 260.0 : 320.0;

    Widget heading(String text) => Padding(
          padding: const EdgeInsets.only(top: AppSpace.lg, bottom: AppSpace.sm),
          child: Text(text.toUpperCase(), style: theme.textTheme.labelSmall),
        );

    return Dialog(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpace.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: p.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760, maxHeight: size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with a soft brand wash.
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.sm, AppSpace.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p.brandSoft, p.brandSoft.withValues(alpha: 0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProjectIcon(project: project, size: 60),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: AppSpace.xxs),
                        TagChip(project.period),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.description, style: theme.textTheme.bodyLarge),
                    if (project.highlights.isNotEmpty) ...[
                      heading('Case study'),
                      for (final point in project.highlights)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_circle_rounded, size: 18, color: p.brand),
                              ),
                              const SizedBox(width: AppSpace.xs),
                              Expanded(child: Text(point, style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                    ],
                    FutureBuilder<List<String>>(
                      future: screenshots,
                      builder: (context, snap) {
                        final waiting = snap.connectionState != ConnectionState.done;
                        final shots = snap.data ?? const [];
                        if (!waiting && shots.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading('Screenshots'),
                            SizedBox(
                              height: shotHeight,
                              child: waiting
                                  ? const Center(child: CircularProgressIndicator())
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: shots.length,
                                      separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
                                      itemBuilder: (context, i) => Semantics(
                                        button: true,
                                        label: 'Screenshot ${i + 1} of ${shots.length}',
                                        child: GestureDetector(
                                          onTap: () => _showImagePreview(context, shots[i]),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.zoomIn,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppRadius.md),
                                                border: Border.all(color: p.hairline),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: _image(shots[i], fit: BoxFit.contain, height: shotHeight),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (project.technologies.isNotEmpty) ...[
                      heading('Built with'),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [for (final tech in project.technologies) TagChip(tech)],
                      ),
                    ],
                    if (links.isNotEmpty) ...[
                      heading('Get it'),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final s in links)
                            FilledButton.tonalIcon(
                              onPressed: () {
                                trackEvent('project_link_click', params: {
                                  'project': project.name,
                                  'url': s,
                                  'store': FeaturedProjectCard.storeName(s),
                                });
                                launchUrlString(s, webOnlyWindowName: '_blank');
                              },
                              icon: Icon(FeaturedProjectCard.storeIcon(s), size: 16),
                              label: Text(FeaturedProjectCard.storeName(s)),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
