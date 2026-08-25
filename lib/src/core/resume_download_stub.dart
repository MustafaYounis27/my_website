// Non-web: hand the bundled PDF to the platform share/print sheet.
import 'package:printing/printing.dart';

import 'resume_file.dart';

Future<void> downloadResume() async {
  await Printing.sharePdf(
    bytes: await ResumeFile.load(),
    filename: ResumeFile.downloadName,
  );
}

Future<void> openResumeInNewTab() => downloadResume();
