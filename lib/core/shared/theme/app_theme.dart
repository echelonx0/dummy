// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme => darkTheme; // Using dark as primary theme

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDarkBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primarySageGreen, // Bronze for primary actions
        onPrimary: AppColors.primaryAccent, // Cream text on bronze
        secondary: AppColors.primaryAccent, // Cream for secondary elements
        onSecondary: AppColors.primaryDarkBlue, // Dark text on cream
        tertiary: AppColors.electricBlue, // Blue accent for special elements
        onTertiary: AppColors.primaryDarkBlue,

        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,

        error: AppColors.error,
        onError: AppColors.textDark,
        errorContainer: AppColors.error.withValues(alpha: 0.2),
        onErrorContainer: AppColors.error,

        outline: AppColors.borderPrimary,
        outlineVariant: AppColors.borderSecondary,

        shadow: AppColors.primaryDarkBlue,
        scrim: AppColors.primaryDarkBlue.withValues(alpha: 0.5),

        inverseSurface: AppColors.primaryAccent,
        onInverseSurface: AppColors.primaryDarkBlue,
        inversePrimary: AppColors.primaryDarkBlue,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.textDark,
        ),
        displayMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.textDark,
        ),
        displaySmall: AppTextStyles.heading3.copyWith(
          color: AppColors.textDark,
        ),
        headlineLarge: AppTextStyles.heading1.copyWith(
          color: AppColors.textDark,
        ),
        headlineMedium: AppTextStyles.heading2.copyWith(
          color: AppColors.textDark,
        ),
        headlineSmall: AppTextStyles.heading3.copyWith(
          color: AppColors.textDark,
        ),
        titleLarge: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
        titleMedium: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMedium,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMedium,
        ),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.textDark),
        labelMedium: AppTextStyles.label.copyWith(color: AppColors.textMedium),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textLight),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySageGreen, // Bronze
          foregroundColor: AppColors.primaryAccent, // Cream text
          elevation: 2,
          shadowColor: AppColors.primaryDarkBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonHeightM / 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryAccent,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryAccent.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryAccent.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: const BorderSide(color: AppColors.primarySageGreen, width: 1.5),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonHeightM / 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryAccent,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primarySageGreen.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primarySageGreen.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryAccent,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryAccent.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryAccent.withValues(alpha: 0.15);
            }
            return null;
          }),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: AppColors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: AppColors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(
            color: AppColors.primarySageGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: BorderSide(color: AppColors.borderSecondary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMedium,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMedium,
        ),
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primarySageGreen,
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        prefixIconColor: AppColors.textMedium,
        suffixIconColor: AppColors.textMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: AppDimensions.cardElevation,
        shadowColor: AppColors.primaryDarkBlue.withValues(alpha: 0.2),
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingS,
          horizontal: AppDimensions.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1.0,
        space: AppDimensions.paddingM,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 8.0,
        shadowColor: AppColors.primaryDarkBlue.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColors.textDark,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 12.0,
        modalElevation: 16.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusL),
            topRight: Radius.circular(AppDimensions.radiusL),
          ),
        ),
        modalBackgroundColor: AppColors.cardBackground,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading3.copyWith(
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryAccent),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryAccent),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryAccent,
        unselectedLabelColor: AppColors.textMedium,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primarySageGreen, width: 2),
        ),
        labelStyle: AppTextStyles.label.copyWith(
          color: AppColors.primaryAccent,
        ),
        unselectedLabelStyle: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.normal,
          color: AppColors.textMedium,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryGold,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6.0,
        actionTextColor: AppColors.primarySageGreen,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primarySageGreen,
        foregroundColor: AppColors.primaryAccent,
        elevation: 6.0,
        focusElevation: 8.0,
        hoverElevation: 8.0,
        highlightElevation: 12.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        deleteIconColor: AppColors.textMedium,
        disabledColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primarySageGreen.withValues(alpha: 0.3),
        secondarySelectedColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        shadowColor: AppColors.primaryDarkBlue.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark),
        secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textMedium,
        ),
        brightness: Brightness.dark,
        elevation: 2,
        pressElevation: 4,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryAccent;
          }
          return AppColors.textMedium;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySageGreen;
          }
          return AppColors.surfaceContainer;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySageGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primaryAccent),
        side: const BorderSide(color: AppColors.borderPrimary, width: 2),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySageGreen;
          }
          return AppColors.borderPrimary;
        }),
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Material 3 Settings
      useMaterial3: true,

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
