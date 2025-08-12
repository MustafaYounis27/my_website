import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../core/seo.dart';
import '../state/cv_provider.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/contact_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _keys = <String, GlobalKey>{
    'home': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'projects': GlobalKey(),
    'contact': GlobalKey(),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cv = context.watch<CVProvider>().cv;
    if (cv != null) {
      Seo.update(
        title: '${cv.name} - ${cv.title}',
        description: cv.summary,
        imageUrl: '/icons/Icon-512.png',
        urlPath: '/',
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(String id) {
    final key = _keys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvLoaded = context.watch<CVProvider>().isLoaded;
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppNav(onSelectSection: _scrollTo),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: CenteredConstrained(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(key: _keys['home']),
              HeroSection(onContactTap: () => _scrollTo('contact')),
              const SizedBox(height: 24),
              SizedBox(key: _keys['about']),
              const AboutSection(),
              const SizedBox(height: 24),
              SizedBox(key: _keys['skills']),
              const SkillsSection(),
              const SizedBox(height: 24),
              SizedBox(key: _keys['experience']),
              const ExperienceSection(),
              const SizedBox(height: 24),
              SizedBox(key: _keys['projects']),
              const ProjectsSection(),
              const SizedBox(height: 24),
              SizedBox(key: _keys['contact']),
              const ContactSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: cvLoaded
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '© ${DateTime.now().year} — Built with Flutter',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : null,
    );
  }
}
