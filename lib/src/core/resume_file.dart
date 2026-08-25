import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Single source of truth for the real resume PDF that ships with the site.
class ResumeFile {
  const ResumeFile._();

  /// Bundled asset (used for rendering the preview on non-web platforms).
  static const String assetPath = 'assets/pdf/Mustafa_Younis_Resume.pdf';

  /// Static copy served from `web/`, so the browser can stream/embed it
  /// without downloading the whole asset bundle first.
  static const String webUrl = 'Mustafa_Younis_Resume.pdf';

  /// File name used when the visitor saves it.
  static const String downloadName = 'Mustafa_Younis_Resume.pdf';

  static Uint8List? _cache;

  static Future<Uint8List> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    _cache = bytes;
    return bytes;
  }
}
