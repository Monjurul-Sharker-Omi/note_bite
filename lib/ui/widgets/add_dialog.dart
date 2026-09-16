import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_bite/app/theme/app_colors.dart';

/// A retro-styled dialog for adding courses, chapters, etc.
class AddDialog extends StatefulWidget {
  final String title;
  final String? katakana;
  final String hintText;
  final String confirmLabel;

  const AddDialog({
    super.key,
    required this.title,
    this.katakana,
    this.hintText = 'Enter name...',
    this.confirmLabel = 'Create',
  });

  /// Shows the dialog and returns the entered text, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? katakana,
    String hintText = 'Enter name...',
    String confirmLabel = 'Create',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => AddDialog(
        title: title,
        katakana: katakana,
        hintText: hintText,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isValid = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.retroShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.andika(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.indigo,
                  ),
                ),
                if (widget.katakana != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    widget.katakana!,
                    style: GoogleFonts.cutiveMono(
                      fontSize: 10,
                      color: AppColors.indigoLight,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            // Input
            TextField(
              controller: _controller,
              autofocus: true,
              style: GoogleFonts.andika(
                fontSize: 16,
                color: AppColors.indigo,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.indigo, width: 1.5),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.andika(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isValid ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isValid
                          ? AppColors.indigo
                          : AppColors.indigo.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isValid
                            ? AppColors.indigo
                            : AppColors.indigo.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: _isValid
                          ? AppColors.retroShadowSmall
                          : null,
                    ),
                    child: Text(
                      widget.confirmLabel,
                      style: GoogleFonts.andika(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }
}
