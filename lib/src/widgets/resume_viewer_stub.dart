// Non-web: render the bundled PDF pages with the printing package.
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/resume_file.dart';

class ResumeViewer extends StatelessWidget {
  const ResumeViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (_) => ResumeFile.load(),
      useActions: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      padding: EdgeInsets.zero,
    );
  }
}
