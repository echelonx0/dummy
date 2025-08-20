// lib/shared/components/action_modal_system.dart

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

enum ActionModalType {
  referral,
  premium,
  feature,
  onboarding,
  achievement,
  reminder,
  survey,
  custom,
}

enum ActionModalStyle {
  card, // Uber Eats style card
  fullOverlay, // Full screen takeover
  bottomSheet, // Slides up from bottom
  center, // Center modal
}

class ActionModalData {
  final String headline;
  final String? subheadline;
  final String ctaText;
  final VoidCallback onAction;
  final VoidCallback? onDismiss;
  final Widget? illustration;
  final Color? backgroundColor;
  final Color? accentColor;
  final List<Color>? gradientColors;
  final String? badge;
  final bool isDismissible;
  final Duration? autoHideAfter;

  const ActionModalData({
    required this.headline,
    this.subheadline,
    required this.ctaText,
    required this.onAction,
    this.onDismiss,
    this.illustration,
    this.backgroundColor,
    this.accentColor,
    this.gradientColors,
    this.badge,
    this.isDismissible = true,
    this.autoHideAfter,
  });
}

class ActionModalController {
  static void show({
    required BuildContext context,
    required ActionModalData data,
    ActionModalStyle style = ActionModalStyle.card,
    ActionModalType? type,
  }) {
    switch (style) {
      case ActionModalStyle.card:
        _showCardModal(context, data, type);
        break;
      case ActionModalStyle.fullOverlay:
        _showFullOverlay(context, data, type);
        break;
      case ActionModalStyle.bottomSheet:
        _showBottomSheet(context, data, type);
        break;
      case ActionModalStyle.center:
        _showCenterModal(context, data, type);
        break;
    }
  }

  static void _showCardModal(
    BuildContext context,
    ActionModalData data,
    ActionModalType? type,
  ) {
    showDialog(
      context: context,
      barrierDismissible: data.isDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => ActionModalCard(data: data, type: type),
    );
  }

  static void _showFullOverlay(
    BuildContext context,
    ActionModalData data,
    ActionModalType? type,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, _, __) => ActionModalOverlay(data: data, type: type),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static void _showBottomSheet(
    BuildContext context,
    ActionModalData data,
    ActionModalType? type,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionModalBottomSheet(data: data, type: type),
    );
  }

  static void _showCenterModal(
    BuildContext context,
    ActionModalData data,
    ActionModalType? type,
  ) {
    showDialog(
      context: context,
      barrierDismissible: data.isDismissible,
      builder: (context) => ActionModalCenter(data: data, type: type),
    );
  }
}

// Card Modal (Uber Eats style)
class ActionModalCard extends StatelessWidget {
  final ActionModalData data;
  final ActionModalType? type;

