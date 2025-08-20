// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ==========================================================================
  // PRIMARY COLORS (Dark Premium Romantic Palette)
  // ==========================================================================

  /// Deep charcoal - Primary dark background
  static const Color primaryDarkBlue = Color(0xFF040D12);

  /// Medium charcoal - Secondary backgrounds and cards
  static const Color primaryGold = Color(0xFF040D12);

  /// Warm bronze - Premium accent for interactive elements
  static const Color primarySageGreen = Color(0xFF222831);

  /// Soft cream - Light accents and highlights
  static const Color primaryAccent = Color(0xFFDFD0B8);

  // ==========================================================================
  // BACKGROUND COLORS
  // ==========================================================================

  static const Color backgroundLight = Color(0xFF040D12); // Dark primary
  static const Color backgroundDark = Color(
    0xFF040D12,
  ); // Even darker for depth
  static const Color backgroundSecondary = Color(0xFF161616); // Medium charcoal

  // ==========================================================================
  // TEXT COLORS
  // ==========================================================================

  static const Color textDark = Color(0xFFDFD0B8); // Cream for primary text
  static const Color textMedium = Color(
    0xFF948979,
  ); // Bronze for secondary text
  static const Color textLight = Color(0xFF6B7280); // Muted for tertiary text
  static const Color textOnDark = Color(
    0xFFDFD0B8,
  ); // Cream on dark backgrounds

  // ==========================================================================
  // FEEDBACK COLORS (Adjusted for dark theme)
  // ==========================================================================

  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color error = Color(0xFFEF4444); // Warm red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // ==========================================================================
  // UI ELEMENT COLORS
  // ==========================================================================

  static const Color cardBackground = Color(0xFF040D12); // Medium charcoal
  static const Color cardBackgroundElevated = Color(
    0xFF4B5563,
  ); // Lighter for elevated cards
  static const Color divider = Color(0xFF4B5563);
  static const Color inputBackground = Color(0xFF4B5563);
  static const Color inputBorder = Color(0xFF6B7280);

  // ==========================================================================
  // ROMANTIC ACCENT COLORS (Premium Dark Theme)
  // ==========================================================================

  /// Soft cream for highlights and romantic elements
  static const Color softPink = Color(0xFFDFD0B8);

  /// Warm bronze for premium touches
  static const Color warmRed = Color(0xFF948979);

  /// Rose gold - warmer bronze variation
  static const Color roseGold = Color(0xFFB8A082);

  /// Electric blue - cool accent for interactions
  static const Color electricBlue = Color(0xFF60A5FA);

  // ==========================================================================
  // GRADIENT DEFINITIONS
  // ==========================================================================

  /// Primary gradient - Dark charcoal to medium charcoal
  static const List<Color> primaryGradient = [primaryDarkBlue, primaryGold];

  /// Accent gradient - Bronze to cream
  static const List<Color> accentGradient = [warmRed, softPink];

  /// Premium gradient - Deep to light with bronze
  static const List<Color> premiumGradient = [
    Color(0xFF1A1D23), // Darkest
    Color(0xFF040D12), // Primary dark
    Color(0xFF161616), // Medium
    Color(0xFF222831), // Bronze
  ];

  // ==========================================================================
  // SURFACE COLORS (Material 3 style)
  // ==========================================================================

  static const Color surface = Color(0xFF161616);
  static const Color surfaceVariant = Color(0xFF4B5563);
  static const Color surfaceContainerLowest = Color(0xFF1A1D23);
  static const Color surfaceContainerLow = Color(0xFF040D12);
  static const Color surfaceContainer = Color(0xFF161616);
  static const Color surfaceContainerHigh = Color(0xFF4B5563);
  static const Color surfaceContainerHighest = Color(0xFF6B7280);

  // ==========================================================================
  // ALPHA VARIATIONS
  // ==========================================================================

  static Color get primaryDarkBlueAlpha10 =>
      primaryDarkBlue.withValues(alpha: 0.1);
  static Color get primaryDarkBlueAlpha20 =>
      primaryDarkBlue.withValues(alpha: 0.2);
  static Color get primaryDarkBlueAlpha50 =>
      primaryDarkBlue.withValues(alpha: 0.5);

  static Color get primaryAccentAlpha10 => primaryAccent.withValues(alpha: 0.1);
  static Color get primaryAccentAlpha20 => primaryAccent.withValues(alpha: 0.2);
  static Color get primaryAccentAlpha50 => primaryAccent.withValues(alpha: 0.5);

  static Color get warmRedAlpha10 => warmRed.withValues(alpha: 0.1);
  static Color get warmRedAlpha20 => warmRed.withValues(alpha: 0.2);
  static Color get warmRedAlpha50 => warmRed.withValues(alpha: 0.5);

  static Color get softPinkAlpha10 => softPink.withValues(alpha: 0.1);
  static Color get softPinkAlpha20 => softPink.withValues(alpha: 0.2);
  static Color get softPinkAlpha50 => softPink.withValues(alpha: 0.5);

  // ==========================================================================
  // SEMANTIC COLORS
  // ==========================================================================

  /// Button colors
  static const Color primaryButton = Color(0xFF948979); // Bronze
  static const Color primaryButtonText = Color(0xFFDFD0B8); // Cream
  static const Color secondaryButton = Color(0xFF4B5563); // Medium gray
  static const Color secondaryButtonText = Color(0xFFDFD0B8); // Cream

  /// Border colors
  static const Color borderPrimary = Color(0xFF4B5563);
  static const Color borderSecondary = Color(0xFF6B7280);
  static const Color borderAccent = Color(0xFF948979);

  /// Overlay colors
  static Color get overlayLight =>
      const Color(0xFFDFD0B8).withValues(alpha: 0.1);
  static Color get overlayMedium =>
      const Color(0xFF948979).withValues(alpha: 0.2);
  static Color get overlayDark =>
      const Color(0xFF040D12).withValues(alpha: 0.8);

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Get dark premium color palette
  static List<Color> get darkPremiumPalette => [
    primaryDarkBlue,
    primaryGold,
    primarySageGreen,
    primaryAccent,
    electricBlue,
  ];

  /// Get contrasting text color for any background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.3 ? primaryDarkBlue : textDark;
  }

  /// Get appropriate text color for dark theme
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    if (luminance > 0.7) return primaryDarkBlue;
    if (luminance > 0.3) return textMedium;
    return textDark;
  }

  // ==========================================================================
  // LEGACY COMPATIBILITY (for gradual migration)
  // ==========================================================================

  /// Aliases for backward compatibility
  static const Color darkBlue = primaryDarkBlue;
  static const Color charcoal = primaryGold;
  static const Color bronze = primarySageGreen;
  static const Color cream = primaryAccent;
}
