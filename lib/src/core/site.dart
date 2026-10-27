/// Public address of the deployed site. Social scrapers and search engines
/// need absolute URLs for og:image, og:url and the canonical link.
abstract final class Site {
  static const String url = 'https://mustafa-younis-portfolio.web.app';
  static const String ogImage = '$url/og-image.jpg';

  static String page(String path) => '$url$path';
}
