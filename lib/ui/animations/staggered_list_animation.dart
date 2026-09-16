import 'package:flutter/material.dart';

/// A wrapper widget providing staggered slide-up animation for list items.
///
/// Each child slides up from below with a staggered delay, creating an
/// elegant cascading entrance animation when navigating to a new screen.
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final double slideOffset;
  final EdgeInsetsGeometry? padding;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.slideOffset = 50,
    this.padding,
  });

  @override
  State<StaggeredListAnimation> createState() =>
      _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(StaggeredListAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (int i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      );

      final fade = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );

      final slide = Tween<Offset>(
        begin: Offset(0, widget.slideOffset),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      _controllers.add(controller);
      _fadeAnimations.add(fade);
      _slideAnimations.add(slide);

      // Start each animation with a staggered delay
      Future.delayed(widget.itemDelay * i, () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _fadeAnimations.clear();
    _slideAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.padding ?? const EdgeInsets.all(20),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        if (index >= _fadeAnimations.length) {
          return widget.children[index];
        }

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value,
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: widget.children[index],
          ),
        );
      },
    );
  }
}
