import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import '../core/analytics/analytics.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onContactTap;
  const HeroSection({super.key, required this.onContactTap});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  Widget build(BuildContext context) {
    final cvProvider = context.watch<CVProvider>();
    final cv = cvProvider.cv;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Profile avatar with gradient border
    final avatar = Container(
      width: context.isMobile ? 140 : 180,
      height: context.isMobile ? 140 : 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
        ),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)],
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
        padding: const EdgeInsets.all(8),
        child: ClipOval(
          child: Image.asset(
            'assets/images/cv_image.png',
            fit: BoxFit.cover,
            semanticLabel: 'Profile avatar',
          ),
        ),
      ),
    );

    // Enhanced typography with gradient text for name
    final name = ShaderMask(
      shaderCallback: (bounds) =>
          LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]).createShader(bounds),
      child: Text(
        cv?.name ?? '',
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
      ),
    );

    final title = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        cv?.title ?? '',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
      ),
    );

    final summary = Text(
      cv?.summary ?? '',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
    );

    final buttons = Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        Semantics(
          label: 'Download CV as PDF',
          button: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
              boxShadow: [
                BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.download_rounded),
              onPressed: () {
                trackEvent('download_cv_click', params: {'from': 'hero'});
                Navigator.pushNamed(context, '/resume');
              },
              label: const Text('Download CV', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        Semantics(
          label: 'Scroll to contact section',
          button: true,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            onPressed: widget.onContactTap,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Get In Touch', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [name, const SizedBox(height: 12), title, const SizedBox(height: 24), summary, const SizedBox(height: 32), buttons],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.95)],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: context.isMobile
            ? Column(
                children: [
                  avatar.animate().fadeIn(duration: 800.ms, delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 32),
                  content,
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar.animate().fadeIn(duration: 800.ms, delay: 200.ms).scale(begin: const Offset(0.8, 0.8)).rotate(begin: -0.05),
                  const SizedBox(width: 48),
                  Expanded(child: content),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05),
      ),
    );
  }
}
