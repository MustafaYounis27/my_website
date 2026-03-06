import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import '../models/cv.dart';
import '../core/analytics/analytics.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _isHovered
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.02),
                        ],
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(_isHovered ? 0.15 : 0.05),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _isHovered
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showProjectDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: widget.project.image != null && widget.project.image!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        widget.project.image!,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Fallback to icon if image fails to load
                                          return Icon(Icons.apps_rounded, size: 32, color: Theme.of(context).colorScheme.primary);
                                        },
                                      ),
                                    )
                                  : Icon(Icons.apps_rounded, size: 32, color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.project.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    widget.project.period,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Theme.of(context).colorScheme.primary.withOpacity(_isHovered ? 1.0 : 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.project.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.project.technologies.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: widget.project.technologies
                                        .take(4)
                                        .map(
                                          (tech) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 1),
                                            ),
                                            child: Text(
                                              tech,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                if (widget.project.stores.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.project.stores
                                        .take(2)
                                        .map(
                                          (store) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3), width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(_getStoreIcon(store), size: 14, color: Theme.of(context).colorScheme.secondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getStoreName(store),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
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
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
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
              decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
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
            decoration: BoxDecoration(color: theme.colorScheme.errorContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
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
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
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
