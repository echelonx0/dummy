// lib/shared/utils/color_utils.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Utility extension and methods to handle the withOpacity() deprecation
/// and provide easy color alpha manipulation throughout the app
extension ColorAlpha on Color {
  /// Replacement for deprecated withOpacity() method
  /// Uses the new withValues() method to set alpha channel
  /// Takes a double value between 0.0 and 1.0 (like the old withOpacity)
  Color withAlpha(double alpha) {
    assert(alpha >= 0.0 && alpha <= 1.0, 'Alpha must be between 0.0 and 1.0');
    return withValues(alpha: alpha);
  }

  /// Quick alpha variants for common use cases
  Color get alpha10 => withValues(alpha: 0.1);
  Color get alpha20 => withValues(alpha: 0.2);
  Color get alpha30 => withValues(alpha: 0.3);
  Color get alpha40 => withValues(alpha: 0.4);
  Color get alpha50 => withValues(alpha: 0.5);
  Color get alpha60 => withValues(alpha: 0.6);
  Color get alpha70 => withValues(alpha: 0.7);
  Color get alpha80 => withValues(alpha: 0.8);
  Color get alpha90 => withValues(alpha: 0.9);
  Color get alpha95 => withValues(alpha: 0.95);

  /// Very light variants for backgrounds
  Color get alpha05 => withValues(alpha: 0.05);
  Color get alpha15 => withValues(alpha: 0.15);
  Color get alpha25 => withValues(alpha: 0.25);
}

/// Pre-defined alpha variants of your app colors for consistent use
class AppColorAlpha {
  AppColorAlpha._(); // Private constructor to prevent instantiation

  // Primary Dark Blue variants
  static Color get primaryDarkBlue05 => AppColors.primaryDarkBlue.alpha05;
  static Color get primaryDarkBlue10 => AppColors.primaryDarkBlue.alpha10;
  static Color get primaryDarkBlue20 => AppColors.primaryDarkBlue.alpha20;
  static Color get primaryDarkBlue30 => AppColors.primaryDarkBlue.alpha30;
  static Color get primaryDarkBlue40 => AppColors.primaryDarkBlue.alpha40;
  static Color get primaryDarkBlue50 => AppColors.primaryDarkBlue.alpha50;
  static Color get primaryDarkBlue60 => AppColors.primaryDarkBlue.alpha60;
  static Color get primaryDarkBlue70 => AppColors.primaryDarkBlue.alpha70;
  static Color get primaryDarkBlue80 => AppColors.primaryDarkBlue.alpha80;
  static Color get primaryDarkBlue90 => AppColors.primaryDarkBlue.alpha90;

  // Primary Gold variants
  static Color get primaryGold05 => AppColors.primaryGold.alpha05;
  static Color get primaryGold10 => AppColors.primaryGold.alpha10;
  static Color get primaryGold20 => AppColors.primaryGold.alpha20;
  static Color get primaryGold30 => AppColors.primaryGold.alpha30;
  static Color get primaryGold40 => AppColors.primaryGold.alpha40;
  static Color get primaryGold50 => AppColors.primaryGold.alpha50;
  static Color get primaryGold60 => AppColors.primaryGold.alpha60;
  static Color get primaryGold70 => AppColors.primaryGold.alpha70;
  static Color get primaryGold80 => AppColors.primaryGold.alpha80;
  static Color get primaryGold90 => AppColors.primaryGold.alpha90;

  // Premium color variants (from your UI)
  static const Color coralPink = Color(0xFFFF6B9D);
  static const Color electricBlue = Color(0xFF4ECDC4);
  static const Color sunsetOrange = Color(0xFFFFE66D);
  static const Color mintGreen = Color(0xFF95E1A3);
  static const Color lavenderPurple = Color(0xFFB794F6);

  // Premium color alpha variants
  static Color get coralPink05 => coralPink.alpha05;
  static Color get coralPink10 => coralPink.alpha10;
  static Color get coralPink20 => coralPink.alpha20;
  static Color get coralPink30 => coralPink.alpha30;
  static Color get coralPink40 => coralPink.alpha40;
  static Color get coralPink50 => coralPink.alpha50;
  static Color get coralPink60 => coralPink.alpha60;
  static Color get coralPink70 => coralPink.alpha70;
  static Color get coralPink80 => coralPink.alpha80;
  static Color get coralPink90 => coralPink.alpha90;

  static Color get electricBlue05 => electricBlue.alpha05;
  static Color get electricBlue10 => electricBlue.alpha10;
  static Color get electricBlue20 => electricBlue.alpha20;
  static Color get electricBlue30 => electricBlue.alpha30;
  static Color get electricBlue40 => electricBlue.alpha40;
  static Color get electricBlue50 => electricBlue.alpha50;
  static Color get electricBlue60 => electricBlue.alpha60;
  static Color get electricBlue70 => electricBlue.alpha70;
  static Color get electricBlue80 => electricBlue.alpha80;
  static Color get electricBlue90 => electricBlue.alpha90;

  static Color get sunsetOrange05 => sunsetOrange.alpha05;
  static Color get sunsetOrange10 => sunsetOrange.alpha10;
  static Color get sunsetOrange20 => sunsetOrange.alpha20;
  static Color get sunsetOrange30 => sunsetOrange.alpha30;
  static Color get sunsetOrange40 => sunsetOrange.alpha40;
  static Color get sunsetOrange50 => sunsetOrange.alpha50;
  static Color get sunsetOrange60 => sunsetOrange.alpha60;
  static Color get sunsetOrange70 => sunsetOrange.alpha70;
  static Color get sunsetOrange80 => sunsetOrange.alpha80;
  static Color get sunsetOrange90 => sunsetOrange.alpha90;

