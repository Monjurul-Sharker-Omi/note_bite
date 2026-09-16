import 'package:flutter/material.dart';

/// Retro Japanese Minimalist color palette.
///
/// Inspired by vintage manga paper, aged stationery, and
/// muted earthy Japanese tones.
class AppColors {
  AppColors._();

  /// Primary background — cream/off-white like vintage manga paper.
  static const Color cream = Color(0xFFFDFBF7);

  /// Slightly warmer parchment for cards and surfaces.
  static const Color parchment = Color(0xFFF5F2EB);

  /// Deep indigo/navy — used for text, borders, and heavy UI elements.
  static const Color indigo = Color(0xFF2E3D52);

  /// Muted wasabi green — status badges, positive accents.
  static const Color wasabi = Color(0xFF8F9E7B);

  /// Muted crimson red — tags, alerts, destructive accents.
  static const Color crimson = Color(0xFFC86558);

  /// Lighter indigo for secondary text and subtle elements.
  static const Color indigoLight = Color(0xFF5A6B7F);

  /// Very light cream for dividers and subtle backgrounds.
  static const Color creamDark = Color(0xFFEDE9DF);

  /// Shadow color for neubrutalism cards.
  static const Color shadow = Color(0xFF2E3D52);

  /// Standard border for retro card style.
  static const Border retroBorder = Border.fromBorderSide(
    BorderSide(color: indigo, width: 1.5),
  );

  /// Standard neubrutalism box shadow with offset.
  static const List<BoxShadow> retroShadow = [
    BoxShadow(
      color: shadow,
      offset: Offset(4, 4),
      blurRadius: 0,
    ),
  ];

  /// Smaller shadow for interactive pressed states.
  static const List<BoxShadow> retroShadowSmall = [
    BoxShadow(
      color: shadow,
      offset: Offset(2, 2),
      blurRadius: 0,
    ),
  ];
}
