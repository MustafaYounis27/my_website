import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:provider/provider.dart';
import '../core/seo.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

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
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
              onPressed: () {
                if (kIsWeb) html.window.print();
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: CenteredConstrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: cv == null
                ? const Text('Loading...')
                : _ResumeContent(cv: cv),
          ),
        ),
      ),
    );
  }
}

class _ResumeContent extends StatelessWidget {
  final dynamic cv;
  const _ResumeContent({required this.cv});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cv.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(cv.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('${cv.location} • ${cv.email} • ${cv.phone}'),
        const SizedBox(height: 16),
        Text('Summary', style: Theme.of(context).textTheme.titleLarge),
        Text(cv.summary),
        const SizedBox(height: 16),
        Text('Education', style: Theme.of(context).textTheme.titleLarge),
        Text('${cv.education.degree} — ${cv.education.university} (${cv.education.period})'),
        const SizedBox(height: 16),
        Text('Skills', style: Theme.of(context).textTheme.titleLarge),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final s in cv.skills) Chip(label: Text(s))]),
        const SizedBox(height: 16),
        Text('Experience', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final e in cv.experience) ...[
          Text('${e.role} — ${e.company} (${e.period})', style: const TextStyle(fontWeight: FontWeight.w600)),
          for (final h in e.highlights) Text('• $h'),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        Text('Projects', style: Theme.of(context).textTheme.titleLarge),
        for (final p in cv.projects) ...[
          Text('${p.name} (${p.period})', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(p.description),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
