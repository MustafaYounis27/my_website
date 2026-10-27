import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/cv_stats.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/resume_download.dart';
import '../state/cv_provider.dart';
import 'common/gradient_text.dart';
import 'common/reveal.dart';
import 'nav_bar.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onContactTap;
  final VoidCallback onWorkTap;
  final VoidCallback? onScrollCueTap;

  const HeroSection({
    super.key,
    required this.onContactTap,
    required this.onWorkTap,
    this.onScrollCueTap,
  });

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final p = context.palette;
    final isDesktop = context.isDesktop;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;
    final align = isDesktop ? WrapAlignment.start : WrapAlignment.center;
    final stats = CvStats.from(cv);

    final copy = Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          alignment: align,
          children: [
            if (cv.availability.isNotEmpty) _AvailabilityBadge(text: cv.availability),
            _MetaChip(icon: Icons.place_outlined, text: cv.location),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          "Hi, I'm",
          textAlign: textAlign,
          style: theme.textTheme.titleLarge?.copyWith(color: p.inkMuted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpace.xxs),
        Text(
          cv.name,
          textAlign: textAlign,
          style: (isDesktop
                  ? theme.textTheme.displayLarge
                  : context.isMobile
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.displayMedium)
              ?.copyWith(height: 1.08, letterSpacing: -1.2),
        ),
        const SizedBox(height: AppSpace.sm),
        GradientText(
          cv.title,
          textAlign: textAlign,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpace.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            cv.headline.isNotEmpty ? cv.headline : cv.summary,
            textAlign: textAlign,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.isMobile ? 16 : 18),
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          alignment: align,
          children: [
            _GradientButton(
              icon: Icons.arrow_forward_rounded,
              label: 'View my work',
              onPressed: onWorkTap,
            ),
            OutlinedButton.icon(
              onPressed: () {
                trackEvent('download_cv_click', params: {'from': 'hero'});
                downloadResume();
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download CV'),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: AppSpace.xs,
          alignment: align,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _IconLink(
              icon: Icons.mail_outline_rounded,
              tooltip: 'Get in touch',
              onPressed: onContactTap,
            ),
            _IconLink(
              icon: Icons.business_center_rounded,
              tooltip: 'LinkedIn',
              onPressed: _outbound(cv.linkedin, 'linkedin'),
            ),
            _IconLink(
              icon: Icons.code_rounded,
              tooltip: 'GitHub',
              onPressed: _outbound(cv.github, 'github'),
            ),
          ],
        ),
      ],
    );

    final showcase = _PortraitShowcase(
      size: isDesktop ? 340 : (context.isMobile ? 200 : 260),
      badges: [
        if (stats.usersReached != null)
          _BadgeData(Icons.groups_rounded, stats.usersReached!, 'users reached'),
        _BadgeData(Icons.rocket_launch_rounded, '${stats.appsShipped}', 'apps shipped'),
      ],
      showBadges: !context.isMobile,
    );

    final content = isDesktop
        ? Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: AppSpace.xl),
              Expanded(flex: 5, child: Center(child: showcase)),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: AppSpace.lg),
              showcase,
              const SizedBox(height: AppSpace.xl),
              copy,
            ],
          );

    // On desktop the hero fills the first screen, with a cue to scroll on.
    final screen = MediaQuery.sizeOf(context).height;
    return Reveal(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isDesktop ? math.max(0, screen - SiteHeader.height - 140) : 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
              child: content,
            ),
            if (isDesktop && onScrollCueTap != null) _ScrollCue(onTap: onScrollCueTap!),
          ],
        ),
      ),
    );
  }

  static VoidCallback? _outbound(String url, String network) {
    if (url.isEmpty) return null;
    return () {
      trackEvent('outbound_click', params: {'network': network});
      launchUrlString(url, webOnlyWindowName: '_blank');
    };
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final String text;

  const _AvailabilityBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1F22C55E),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: const Color(0x5522C55E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulseDot(),
          const SizedBox(width: AppSpace.xs),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: p.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "online" dot with a soft expanding halo.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 8 + 6 * t,
                height: 8 + 6 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: green.withValues(alpha: 0.45 * (1 - t)),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: green, shape: BoxShape.circle),
                child: SizedBox(width: 8, height: 8),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 6),
      decoration: BoxDecoration(
        color: p.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: p.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: p.inkSubtle),
          const SizedBox(width: AppSpace.xxs),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String value;
  final String label;

  const _BadgeData(this.icon, this.value, this.label);
}

