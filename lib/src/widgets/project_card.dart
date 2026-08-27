import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import '../models/cv.dart';
import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import 'common/glass_card.dart';
import 'common/hover_lift.dart';
import 'common/tag_chip.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final project = widget.project;

    return HoverLift(
      child: GlassCard(
        onTap: () => _showProjectDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpace.xs),
                  decoration: BoxDecoration(
                    color: p.brandSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: project.image != null && project.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            project.image!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.apps_rounded, size: 32, color: p.brand),
                          ),
                        )
                      : Icon(Icons.apps_rounded, size: 32, color: p.brand),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                Icon(Icons.arrow_outward_rounded, size: 18, color: p.brand),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.technologies.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final tech in project.technologies.take(4)) TagChip(tech),
                        ],
                      ),
                    ],
                    if (project.stores.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final store in project.stores.take(2))
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStoreIcon(store), size: 14, color: p.inkSubtle),
                                const SizedBox(width: AppSpace.xxs),
                                Text(_getStoreName(store), style: theme.textTheme.bodySmall),
                              ],
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

  String _domain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  IconData _getStoreIcon(String url) {
    if (url.contains('apple.com')) {
      return Icons.phone_iphone; // App Store icon
    } else if (url.contains('play.google.com')) {
      return Icons.shop; // Play Store icon
    } else if (url.contains('appgallery.huawei.com')) {
      return Icons.apps; // AppGallery icon
    } else if (url.contains('apps.microsoft.com')) {
      return Icons.window; // Microsoft Store icon
    }
    return Icons.link; // Default icon
  }

  String _getStoreName(String url) {
    if (url.contains('apple.com')) {
      return 'App Store';
    } else if (url.contains('play.google.com')) {
      return 'Play Store';
    } else if (url.contains('appgallery.huawei.com')) {
      return 'AppGallery';
    } else if (url.contains('apps.microsoft.com')) {
      return 'Microsoft Store';
    }
    return _domain(url);
  }

  static bool _isNetworkUrl(String s) {
    return s.startsWith('http://') || s.startsWith('https://');
  }

  static String? _extractAppleAppId(String storeUrl) {
    final match = RegExp(r'id(\d+)').firstMatch(storeUrl);
    return match?.group(1);
  }

  static Future<List<String>> _fetchAppStoreScreenshots(List<String> storeUrls) async {
    final appleUrls = storeUrls.where((u) => u.contains('apple.com')).toList();
    if (appleUrls.isEmpty) return [];
    final appId = _extractAppleAppId(appleUrls.first);
    if (appId == null) return [];
    try {
      final uri = Uri.parse('https://itunes.apple.com/lookup?id=$appId&entity=software');
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>?;
      final first = results?.isNotEmpty == true ? results!.first as Map<String, dynamic>? : null;
      final urls = first?['screenshotUrls'] as List<dynamic>?;
      if (urls == null) return [];
      return urls.take(10).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Widget _buildScreenshotImage(BuildContext context, String urlOrPath, {VoidCallback? onTap}) {
    const size = 120.0;
    final theme = Theme.of(context);
    Widget imageWidget;
    if (_isNetworkUrl(urlOrPath)) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          urlOrPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha:0.3), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.broken_image_outlined, size: 32, color: theme.colorScheme.error),
            );
          },
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          urlOrPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha:0.3), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.broken_image_outlined, size: 32, color: theme.colorScheme.error),
            );
          },
        ),
      );
    }
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: imageWidget);
    }
    return imageWidget;
  }

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
            GestureDetector(onTap: () => Navigator.of(ctx).pop(), child: _buildPreviewImage(ctx, urlOrPath)),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
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

  Widget _buildPreviewImage(BuildContext context, String urlOrPath) {
    final theme = Theme.of(context);
    if (_isNetworkUrl(urlOrPath)) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          urlOrPath,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha:0.3), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.broken_image_outlined, size: 64, color: theme.colorScheme.error),
            );
          },
        ),
      );
    }
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.asset(
        urlOrPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withValues(alpha:0.3), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.broken_image_outlined, size: 64, color: theme.colorScheme.error),
          );
        },
      ),
    );
  }

  Future<void> _showProjectDialog(BuildContext context) async {
    List<String> screenshotUrls = (widget.project.screenshots ?? []).toList();
    if (screenshotUrls.isEmpty && widget.project.stores.isNotEmpty) {
      screenshotUrls = await _fetchAppStoreScreenshots(widget.project.stores);
      screenshotUrls = screenshotUrls.toList();
    }
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.project.name),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.project.period, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(widget.project.description),
                if (screenshotUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 128,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < screenshotUrls.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _buildScreenshotImage(context, screenshotUrls[i], onTap: () => _showImagePreview(context, screenshotUrls[i])),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (widget.project.technologies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Technologies', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tech in widget.project.technologies)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3), width: 1),
                          ),
                          child: Text(
                            tech,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                    ],
                  ),
                ],
                if (widget.project.stores.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Links', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in widget.project.stores)
                        FilledButton.tonalIcon(
                          onPressed: () {
                            trackEvent('project_link_click', params: {'project': widget.project.name, 'url': s, 'store': _getStoreName(s)});
                            launchUrlString(s, webOnlyWindowName: '_blank');
                          },
                          icon: Icon(_getStoreIcon(s), size: 16),
                          label: Text(_getStoreName(s)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ), // ConstrainedBox
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}
