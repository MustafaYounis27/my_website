import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/cv.dart';

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
                        Text(
                          widget.project.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  void _showProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.project.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.project.period, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(widget.project.description),
              const SizedBox(height: 12),
              if (widget.project.stores.isNotEmpty) ...[
                const Text('Links:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in widget.project.stores)
                      FilledButton.tonalIcon(
                        onPressed: () => launchUrlString(s, webOnlyWindowName: '_blank'),
                        icon: Icon(_getStoreIcon(s), size: 16),
                        label: Text(_getStoreName(s)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}