/// Portrait inside a slowly turning gradient ring, with stat badges that
/// float beside it. Static when the visitor asks for reduced motion.
class _PortraitShowcase extends StatefulWidget {
  final double size;
  final List<_BadgeData> badges;
  final bool showBadges;

  const _PortraitShowcase({required this.size, required this.badges, required this.showBadges});

  @override
  State<_PortraitShowcase> createState() => _PortraitShowcaseState();
}

class _PortraitShowcaseState extends State<_PortraitShowcase> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 14));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = widget.size;
    const ring = 4.0;
    // Badges hang off the portrait's edges; reserve room so they stay inside
    // the layout box instead of overflowing it.
    final inset = widget.showBadges ? 56.0 : 16.0;

    final portrait = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl + 8 - ring),
      child: Image.asset(
        'assets/images/cv_image.jpg',
        width: size - ring * 2,
        height: size - ring * 2,
        fit: BoxFit.cover,
        semanticLabel: 'Portrait photo',
      ),
    );

    return SizedBox(
      width: size + inset * 2,
      height: size + inset * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;
          final bob = math.sin(angle * 4) * 6;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft glow behind everything.
              Container(
                width: size * 0.9,
                height: size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.gradientStrong.first.withValues(alpha: 0.45),
                      blurRadius: size * 0.35,
                      spreadRadius: size * 0.02,
                    ),
                  ],
                ),
              ),
              // Turning gradient ring.
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(ring),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl + 8),
                  gradient: SweepGradient(
                    colors: [...p.gradient, p.gradientStrong.last, ...p.gradient.reversed, p.gradient.first],
                    transform: GradientRotation(angle),
                  ),
                ),
                child: child,
              ),
              if (widget.showBadges && widget.badges.isNotEmpty)
                Positioned(
                  left: 0,
                  top: inset + size * 0.12 + bob,
                  child: _FloatingBadge(data: widget.badges.first),
                ),
              if (widget.showBadges && widget.badges.length > 1)
                Positioned(
                  right: 0,
                  bottom: inset + size * 0.12 - bob,
                  child: _FloatingBadge(data: widget.badges[1]),
                ),
            ],
          );
        },
        child: portrait,
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final _BadgeData data;

  const _FloatingBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpace.xs, AppSpace.xs, AppSpace.md, AppSpace.xs),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.hairline),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: p.gradientStrong),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(data.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpace.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.value,
                style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w700, height: 1.1),
              ),
              Text(data.label, style: theme.textTheme.bodySmall?.copyWith(height: 1.2)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Scroll" hint with a gently bouncing arrow.
class _ScrollCue extends StatefulWidget {
  final VoidCallback onTap;

  const _ScrollCue({required this.onTap});

  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends State<_ScrollCue> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: 'Scroll to about',
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SCROLL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: p.inkSubtle)),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, 6 * Curves.easeInOut.transform(_controller.value)),
                  child: child,
                ),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: p.brand),
              ),
            ],
          ),
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
          colors: p.gradientStrong,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: p.gradientStrong.first.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
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
        // Arrow trails the label, like a "next" action.
        icon: Icon(icon, size: 18),
        iconAlignment: IconAlignment.end,
        label: Text(label),
      ),
    );
  }
}

class _IconLink extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _IconLink({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          foregroundColor: p.brand,
          backgroundColor: p.surfaceGlass,
          side: BorderSide(color: p.hairline),
          padding: const EdgeInsets.all(AppSpace.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
