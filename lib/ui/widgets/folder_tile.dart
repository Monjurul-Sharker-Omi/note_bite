import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';
import 'package:note_bite/ui/widgets/retro_card.dart';

/// A folder-style tile for courses and chapters.
///
/// Shows the folder icon, name, and optional stats (file/chapter/card counts).
class FolderTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final String? subtitle;
  final int? itemCount;
  final String? itemLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color accentColor;

  const FolderTile({
    super.key,
    required this.name,
    this.icon = Icons.folder_outlined,
    this.subtitle,
    this.itemCount,
    this.itemLabel,
    this.onTap,
    this.onLongPress,
    this.accentColor = AppColors.wasabi,
  });

  @override
  Widget build(BuildContext context) {
    return RetroCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.andika(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.cutiveMono(
                          fontSize: 10,
                          color: AppColors.indigoLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (itemCount != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.indigo.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '$itemCount ${itemLabel ?? 'items'}',
                    style: GoogleFonts.cutiveMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.indigoLight,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
