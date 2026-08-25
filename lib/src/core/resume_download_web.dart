// Web implementation: trigger a real browser download of the static PDF.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'resume_file.dart';

Future<void> downloadResume() async {
  final anchor = html.AnchorElement(href: ResumeFile.webUrl)
    ..download = ResumeFile.downloadName
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> openResumeInNewTab() async {
  html.window.open(ResumeFile.webUrl, '_blank');
}