  const ActionModalCard({super.key, required this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient:
              data.gradientColors != null
                  ? LinearGradient(
                    colors: data.gradientColors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: data.backgroundColor ?? _getTypeColor(type),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge (optional)
                  if (data.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Text(
                        data.badge!,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                  ],

                  // Illustration
                  if (data.illustration != null) ...[
                    SizedBox(height: 120, child: data.illustration!),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],

                  // Headline
                  Text(
                    data.headline,
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Subheadline
                  if (data.subheadline != null) ...[
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      data.subheadline!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.paddingL),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        data.onAction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            data.accentColor ?? _getTypeColor(type),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.ctaText,
                            style: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: data.accentColor ?? _getTypeColor(type),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Close button
            if (data.isDismissible)
              Positioned(
                top: AppDimensions.paddingM,
                right: AppDimensions.paddingM,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    data.onDismiss?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ActionModalType? type) {
    switch (type) {
      case ActionModalType.referral:
        return AppColors.primaryAccent;
      case ActionModalType.premium:
        return AppColors.primaryGold;
      case ActionModalType.feature:
        return AppColors.primarySageGreen;
      case ActionModalType.onboarding:
        return AppColors.primaryDarkBlue;
      case ActionModalType.achievement:
        return AppColors.success;
      case ActionModalType.reminder:
        return AppColors.primaryGold;
      case ActionModalType.survey:
        return AppColors.info;
      default:
        return AppColors.primaryDarkBlue;
    }
  }
}

// Bottom Sheet Modal
class ActionModalBottomSheet extends StatelessWidget {
  final ActionModalData data;
  final ActionModalType? type;

  const ActionModalBottomSheet({super.key, required this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            data.gradientColors != null
                ? LinearGradient(
                  colors: data.gradientColors!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                : null,
        color: data.backgroundColor ?? _getTypeColor(type),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Illustration
              if (data.illustration != null) ...[
                SizedBox(height: 100, child: data.illustration!),
                const SizedBox(height: AppDimensions.paddingL),
              ],

              // Content
              Text(
                data.headline,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              if (data.subheadline != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  data.subheadline!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppDimensions.paddingL),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    data.onAction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _getTypeColor(type),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingL,
                    ),
                  ),
                  child: Text(
                    data.ctaText,
                    style: AppTextStyles.button.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ActionModalType? type) {
    switch (type) {
      case ActionModalType.referral:
        return AppColors.primaryAccent;
      case ActionModalType.premium:
        return AppColors.primaryGold;
      case ActionModalType.feature:
        return AppColors.primarySageGreen;
      case ActionModalType.onboarding:
        return AppColors.primaryDarkBlue;
      case ActionModalType.achievement:
        return AppColors.success;
      case ActionModalType.reminder:
        return AppColors.primaryGold;
      case ActionModalType.survey:
        return AppColors.info;
      default:
        return AppColors.primaryDarkBlue;
    }
  }
}

// Full Overlay Modal
class ActionModalOverlay extends StatelessWidget {
  final ActionModalData data;
  final ActionModalType? type;

  const ActionModalOverlay({super.key, required this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              data.gradientColors != null
                  ? LinearGradient(
                    colors: data.gradientColors!,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                  : null,
          color: data.backgroundColor ?? _getTypeColor(type),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Close button
                if (data.isDismissible)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        data.onDismiss?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),

                const Spacer(),

                // Illustration
                if (data.illustration != null) ...[
                  SizedBox(height: 200, child: data.illustration!),
                  const SizedBox(height: AppDimensions.paddingXL),
                ],

                // Content
                Text(
                  data.headline,
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (data.subheadline != null) ...[
                  const SizedBox(height: AppDimensions.paddingL),
                  Text(
                    data.subheadline!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const Spacer(),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      data.onAction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _getTypeColor(type),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingL,
                      ),
                    ),
                    child: Text(
                      data.ctaText,
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ActionModalType? type) {
    switch (type) {
      case ActionModalType.referral:
        return AppColors.primaryAccent;
      case ActionModalType.premium:
        return AppColors.primaryGold;
      case ActionModalType.feature:
        return AppColors.primarySageGreen;
      case ActionModalType.onboarding:
        return AppColors.primaryDarkBlue;
      case ActionModalType.achievement:
        return AppColors.success;
      case ActionModalType.reminder:
        return AppColors.primaryGold;
      case ActionModalType.survey:
        return AppColors.info;
      default:
        return AppColors.primaryDarkBlue;
    }
  }
}

// Center Modal
// Center Modal - FIXED VERSION
class ActionModalCenter extends StatelessWidget {
  final ActionModalData data;
  final ActionModalType? type;

  const ActionModalCenter({super.key, required this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            if (data.illustration != null) ...[
              SizedBox(height: 100, child: data.illustration!),
              const SizedBox(height: AppDimensions.paddingL),
            ],

            // Content
            Text(
              data.headline,
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            if (data.subheadline != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                data.subheadline!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppDimensions.paddingL),

            // ✅ FIXED: Primary action button (full width, on top)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  data.onAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTypeColor(type),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingL,
                  ),
                ),
                child: Text(
                  data.ctaText,
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ✅ FIXED: Cancel button (subtle text button, below) - only if dismissible
            if (data.isDismissible) ...[
              const SizedBox(
                height: AppDimensions.paddingM,
              ), // ✅ Added proper spacing
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  data.onDismiss?.call();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                    horizontal: AppDimensions.paddingL,
                  ),
                  minimumSize: const Size(0, 40), // ✅ Smaller height
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    // ✅ Smaller text style
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ActionModalType? type) {
    switch (type) {
      case ActionModalType.referral:
        return AppColors.primaryAccent;
      case ActionModalType.premium:
        return AppColors.primaryGold;
      case ActionModalType.feature:
        return AppColors.primarySageGreen;
      case ActionModalType.onboarding:
        return AppColors.primaryDarkBlue;
      case ActionModalType.achievement:
        return AppColors.success;
      case ActionModalType.reminder:
        return AppColors.primaryGold;
      case ActionModalType.survey:
        return AppColors.info;
      default:
        return AppColors.primaryDarkBlue;
    }
  }
}
