import 'package:flutter/material.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A card widget styled with the neubrutalism / retro Japanese aesthetic.
///
/// Features a solid border and sharp offset drop shadow instead of
/// blurred elevation, giving a tactile, editorial feel.
class RetroCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final double borderWidth;

  const RetroCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderWidth = 1.5,
  });

  @override
  State<RetroCard> createState() => _RetroCardState();
}

class _RetroCardState extends State<RetroCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTap != null ? (_) => _setPressed(true) : null,
      onTapUp: widget.onTap != null ? (_) => _setPressed(false) : null,
      onTapCancel: widget.onTap != null ? () => _setPressed(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: widget.margin ?? EdgeInsets.zero,
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.parchment,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.indigo,
            width: widget.borderWidth,
          ),
          boxShadow: _isPressed
              ? AppColors.retroShadowSmall
              : AppColors.retroShadow,
        ),
        transform: _isPressed
            ? (Matrix4.identity()..translateByDouble(2.0, 2.0, 0.0, 1.0))
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool pressed) {
    setState(() => _isPressed = pressed);
  }
}
