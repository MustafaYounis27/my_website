import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class Seo {
  static void update({required String title, required String description, String? imageUrl, String? urlPath}) {
    if (!kIsWeb) return;
    html.document.title = title;

    _setMeta('name', 'description', description);
    _setMeta('property', 'og:title', title);
    _setMeta('property', 'og:description', description);
    if (imageUrl != null) _setMeta('property', 'og:image', imageUrl);
    if (urlPath != null) _setMeta('property', 'og:url', urlPath);
  }

  static void _setMeta(String key, String name, String content) {
    final existing = html.document.head?.querySelector('meta[$key="$name"]') as html.MetaElement?;
    if (existing != null) {
      existing.content = content;
    } else {
      final meta = html.MetaElement()..setAttribute(key, name)..content = content;
      html.document.head?.append(meta);
    }
  }
}
