import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';
import 'package:note_bite/data/models/flashcard_model.dart';
import 'package:note_bite/ui/widgets/flashcard_widget.dart';

/// A physics-based swipeable flashcard stack.
///
/// Implements GestureDetector + Transform with dynamically calculated
/// Y-axis and Z-axis rotation, giving cards simulated physical weight.
class FlashcardStack extends StatefulWidget {
  final List<FlashcardModel> flashcards;
  final int? editingIndex;
  final ValueChanged<int>? onToggleEdit;
  final Function(int index, String front, String back)? onCardUpdated;
  final Function(int index)? onCardDeleted;

  const FlashcardStack({
    super.key,
    required this.flashcards,
    this.editingIndex,
    this.onToggleEdit,
    this.onCardUpdated,
    this.onCardDeleted,
  });

  @override
  State<FlashcardStack> createState() => _FlashcardStackState();
}

class _FlashcardStackState extends State<FlashcardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(vsync: this);
    _springAnimation =
        _springController.drive(Tween<Offset>(begin: Offset.zero, end: Offset.zero));
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.editingIndex != null) return;
    _springController.stop();
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.editingIndex != null) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.editingIndex != null) return;
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.35;

    if (_dragOffset.dx.abs() > threshold) {
      // Card was swiped far enough — animate it off screen
      _animateOffScreen(_dragOffset.dx > 0 ? 1 : -1);
    } else {
      // Snap back with spring physics
      _animateSpringBack();
    }
  }

  void _animateOffScreen(int direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final target = Offset(direction * screenWidth * 1.5, _dragOffset.dy);

    _springAnimation = _springController.drive(
      Tween<Offset>(begin: _dragOffset, end: target),
    );
    _springController.duration = const Duration(milliseconds: 300);
    _springController.forward(from: 0).then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.flashcards.length;
        _dragOffset = Offset.zero;
      });
      _springController.reset();
    });
  }

  void _animateSpringBack() {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 500, damping: 25),
      0,
      1,
      -10,
    );

    _springAnimation = _springController.drive(
      Tween<Offset>(begin: _dragOffset, end: Offset.zero),
    );
    _springController.animateWith(simulation).then((_) {
      setState(() => _dragOffset = Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Center(
        child: Text(
          'No flashcards yet',
          style: GoogleFonts.andika(
            fontSize: 16,
            color: AppColors.indigoLight,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Card counter
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${_currentIndex + 1} / ${widget.flashcards.length}',
            style: GoogleFonts.cutiveMono(
              fontSize: 14,
              color: AppColors.indigoLight,
              letterSpacing: 2,
            ),
          ),
        ),
        // Card stack
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: _buildCardStack(constraints),
              );
            },
          ),
        ),
        // Navigation dots
        const SizedBox(height: 20),
        _buildNavigationDots(),
      ],
    );
  }

  List<Widget> _buildCardStack(BoxConstraints constraints) {
    final cards = <Widget>[];
    final total = widget.flashcards.length;
    if (total == 0) return cards;

    // Show up to 3 cards in the stack (back cards peeking behind)
    for (int i = 2; i >= 0; i--) {
      final cardIndex = (_currentIndex + i) % total;
      if (i == 0) {
        // Top card — draggable
        cards.add(
          AnimatedBuilder(
            animation: _springAnimation,
            builder: (context, child) {
              final offset =
                  _isDragging ? _dragOffset : _springAnimation.value;
              final rotationY = offset.dx / 800; // Y-axis rotation
              final rotationZ = offset.dx / 1200; // Z-axis tilt

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translateByDouble(offset.dx, offset.dy * 0.3, 0.0, 1.0)
                  ..rotateY(rotationY)
                  ..rotateZ(rotationZ),
                child: child,
              );
            },
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: SizedBox(
                width: constraints.maxWidth * 0.88,
                height: constraints.maxHeight * 0.85,
                child: FlashcardWidget(
                  frontText: widget.flashcards[cardIndex].frontText,
                  backText: widget.flashcards[cardIndex].backText,
                  isEditing: widget.editingIndex == cardIndex,
                  onToggleEdit: () => widget.onToggleEdit?.call(cardIndex),
                  onFrontChanged: (text) =>
                      widget.onCardUpdated?.call(cardIndex, text, widget.flashcards[cardIndex].backText),
                  onBackChanged: (text) =>
                      widget.onCardUpdated?.call(cardIndex, widget.flashcards[cardIndex].frontText, text),
                  onDelete: () => widget.onCardDeleted?.call(cardIndex),
                ),
              ),
            ),
          ),
        );
      } else {
        // Background cards (peeking)
        final scale = 1.0 - (i * 0.05);
        final translateY = i * 12.0;
        cards.add(
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(0.0, translateY, 0.0, 1.0)
              ..scaleByDouble(scale, scale, scale, 1.0),
            child: Opacity(
              opacity: 1.0 - (i * 0.2),
              child: SizedBox(
                width: constraints.maxWidth * 0.88,
                height: constraints.maxHeight * 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.indigo, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        offset: Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return cards;
  }

  Widget _buildNavigationDots() {
    final total = widget.flashcards.length;
    const maxDots = 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        math.min(total, maxDots),
        (index) {
          final isActive = index == _currentIndex % math.min(total, maxDots);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.indigo : AppColors.creamDark,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive ? AppColors.indigo : AppColors.indigoLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
