import 'package:flutter/material.dart';

class AppIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final Widget icon;

  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    Key? key,
  }) : super(key: key);

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late final Tween<double> _opacityTween;
  late final Tween<double> _scaleTween;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..forward();

    _opacityAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInCubic);
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);

    _opacityTween = Tween(begin: 0.6, end: 1.0);
    _scaleTween = Tween(begin: 0.2, end: 1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: widget.tooltip,
            child: widget.icon,
          ),
        ),
      ),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityTween.evaluate(_opacityAnimation),
          child: Transform.scale(
            scale: _scaleTween.evaluate(_scaleAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
