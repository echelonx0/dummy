// lib/shared/theme/app_gradients.dart
import 'package:flutter/material.dart';

class AppGradients {
  // Private constructor to prevent instantiation
  AppGradients._();

  // ==========================================================================
  // DARK PREMIUM COLOR PALETTE CONSTANTS
  // ==========================================================================

  static const Color _deepCharcoal = Color(0xFF222831);
  static const Color _mediumCharcoal = Color(0xFF393E46);
  static const Color _warmBronze = Color(0xFF948979);
  static const Color _softCream = Color(0xFFDFD0B8);
  static const Color _darkerCharcoal = Color(0xFF1A1D23);
  static const Color _lightBronze = Color(0xFFB8A082);

  // ==========================================================================
  // AUTH SCREEN GRADIENTS
  // ==========================================================================

  /// Primary auth gradient for login screen - Dark premium
  static const LinearGradient loginGradient = LinearGradient(
    colors: [_darkerCharcoal, _deepCharcoal, _mediumCharcoal, _warmBronze],
    stops: [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Register screen gradient with cream highlights
  static const LinearGradient registerGradient = LinearGradient(
    colors: [_deepCharcoal, _mediumCharcoal, _warmBronze, _softCream],
    stops: [0.0, 0.4, 0.8, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Forgot password gradient (normal state)
  static const LinearGradient forgotPasswordGradient = LinearGradient(
    colors: [_warmBronze, _mediumCharcoal, _deepCharcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Forgot password gradient (success state)
  static const LinearGradient forgotPasswordSuccessGradient = LinearGradient(
    colors: [
      Color(0xFF10B981), // Success green
      _warmBronze,
      _deepCharcoal,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==========================================================================
  // DASHBOARD & UI GRADIENTS
  // ==========================================================================

  /// Enhanced dashboard header gradient
  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    colors: [_darkerCharcoal, _deepCharcoal, _mediumCharcoal, _warmBronze],
    stops: [0.0, 0.2, 0.6, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Match status widget gradient (ready state)
  static const LinearGradient matchStatusGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_mediumCharcoal, _warmBronze, _softCream],
    stops: [0.0, 0.6, 1.0],
  );

  /// Philosophy card gradient (variant 1) - Subtle bronze
  static LinearGradient philosophyCardGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_mediumCharcoal, _warmBronze.withValues(alpha: 0.3)],
  );

  /// Philosophy card gradient (variant 2) - Cream highlights
  static LinearGradient philosophyCardGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_mediumCharcoal, _softCream.withValues(alpha: 0.1)],
  );

  /// Action card gradient - Bronze to charcoal
  static const LinearGradient actionCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_warmBronze, _mediumCharcoal],
  );

  // ==========================================================================
  // BUTTON GRADIENTS
  // ==========================================================================

  /// Primary button gradient - Bronze tones
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [_warmBronze, _lightBronze],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary button gradient - Charcoal tones
  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [_mediumCharcoal, _deepCharcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// CTA button gradient - Bronze to cream
  static const LinearGradient ctaButtonGradient = LinearGradient(
    colors: [_warmBronze, _softCream],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==========================================================================
  // OVERLAY GRADIENTS
  // ==========================================================================

  /// Dark overlay for modals and bottomsheets
  static LinearGradient darkOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _darkerCharcoal.withValues(alpha: 0.8),
      _deepCharcoal.withValues(alpha: 0.9),
    ],
  );

  /// Light overlay for content over dark backgrounds
  static LinearGradient lightOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      _softCream.withValues(alpha: 0.1),
      _warmBronze.withValues(alpha: 0.05),
    ],
  );

  /// Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [_mediumCharcoal, _warmBronze, _mediumCharcoal],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  // ==========================================================================
  // UTILITY METHODS FOR DYNAMIC GRADIENTS
  // ==========================================================================

  /// Get auth gradient with custom alpha values
  static LinearGradient getAuthGradient({
    required List<Color> baseColors,
    List<double>? alphas,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<double>? stops,
  }) {
    List<Color> finalColors = baseColors;

    if (alphas != null && alphas.length == baseColors.length) {
      finalColors = List.generate(baseColors.length, (index) {
        return baseColors[index].withValues(alpha: alphas[index]);
      });
    }

    return LinearGradient(
      colors: finalColors,
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      stops: stops,
    );
  }

  /// Get premium dark gradient with alpha variations
  static LinearGradient getPremiumDarkGradient({
    double bronzeAlpha = 0.8,
    double creamAlpha = 0.6,
    double charcoalAlpha = 0.9,
  }) {
    return LinearGradient(
      colors: [
        _darkerCharcoal,
        _deepCharcoal.withValues(alpha: charcoalAlpha),
        _warmBronze.withValues(alpha: bronzeAlpha),
        _softCream.withValues(alpha: creamAlpha),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Get card gradient with customizable alpha
  static LinearGradient getCardGradient({
    Color primaryColor = _mediumCharcoal,
    double primaryAlpha = 1.0,
    Color secondaryColor = _warmBronze,
    double secondaryAlpha = 0.3,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withValues(alpha: primaryAlpha),
        secondaryColor.withValues(alpha: secondaryAlpha),
      ],
    );
  }

  /// Get glass morphism effect gradient
  static LinearGradient getGlassMorphismGradient({double opacity = 0.1}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _softCream.withValues(alpha: opacity),
        _warmBronze.withValues(alpha: opacity * 0.5),
        _mediumCharcoal.withValues(alpha: opacity * 0.3),
      ],
    );
  }

  // ==========================================================================
  // GRADIENT PRESETS FOR COMMON UI PATTERNS
  // ==========================================================================

  /// Subtle background gradient for cards
  static LinearGradient subtleCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_mediumCharcoal, _warmBronze.withValues(alpha: 0.1)],
  );

  /// Elevated card gradient with depth
  static const LinearGradient elevatedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_mediumCharcoal, _warmBronze, _lightBronze],
    stops: [0.0, 0.6, 1.0],
  );

  /// Input field gradient
  static LinearGradient inputFieldGradient = LinearGradient(
    colors: [_mediumCharcoal, _mediumCharcoal.withValues(alpha: 0.8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Floating element gradient with glow effect
  static LinearGradient getFloatingElementGradient({double alpha = 0.2}) {
    return LinearGradient(
      colors: [
        _warmBronze.withValues(alpha: alpha),
        _softCream.withValues(alpha: alpha * 0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ==========================================================================
  // SHADOW AND GLOW UTILITIES
  // ==========================================================================

  /// Premium glow effects for dark theme
  static List<BoxShadow> bronzeGlow({
    double alpha = 0.30,
    double blurRadius = 24,
    Offset offset = const Offset(0, 12),
  }) {
    return [
      BoxShadow(
        color: _warmBronze.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  static List<BoxShadow> creamGlow({
    double alpha = 0.25,
    double blurRadius = 20,
    Offset offset = const Offset(0, 10),
  }) {
    return [
      BoxShadow(
        color: _softCream.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  static List<BoxShadow> darkCardShadow({
    double alpha = 0.2,
    double blurRadius = 12,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: _darkerCharcoal.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  /// Progress bar gradient
  static const LinearGradient progressGradient = LinearGradient(
    colors: [_warmBronze, _lightBronze, _softCream],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Success state gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), _warmBronze],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Error state gradient
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), _mediumCharcoal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning state gradient
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), _warmBronze],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==========================================================================
  // RADIAL GRADIENTS
  // ==========================================================================

  /// Spotlight effect gradient
  static RadialGradient getSpotlightGradient({
    Color centerColor = _softCream,
    double centerAlpha = 0.3,
    Color edgeColor = _deepCharcoal,
    double edgeAlpha = 0.8,
  }) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        centerColor.withValues(alpha: centerAlpha),
        edgeColor.withValues(alpha: edgeAlpha),
      ],
    );
  }

  /// Circular button gradient
  static const RadialGradient circularButtonGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [_warmBronze, _mediumCharcoal],
  );

  /// Glow effect gradient
  static RadialGradient getGlowGradient({
    required Color glowColor,
    double intensity = 0.4,
  }) {
    return RadialGradient(
      colors: [
        glowColor.withValues(alpha: intensity),
        glowColor.withValues(alpha: intensity * 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }
}
