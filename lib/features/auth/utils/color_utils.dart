// lib/shared/utils/color_utils.dart
import 'package:flutter/material.dart';

extension ColorUtils on Color {
  /// Modern replacement for deprecated withOpacity()
  Color withAlpha(double alpha) {
    return withValues(alpha: alpha);
  }
  
  /// Create a subtle glow color variant
  Color get glowVariant {
    return withValues(alpha: 0.4);
  }
  
  /// Create a light background variant
  Color get lightBackground {
    return withValues(alpha: 0.1);
  }
  
  /// Create a medium background variant
  Color get mediumBackground {
    return withValues(alpha: 0.2);
  }
  
  /// Create a border variant
  Color get borderVariant {
    return withValues(alpha: 0.3);
  }
}