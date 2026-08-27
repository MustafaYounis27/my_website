import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    final theme = Theme.of(context);
    final p = context.palette;
    final year = DateTime.now().year;

    final left = Text('© $year ${cv?.name ?? ''}'.trim(), style: theme.textTheme.bodySmall);
    const right = Text('Built with Flutter · Deployed on Netlify');

    return Column(
      children: [
        Divider(color: p.hairline, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          child: context.isMobile
              ? Column(
                  children: [
                    left,
                    const SizedBox(height: AppSpace.xxs),
                    DefaultTextStyle.merge(style: theme.textTheme.bodySmall, child: right),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    left,
                    DefaultTextStyle.merge(style: theme.textTheme.bodySmall, child: right),
                  ],
                ),
        ),
      ],
    );
  }
}
