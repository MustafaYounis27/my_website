import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/seo.dart';
import '../core/responsive.dart';
import '../widgets/nav_bar.dart';
import '../widgets/projects_section.dart';
import '../state/cv_provider.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv != null) {
      Seo.update(
        title: '${cv.name} — Projects',
        description: 'Selected projects by ${cv.name}',
        imageUrl: '/icons/Icon-512.png',
        urlPath: '/projects',
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Projects'), actions: const [Padding(padding: EdgeInsets.only(right: 8), child: AppNav())]),
      body: const SingleChildScrollView(
        child: CenteredConstrained(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: ProjectsSection())),
      ),
    );
  }
}
