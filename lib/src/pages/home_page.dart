import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/seo.dart';
import '../core/site.dart';
import '../state/cv_provider.dart';
import '../widgets/about_section.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/back_to_top_button.dart';
import '../widgets/contact_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/nav_bar.dart';
import '../widgets/projects_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/skills_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/testimonials_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  String _currentSection = 'home';
  final _keys = <String, GlobalKey>{
    'home': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'projects': GlobalKey(),
    'contact': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cv = context.watch<CVProvider>().cv;
    if (cv != null) {
      Seo.update(
        title: '${cv.name} - ${cv.title}',
        description: cv.summary,
        imageUrl: Site.ogImage,
        urlPath: Site.page('/'),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    var newSection = 'home';
    for (final entry in _keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= 150) newSection = entry.key;
    }
    if (newSection != _currentSection) {
      setState(() => _currentSection = newSection);
    }
  }

  void _scrollTo(String id) {
    setState(() => _currentSection = id);
    final box = _keys[id]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !_scrollController.hasClients) return;
    // Land the section just below the sticky header instead of under it.
    final position = _scrollController.position;
    final target = id == 'home'
        ? 0.0
        : position.pixels + box.localToGlobal(Offset.zero).dy - SiteHeader.height - AppSpace.md;
    _scrollController.animateTo(
      target.clamp(0.0, position.maxScrollExtent),
      duration: AppMotion.slow,
      curve: AppMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.isMobile ? AppSpace.sectionMobile : AppSpace.section;
    final hasTestimonials = context.watch<CVProvider>().cv?.testimonials.isNotEmpty ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SiteHeader(
        controller: _scrollController,
        onSelectSection: _scrollTo,
        currentSection: _currentSection,
      ),
      floatingActionButton: BackToTopButton(controller: _scrollController),
      body: AuroraBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: CenteredConstrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(key: _keys['home'], height: SiteHeader.height),
                HeroSection(
                  onContactTap: () => _scrollTo('contact'),
                  onWorkTap: () => _scrollTo('projects'),
                  onScrollCueTap: () => _scrollTo('about'),
                ),
                const StatsSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['about']),
                const AboutSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['skills']),
                const SkillsSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['experience']),
                const ExperienceSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['projects']),
                const ProjectsSection(),
                SizedBox(height: gap),
                if (hasTestimonials) ...[
                  const TestimonialsSection(),
                  SizedBox(height: gap),
                ],
                SizedBox(key: _keys['contact']),
                const ContactSection(),
                SizedBox(height: gap),
                SiteFooter(onSelectSection: _scrollTo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
