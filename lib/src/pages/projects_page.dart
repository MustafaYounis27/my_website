import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/seo.dart';
import '../core/site.dart';
import '../core/responsive.dart';
import '../widgets/nav_bar.dart';
import '../widgets/projects_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/common/aurora_background.dart';
import '../core/design/app_tokens.dart';
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
        imageUrl: Site.ogImage,
        urlPath: Site.page('/projects'),
      );
    }
    return const Scaffold(
      appBar: SiteHeader(),
      body: AuroraBackground(
        child: SingleChildScrollView(
          child: CenteredConstrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpace.xl),
                ProjectsSection(),
                SizedBox(height: AppSpace.section),
                SiteFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
