import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../core/seo.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import '../models/cv.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  Future<void> _generateAndDownloadPDF(CV cv) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(cv.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(cv.title, style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 8),
                pw.Text('${cv.location} • ${cv.email} • ${cv.phone}', 
                  style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),
                
                // Summary
                pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(cv.summary, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),
                
                // Education
                pw.Text('Education', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${cv.education.degree} — ${cv.education.university} (${cv.education.period})',
                  style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),
                
                // Skills
                pw.Text('Skills', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: cv.skills.map((skill) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(skill, style: const pw.TextStyle(fontSize: 10)),
                  )).toList(),
                ),
                pw.SizedBox(height: 16),
                
                // Experience
                pw.Text('Experience', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...cv.experience.map((exp) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${exp.role} — ${exp.company} (${exp.period})',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    ...exp.highlights.map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16, bottom: 2),
                      child: pw.Text('• $h', style: const pw.TextStyle(fontSize: 11)),
                    )),
                    pw.SizedBox(height: 8),
                  ],
                )),
                
                // Projects
                pw.Text('Projects', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...cv.projects.map((proj) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${proj.name} (${proj.period})',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text(proj.description, style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 8),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );
    
    // Save and download the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${cv.name.replaceAll(' ', '_')}_Resume.pdf',
    );
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
          if (cv != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                onPressed: () => _generateAndDownloadPDF(cv),
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
