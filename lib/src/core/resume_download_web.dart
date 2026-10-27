// Web implementation: trigger a real browser download of the static PDF.
import 'package:web/web.dart' as web;

import 'resume_file.dart';

Future<void> downloadResume() async {
  final anchor = web.HTMLAnchorElement()
    ..href = ResumeFile.webUrl
    ..download = ResumeFile.downloadName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

Future<void> openResumeInNewTab() async {
  web.window.open(ResumeFile.webUrl, '_blank');
}
