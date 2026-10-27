// Web implementation: updates document title and meta tags
import 'package:web/web.dart' as web;

class Seo {
  static void update({
    required String title,
    required String description,
    String? imageUrl,
    String? urlPath,
  }) {
    web.document.title = title;

    _setMeta('name', 'description', description);
    _setMeta('property', 'og:title', title);
    _setMeta('property', 'og:description', description);
    _setMeta('name', 'twitter:title', title);
    _setMeta('name', 'twitter:description', description);
    if (imageUrl != null) {
      _setMeta('property', 'og:image', imageUrl);
      _setMeta('name', 'twitter:image', imageUrl);
    }
    if (urlPath != null) {
      _setMeta('property', 'og:url', urlPath);
      _setCanonical(urlPath);
    }
  }

  static void _setMeta(String key, String name, String content) {
    final existing = web.document.head?.querySelector('meta[$key="$name"]');
    if (existing != null) {
      existing.setAttribute('content', content);
    } else {
      final meta = web.document.createElement('meta')
        ..setAttribute(key, name)
        ..setAttribute('content', content);
      web.document.head?.append(meta);
    }
  }

  static void _setCanonical(String href) {
    final existing = web.document.head?.querySelector('link[rel="canonical"]');
    if (existing != null) {
      existing.setAttribute('href', href);
    } else {
      final link = web.document.createElement('link')
        ..setAttribute('rel', 'canonical')
        ..setAttribute('href', href);
      web.document.head?.append(link);
    }
  }
}
