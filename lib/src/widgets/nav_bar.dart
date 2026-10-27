import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import '../state/theme_provider.dart';
import 'common/glass_card.dart';

/// One navigation target. Sections scroll the home page; routes push a page.
class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final String? route;

  const NavItem(this.id, this.label, this.icon, {this.route});
}

const navItems = <NavItem>[
  NavItem('home', 'Home', Icons.home_rounded),
  NavItem('about', 'About', Icons.person_rounded),
  NavItem('skills', 'Skills', Icons.code_rounded),
  NavItem('experience', 'Experience', Icons.work_rounded),
  NavItem('projects', 'Projects', Icons.folder_rounded),
  NavItem('resume', 'Resume', Icons.description_rounded, route: '/resume'),
  NavItem('contact', 'Contact', Icons.mail_rounded),
];

/// Below this width the inline links don't fit next to the brand, so the
/// header collapses to a menu button.
const double kInlineNavMinWidth = 1100;

/// Sticky site header: brand on the left, navigation on the right. Frosts and
/// shows a reading-progress line once [controller] has scrolled.
class SiteHeader extends StatelessWidget implements PreferredSizeWidget {
  final ScrollController? controller;
  final void Function(String sectionId)? onSelectSection;
  final String? currentSection;

  const SiteHeader({super.key, this.controller, this.onSelectSection, this.currentSection});

  static const double height = 68;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) return _bar(context, scrolled: true, progress: null);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasPosition = controller.hasClients && controller.position.hasContentDimensions;
        final offset = hasPosition ? controller.offset : 0.0;
        final max = hasPosition ? controller.position.maxScrollExtent : 0.0;
        return _bar(
          context,
          scrolled: offset > 8,
          progress: max > 0 ? (offset / max).clamp(0.0, 1.0) : 0.0,
        );
      },
    );
  }

  Widget _bar(BuildContext context, {required bool scrolled, required double? progress}) {
    final p = context.palette;

    Widget bar = AnimatedContainer(
      duration: AppMotion.fast,
      height: height,
      decoration: BoxDecoration(
        color: scrolled ? p.canvas.withValues(alpha: 0.72) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: scrolled ? p.hairline : Colors.transparent),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.contentMaxWidth + 80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _Brand(onTap: () => _goHome(context)),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  AppNav(onSelectSection: onSelectSection, currentSection: currentSection),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (scrolled) {
      bar = ClipRect(
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: bar),
      );
    }

    return Stack(
      children: [
        bar,
        if (progress != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: p.gradient)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _goHome(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/' && onSelectSection != null) {
      onSelectSection!('home');
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}

class _Brand extends StatelessWidget {
  final VoidCallback onTap;

  const _Brand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final name = context.watch<CVProvider>().cv?.name ?? '';
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    final initials = words.isEmpty ? '' : '${words.first[0]}${words.length > 1 ? words.last[0] : ''}';
    final shortName = words.length > 1 ? '${words.first} ${words.last}' : name;

    return Semantics(
      button: true,
      label: 'Home',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: p.gradientStrong,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                      color: p.gradientStrong.first.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Flexible(
                child: Text(
                  shortName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNav extends StatelessWidget {
  final void Function(String sectionId)? onSelectSection; // only used on home page
  final String? currentSection;
  const AppNav({super.key, this.onSelectSection, this.currentSection});

  void _select(BuildContext context, NavItem item) {
    final isHome = ModalRoute.of(context)?.settings.name == '/';
    if (item.route != null) {
      Navigator.pushNamed(context, item.route!);
    } else if (isHome && onSelectSection != null) {
      onSelectSection!(item.id);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inline = MediaQuery.sizeOf(context).width >= kInlineNavMinWidth;

    if (!inline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ThemeToggleButton(),
          const SizedBox(width: AppSpace.xxs),
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => _openMenu(context),
          ),
        ],
      );
    }

    return GlassCard(
      blur: true,
      radius: AppRadius.pill,
      raised: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs, vertical: AppSpace.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in navItems)
            _NavLink(
              item: item,
              selected: currentSection == item.id,
              onTap: () => _select(context, item),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
            height: 24,
            width: 1,
            color: context.palette.hairline,
          ),
          const _ThemeToggleButton(),
        ],
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetCtx) {
        final p = sheetCtx.palette;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.sm, 0, AppSpace.sm, AppSpace.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in navItems)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    selected: currentSection == item.id,
                    selectedTileColor: p.brandSoft,
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    trailing: item.route != null ? const Icon(Icons.arrow_outward_rounded, size: 18) : null,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _select(context, item);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatefulWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavLink({required this.item, required this.selected, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final active = widget.selected || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        selected: widget.selected,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpace.xs),
            decoration: BoxDecoration(
              color: widget.selected ? p.brandSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              widget.item.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: active ? p.brand : p.inkMuted,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    // Use effective brightness so the icon/tooltip reflect the actual theme,
    // even when ThemeMode is system.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: 'Switch to ${isDark ? 'light' : 'dark'} theme',
      onPressed: theme.toggle,
      icon: AnimatedSwitcher(
        duration: AppMotion.base,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFF59E0B),
        ),
      ),
    );
  }
}
