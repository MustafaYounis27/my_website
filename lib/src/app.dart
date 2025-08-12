import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/projects_page.dart';
import 'pages/resume_page.dart';
import 'pages/admin_page.dart';
import 'state/theme_provider.dart';
import 'state/cv_provider.dart';


class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => CVProvider()..load()),
      ],
      child: Consumer2<ThemeProvider, CVProvider>(
        builder: (context, theme, cv, _) {
          final appTitle = cv.cv?.name != null && cv.cv!.name.isNotEmpty
              ? '${cv.cv!.name} - ${cv.cv!.title}'
              : 'Portfolio';
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appTitle,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const HomePage(),
              '/projects': (_) => const ProjectsPage(),
              '/resume': (_) => const ResumePage(),
              '/admin': (_) => const AdminPage(),
            },
          );
        },
      ),
    );
  }
}