  static Color get mintGreen05 => mintGreen.alpha05;
  static Color get mintGreen10 => mintGreen.alpha10;
  static Color get mintGreen20 => mintGreen.alpha20;
  static Color get mintGreen30 => mintGreen.alpha30;
  static Color get mintGreen40 => mintGreen.alpha40;
  static Color get mintGreen50 => mintGreen.alpha50;
  static Color get mintGreen60 => mintGreen.alpha60;
  static Color get mintGreen70 => mintGreen.alpha70;
  static Color get mintGreen80 => mintGreen.alpha80;
  static Color get mintGreen90 => mintGreen.alpha90;

  static Color get lavenderPurple05 => lavenderPurple.alpha05;
  static Color get lavenderPurple10 => lavenderPurple.alpha10;
  static Color get lavenderPurple20 => lavenderPurple.alpha20;
  static Color get lavenderPurple30 => lavenderPurple.alpha30;
  static Color get lavenderPurple40 => lavenderPurple.alpha40;
  static Color get lavenderPurple50 => lavenderPurple.alpha50;
  static Color get lavenderPurple60 => lavenderPurple.alpha60;
  static Color get lavenderPurple70 => lavenderPurple.alpha70;
  static Color get lavenderPurple80 => lavenderPurple.alpha80;
  static Color get lavenderPurple90 => lavenderPurple.alpha90;

  // Common white variants for overlays
  static Color get white05 => Colors.white.alpha05;
  static Color get white10 => Colors.white.alpha10;
  static Color get white15 => Colors.white.alpha15;
  static Color get white20 => Colors.white.alpha20;
  static Color get white25 => Colors.white.alpha25;
  static Color get white30 => Colors.white.alpha30;
  static Color get white40 => Colors.white.alpha40;
  static Color get white50 => Colors.white.alpha50;
  static Color get white60 => Colors.white.alpha60;
  static Color get white70 => Colors.white.alpha70;
  static Color get white80 => Colors.white.alpha80;
  static Color get white90 => Colors.white.alpha90;
  static Color get white95 => Colors.white.alpha95;

  // Common black variants for overlays and shadows
  static Color get black05 => Colors.black.alpha05;
  static Color get black10 => Colors.black.alpha10;
  static Color get black20 => Colors.black.alpha20;
  static Color get black30 => Colors.black.alpha30;
  static Color get black40 => Colors.black.alpha40;
  static Color get black50 => Colors.black.alpha50;
  static Color get black60 => Colors.black.alpha60;
  static Color get black70 => Colors.black.alpha70;
  static Color get black80 => Colors.black.alpha80;
  static Color get black90 => Colors.black.alpha90;
}

/// Utility class for creating gradients with alpha variants
class GradientUtils {
  GradientUtils._(); // Private constructor

  /// Create a linear gradient with alpha progression
  static LinearGradient alphaGradient({
    required Color color,
    double startAlpha = 1.0,
    double endAlpha = 0.0,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        color.withValues(alpha: startAlpha),
        color.withValues(alpha: endAlpha),
      ],
    );
  }

  /// Create a radial gradient with alpha progression
  static RadialGradient alphaRadialGradient({
    required Color color,
    double centerAlpha = 1.0,
    double edgeAlpha = 0.0,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        color.withValues(alpha: centerAlpha),
        color.withValues(alpha: edgeAlpha),
      ],
    );
  }

  /// Common gradients used in your app
  static LinearGradient get primaryHeaderGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryDarkBlue,
      AppColors.primaryDarkBlue.alpha90,
      AppColors.primaryDarkBlue.alpha80,
    ],
  );

  static LinearGradient get coralToOrange => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorAlpha.coralPink,
      AppColorAlpha.coralPink90,
      AppColorAlpha.sunsetOrange80,
    ],
  );

  static LinearGradient get purpleToBlue => LinearGradient(
    colors: [
      AppColorAlpha.lavenderPurple,
      AppColorAlpha.lavenderPurple90,
      AppColorAlpha.electricBlue80,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// BoxShadow utilities with proper alpha values
class ShadowUtils {
  ShadowUtils._(); // Private constructor

  /// Create a soft shadow with the given color
  static BoxShadow softShadow({
    required Color color,
    double alpha = 0.1,
    double blurRadius = 10,
    Offset offset = const Offset(0, 5),
  }) {
    return BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: blurRadius,
      offset: offset,
    );
  }

  /// Create a glow effect with the given color
  static BoxShadow glowShadow({
    required Color color,
    double alpha = 0.3,
    double blurRadius = 20,
    Offset offset = const Offset(0, 8),
  }) {
    return BoxShadow(
      color: color.withValues(alpha: alpha),
      blurRadius: blurRadius,
      offset: offset,
    );
  }

  /// Common shadow presets
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColorAlpha.black05,
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(
      color: AppColorAlpha.black10,
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColorAlpha.black05,
      blurRadius: 30,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> primaryGlow(Color color) => [
    BoxShadow(
      color: color.alpha30,
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}

/// Migration helper for quick replacements
/// Use this to quickly replace .withOpacity() calls
class ColorMigration {
  ColorMigration._(); // Private constructor

  /// Quick replacement for .withOpacity() calls
  /// Example: ColorMigration.opacity(Colors.blue, 0.5)
  /// Instead of: Colors.blue.withOpacity(0.5)
  static Color opacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
