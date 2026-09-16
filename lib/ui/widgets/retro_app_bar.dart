import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A custom app bar with the retro Japanese minimalist style.
///
/// Features the main title alongside a small katakana subtitle
/// for decorative Japanese aesthetic.
class RetroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? katakanaSubtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const RetroAppBar({
    super.key,
    required this.title,
    this.katakanaSubtitle,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          border: Border(
            bottom: BorderSide(color: AppColors.creamDark, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (showBack) ...[
              GestureDetector(
                onTap: onBack ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.indigo, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.indigo,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.andika(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.indigo,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (katakanaSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      katakanaSubtitle!,
                      style: GoogleFonts.cutiveMono(
                        fontSize: 10,
                        color: AppColors.indigoLight,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
