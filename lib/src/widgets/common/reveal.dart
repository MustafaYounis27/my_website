import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';

/// Fades and rises its child the first time it scrolls into view.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.base);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: AppMotion.standard);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_fade);

  ScrollPosition? _position;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePlay());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _played = true;
      _controller.value = 1;
      return;
    }

    _position?.removeListener(_maybePlay);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_maybePlay);
  }

  void _maybePlay() {
    if (_played || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final viewportHeight = MediaQuery.of(context).size.height;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top > viewportHeight * 0.92) return;

    _played = true;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_maybePlay);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
