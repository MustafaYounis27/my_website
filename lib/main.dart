import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Cleaner URLs without the '#' for web
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyPortfolioApp());
}
