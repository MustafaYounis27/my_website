import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Avoid blocking first paint on fonts.googleapis.com (often slow or blocked).
    GoogleFonts.config.allowRuntimeFetching = false;
    // Cleaner URLs without the '#' for web
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyPortfolioApp());
}
