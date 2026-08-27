import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';

/// Paints text with the brand gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette.gradient;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? Theme.of(context).textTheme.headlineSmall)?.copyWith(color: Colors.white),
      ),
    );
  }
}
