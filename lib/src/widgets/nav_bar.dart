import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/theme_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppNav extends StatelessWidget {
  final void Function(String sectionId)? onSelectSection; // only used on home page
  const AppNav({super.key, this.onSelectSection});

  @override
  Widget build(BuildContext context) {
    final isHome = ModalRoute.of(context)?.settings.name == '/';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget navButton(String label, String sectionOrRoute, {bool isRoute = false, IconData? icon}) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isRoute || !isHome || onSelectSection == null) {
                Navigator.pushNamed(context, sectionOrRoute);
              } else {
                onSelectSection!(sectionOrRoute);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, duration: 400.ms);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              navButton('Home', 'home', isRoute: !isHome, icon: Icons.home_rounded),
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
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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

class _ThemeToggleButtonState extends State<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.themeMode == ThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.indigo.withOpacity(0.2),
                  Colors.purple.withOpacity(0.2),
                ]
              : [
                  Colors.orange.withOpacity(0.2),
                  Colors.yellow.withOpacity(0.2),
                ],
        ),
      ),
      child: IconButton(
        tooltip: 'Toggle ${isDark ? 'light' : 'dark'} theme',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
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
    ).animate()
      .fadeIn(duration: 400.ms)
      .scale(begin: const Offset(0.8, 0.8));
  }
}
