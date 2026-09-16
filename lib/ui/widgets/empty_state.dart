import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A styled empty state widget for when lists have no content.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? katakana;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.katakana,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.indigo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.indigo.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.indigoLight.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: GoogleFonts.andika(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
            if (katakana != null) ...[
              const SizedBox(height: 4),
              Text(
                katakana!,
                style: GoogleFonts.cutiveMono(
                  fontSize: 11,
                  color: AppColors.indigoLight.withValues(alpha: 0.5),
                  letterSpacing: 3,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: GoogleFonts.andika(
                  fontSize: 14,
                  color: AppColors.indigoLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.indigo,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.indigo, width: 1.5),
                    boxShadow: AppColors.retroShadowSmall,
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.andika(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
