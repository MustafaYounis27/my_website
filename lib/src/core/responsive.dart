import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double contentMaxWidth = 1100;
}

extension ContextScreen on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < Breakpoints.mobile;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= Breakpoints.mobile &&
      MediaQuery.of(this).size.width < Breakpoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= Breakpoints.tablet;

  double get contentMaxWidth => Breakpoints.contentMaxWidth;
}

class CenteredConstrained extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const CenteredConstrained({super.key, required this.child, this.maxWidth = Breakpoints.contentMaxWidth});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ),
    );
  }
}
