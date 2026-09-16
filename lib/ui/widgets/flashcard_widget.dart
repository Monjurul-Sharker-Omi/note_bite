import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A single 3D-flippable flashcard widget.
///
/// Tapping the card triggers a smooth 180-degree Y-axis flip animation.
/// The front text swaps with the back text at exactly 90 degrees of rotation.
/// Supports inline editing mode.
class FlashcardWidget extends StatefulWidget {
  final String frontText;
  final String backText;
  final bool isEditing;
  final ValueChanged<String>? onFrontChanged;
  final ValueChanged<String>? onBackChanged;
  final VoidCallback? onToggleEdit;
  final VoidCallback? onDelete;

  const FlashcardWidget({
    super.key,
    required this.frontText,
    required this.backText,
    this.isEditing = false,
    this.onFrontChanged,
    this.onBackChanged,
    this.onToggleEdit,
    this.onDelete,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showFront = true;

  late TextEditingController _frontTextController;
  late TextEditingController _backTextController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
    _flipAnimation.addListener(() {
      // Swap text at 90 degrees (halfway through animation)
      final angle = _flipAnimation.value * math.pi;
      if (angle >= math.pi / 2 && _showFront) {
        setState(() => _showFront = false);
      } else if (angle < math.pi / 2 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    _frontTextController = TextEditingController(text: widget.frontText);
    _backTextController = TextEditingController(text: widget.backText);
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frontText != widget.frontText) {
      _frontTextController.text = widget.frontText;
    }
    if (oldWidget.backText != widget.backText) {
      _backTextController.text = widget.backText;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (widget.isEditing) return;
    if (_flipController.isAnimating) return;

    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: _showFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCardFace(
      label: 'FRONT',
      labelKatakana: 'おもて',
      text: widget.frontText,
      controller: _frontTextController,
      onChanged: widget.onFrontChanged,
      color: AppColors.parchment,
      isBack: false,
    );
  }

  Widget _buildBack() {
    // Mirror the back face so text reads correctly
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: _buildCardFace(
        label: 'BACK',
        labelKatakana: 'うら',
        text: widget.backText,
        controller: _backTextController,
        onChanged: widget.onBackChanged,
        color: AppColors.cream,
        isBack: true,
      ),
    );
  }

  Widget _buildCardFace({
    required String label,
    required String labelKatakana,
    required String text,
    required TextEditingController controller,
    required ValueChanged<String>? onChanged,
    required Color color,
    required bool isBack,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.indigo, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative grid pattern
          ..._buildGridLines(),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBack
                                ? AppColors.wasabi.withValues(alpha: 0.15)
                                : AppColors.crimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isBack ? AppColors.wasabi : AppColors.crimson,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.cutiveMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  isBack ? AppColors.wasabi : AppColors.crimson,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          labelKatakana,
                          style: GoogleFonts.cutiveMono(
                            fontSize: 10,
                            color: AppColors.indigoLight,
                          ),
                        ),
                      ],
                    ),
                    if (widget.onToggleEdit != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: widget.onToggleEdit,
                            child: Icon(
                              widget.isEditing
                                  ? Icons.check_circle_outline
                                  : Icons.edit_outlined,
                              color: AppColors.indigoLight,
                              size: 20,
                            ),
                          ),
                          if (widget.onDelete != null) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: widget.onDelete,
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.crimson,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
                const Spacer(),
                // Card content
                if (widget.isEditing)
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      maxLines: null,
                      style: GoogleFonts.andika(
                        fontSize: 18,
                        color: AppColors.indigo,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter $label text...',
                        hintStyle: GoogleFonts.andika(
                          color: AppColors.indigoLight.withValues(alpha: 0.4),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        text,
                        style: GoogleFonts.andika(
                          fontSize: 20,
                          color: AppColors.indigo,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const Spacer(),
                // Tap hint
                if (!widget.isEditing)
                  Center(
                    child: Text(
                      'tap to flip',
                      style: GoogleFonts.cutiveMono(
                        fontSize: 10,
                        color: AppColors.indigoLight.withValues(alpha: 0.5),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds subtle decorative grid lines mimicking a typewriter grid.
  List<Widget> _buildGridLines() {
    return [
      Positioned.fill(
        child: CustomPaint(
          painter: _GridPainter(),
        ),
      ),
    ];
  }
}

/// Paints subtle horizontal typewriter-style grid lines.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    // Horizontal lines
    const lineSpacing = 28.0;
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Left margin line
    final marginPaint = Paint()
      ..color = AppColors.crimson.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(20, 0),
      Offset(20, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
