// Web implementation: embed the actual PDF with the browser's native viewer.
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../core/resume_file.dart';

class ResumeViewer extends StatefulWidget {
  const ResumeViewer({super.key});

  @override
  State<ResumeViewer> createState() => _ResumeViewerState();
}

class _ResumeViewerState extends State<ResumeViewer> {
  static const String _viewType = 'resume-pdf-iframe';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      _registered = true;
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        return web.HTMLIFrameElement()
          ..src = '${ResumeFile.webUrl}#view=FitH'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..title = 'Resume PDF';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: _viewType);
  }
}
