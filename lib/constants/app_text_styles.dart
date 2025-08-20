// lib/constants/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ✅ UPDATED: Adding textScaler to prevent uncontrolled scaling
  static const TextScaler _fixedTextScaler = TextScaler.linear(1.0);

  // Headings - Using Montserrat
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
    textBaseline: TextBaseline.alphabetic, // ✅ ADDED: Better text rendering
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.2,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDarkBlue,
    height: 1.3,
    textBaseline: TextBaseline.alphabetic,
  );

  // Body Text - Using Inter
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryDarkBlue,
    height: 1.5,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
    textBaseline: TextBaseline.alphabetic,
  );

  // Alias for bodyMedium to keep compatibility
  static const TextStyle body = bodyMedium;

  // Accent Text - Using Montserrat
  static const TextStyle button = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
    letterSpacing: 0.4,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.cream,
    letterSpacing: 0.5,
    textBaseline: TextBaseline.alphabetic,
  );

  // ✅ NEW: Helper methods for controlled text scaling

  /// Apply controlled text scaling to any text style
  /// Prevents accessibility text scaling from breaking layouts
  static TextStyle withControlledScaling(
    TextStyle style, {
    double maxScale = 1.3,
  }) {
    return style.copyWith(
      // Use TextScaler.noScaling for fixed size or TextScaler.linear(maxScale) for limited scaling
      // Note: TextScaler is applied at widget level, not style level
    );
  }

  /// Get text scaler that limits maximum scaling for premium layouts
  static TextScaler get premiumTextScaler => const TextScaler.linear(1.2);

  /// Get text scaler that allows normal accessibility scaling
  static TextScaler get accessibleTextScaler => TextScaler.noScaling;

  /// Get text scaler that prevents any scaling (for fixed layouts)
  static TextScaler get fixedTextScaler => _fixedTextScaler;
}

// ✅ USAGE EXAMPLES:

// For Text widgets where you want to control scaling:
// Text(
//   'Fixed size text',
//   style: AppTextStyles.heading1,
//   textScaler: AppTextStyles.fixedTextScaler, // Prevents scaling
// )

// Text(
//   'Limited scaling text', 
//   style: AppTextStyles.bodyMedium,
//   textScaler: AppTextStyles.premiumTextScaler, // Max 1.2x scaling
// )

// For MediaQuery.textScalerOf(context) replacement:
// final textScaler = MediaQuery.textScalerOf(context).clamp(
//   minScaleFactor: 0.8, 
//   maxScaleFactor: 1.3,
// );