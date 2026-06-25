import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF393939);
  
  // Elevation Surfaces
  static const Color surfaceLevel1 = Color(0xFF1E1E1E);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);

  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFD4C5AB);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);

  // Brand Accent Colors
  static const Color primary = Color(0xFFFFE4AF);
  static const Color primaryContainer = Color(0xFFFFC107); // Amber Solid
  static const Color primaryFixedDim = Color(0xFFFABD00); // Amber Tint
  static const Color onPrimary = Color(0xFF3F2E00);
  static const Color onPrimaryContainer = Color(0xFF6D5100);

  static const Color secondary = Color(0xFF45D8ED); // Teal
  static const Color secondaryContainer = Color(0xFF00BACD);
  static const Color onSecondary = Color(0xFF00363D);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color outline = Color(0xFF9C8F78);
  static const Color outlineVariant = Color(0xFF4F4632);
}

class AppTypography {
  static TextStyle get headlineLg => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.64,
        color: AppColors.primary,
      );

  static TextStyle get headlineMd => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33, // 32px
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4, // 28px
        color: AppColors.onSurface,
      );

  // Body typography (Hanken Grotesk)
  static TextStyle get bodyLg => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.44, // 26px
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5, // 24px
        color: AppColors.onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43, // 20px
        letterSpacing: 0.14, // 0.01em
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33, // 16px
        color: AppColors.onSurface,
      );
}

class AppDecorations {
  // Level 1 Glassmorphic card styling
  static BoxDecoration glassPanel({
    double borderRadius = 12.0,
    Color color = const Color(0xCC1E1E1E),
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1.0,
      ),
    );
  }

  // Shadow glow effect for primary Amber button
  static List<BoxShadow> primaryGlow() {
    return [
      BoxShadow(
        color: AppColors.primaryContainer.withValues(alpha: 0.3),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
