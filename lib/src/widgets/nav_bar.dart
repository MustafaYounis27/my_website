import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/responsive.dart';

class AppNav extends StatelessWidget {
  final void Function(String sectionId)? onSelectSection; // only used on home page
  final String? currentSection;
  const AppNav({super.key, this.onSelectSection, this.currentSection});

  @override
  Widget build(BuildContext context) {
    final isHome = ModalRoute.of(context)?.settings.name == '/';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    Widget navButton(String label, String sectionOrRoute, {bool isRoute = false, IconData? icon}) {
      final isSelected = currentSection == sectionOrRoute;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isRoute) {
                Navigator.pushNamed(context, sectionOrRoute);
              } else if (isHome && onSelectSection != null) {
                onSelectSection!(sectionOrRoute);
              } else {
                // Not on home and not a dedicated route -> go to home
                Navigator.pushNamed(context, '/');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, duration: 400.ms);
    }

    // Mobile: show compact actions (theme toggle + menu)
    if (isMobile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ThemeToggleButton(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                showDragHandle: true,
                builder: (sheetCtx) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home_rounded),
                          title: const Text('Home'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome) {
                              onSelectSection?.call('home');
                            } else {
                              Navigator.pushNamed(context, '/');
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_rounded),
                          title: const Text('About'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome && onSelectSection != null) {
                              onSelectSection!('about');
                            } else {
                              Navigator.pushNamed(context, '/');
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.code_rounded),
                          title: const Text('Skills'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome && onSelectSection != null) {
                              onSelectSection!('skills');
                            } else {
                              Navigator.pushNamed(context, '/');
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.work_rounded),
                          title: const Text('Experience'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome && onSelectSection != null) {
                              onSelectSection!('experience');
                            } else {
                              Navigator.pushNamed(context, '/');
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.folder_rounded),
                          title: const Text('Projects'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome && onSelectSection != null) {
                              onSelectSection!('projects');
                            } else {
                              Navigator.pushNamed(context, '/projects');
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mail_rounded),
                          title: const Text('Contact'),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            if (isHome && onSelectSection != null) {
                              onSelectSection!('contact');
                            } else {
                              Navigator.pushNamed(context, '/');
                            }
                          },
                        ),
                        const Divider(height: 0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              _ThemeToggleButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1), width: 1),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              navButton('Home', isHome ? 'home' : '/', isRoute: !isHome, icon: Icons.home_rounded),
              navButton('About', 'about', icon: Icons.person_rounded),
              navButton('Skills', 'skills', icon: Icons.code_rounded),
              navButton('Experience', 'experience', icon: Icons.work_rounded),
              // go to dedicated projects page when not on home
              isHome
                  ? navButton('Projects', 'projects', icon: Icons.folder_rounded)
                  : navButton('Projects', '/projects', isRoute: true, icon: Icons.folder_rounded),
              navButton('Contact', 'contact', icon: Icons.mail_rounded),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 24,
                width: 1,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
              const _ThemeToggleButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  const _ThemeToggleButton();

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    // Use effective brightness so the icon/tooltip reflect the actual theme,
    // even when ThemeMode is system.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.indigo.withValues(alpha: 0.2), Colors.purple.withValues(alpha: 0.2)]
              : [Colors.orange.withValues(alpha: 0.2), Colors.yellow.withValues(alpha: 0.2)],
        ),
      ),
      child: IconButton(
        tooltip: 'Toggle ${isDark ? 'light' : 'dark'} theme',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? Colors.yellow : Colors.orange,
          ),
        ),
        onPressed: () {
          _controller.forward(from: 0);
          theme.toggle();
        },
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }
}
