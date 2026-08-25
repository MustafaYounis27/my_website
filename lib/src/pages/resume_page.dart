import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/analytics/analytics.dart';
import '../core/resume_download.dart';
import '../core/responsive.dart';
import '../core/seo.dart';
import '../state/cv_provider.dart';
import '../widgets/resume_viewer.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  Future<void> _download(BuildContext context, {required String from}) async {
    trackEvent('download_cv_click', params: {'from': from});
    try {
      await downloadResume();
      trackEvent('cv_pdf_download', params: {'source': 'resume_page'});
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not download the resume. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv != null) {
      Seo.update(
        title: '${cv.name} — Resume',
        description: cv.summary,
        imageUrl: '/icons/Icon-512.png',
        urlPath: '/resume',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download PDF'),
              onPressed: () => _download(context, from: 'resume_page_appbar'),
            ),
          ),
        ],
      ),
      body: CenteredConstrained(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cv?.name ?? 'Mustafa Younis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (cv != null) Text(cv.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const ResumeViewer(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download PDF'),
                    onPressed: () => _download(context, from: 'resume_page_body'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open in new tab'),
                    onPressed: () {
                      trackEvent('cv_pdf_open_tab', params: {'source': 'resume_page'});
                      openResumeInNewTab();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
