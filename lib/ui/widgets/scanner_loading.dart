import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A retro "Document Scanner" loading animation.
///
/// Displays a typewriter-pattern grid card placeholder where a
/// colored laser line glides up and down, simulating document scanning.
class ScannerLoading extends StatefulWidget {
  final String? message;

  const ScannerLoading({super.key, this.message});

  @override
  State<ScannerLoading> createState() => _ScannerLoadingState();
}

class _ScannerLoadingState extends State<ScannerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanner card
          Container(
            width: 280,
            height: 380,
            decoration: BoxDecoration(
              color: AppColors.parchment,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.indigo, width: 2),
              boxShadow: AppColors.retroShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Typewriter grid
                  CustomPaint(
                    size: const Size(280, 380),
                    painter: _TypewriterGridPainter(),
                  ),
                  // Fake text lines
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(10, (index) {
                        final widths = [0.9, 0.75, 0.85, 0.6, 0.95, 0.7, 0.8, 0.65, 0.88, 0.5];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 10,
                            width: 232 * widths[index],
                            decoration: BoxDecoration(
                              color: AppColors.indigo.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Scanning laser line
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimation.value * 350,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.crimson.withValues(alpha: 0),
                                AppColors.crimson.withValues(alpha: 0.8),
                                AppColors.crimson,
                                AppColors.crimson.withValues(alpha: 0.8),
                                AppColors.crimson.withValues(alpha: 0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.crimson.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Loading text
          Text(
            widget.message ?? 'Scanning document...',
            style: GoogleFonts.cutiveMono(
              fontSize: 13,
              color: AppColors.indigoLight,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'スキャン中',
            style: GoogleFonts.cutiveMono(
              fontSize: 11,
              color: AppColors.indigoLight.withValues(alpha: 0.6),
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a typewriter-style grid for the scanner card.
class _TypewriterGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    // Horizontal lines
    const spacing = 22.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical margin lines
    final marginPaint = Paint()
      ..color = AppColors.crimson.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    canvas.drawLine(
        const Offset(22, 0), Offset(22, size.height), marginPaint);
    canvas.drawLine(
        Offset(size.width - 22, 0), Offset(size.width - 22, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
