// lib/features/onboarding/screens/not_ready_yet_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/shared/widgets/action_modal_widget.dart';
import '../../../generated/l10n.dart';
import '../../../core/shared/widgets/custom_button.dart';
import 'email_capture_sheet.dart';

class NotReadyYetScreen extends StatefulWidget {
  final List<String> userAnswers;

  const NotReadyYetScreen({super.key, required this.userAnswers});

  @override
  State<NotReadyYetScreen> createState() => _NotReadyYetScreenState();
}

class _NotReadyYetScreenState extends State<NotReadyYetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _showNotifyOption = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Show notify option after emotional processing time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotifyOption = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ FIXED: Added proper scrolling
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            // ✅ FIXED: Ensure minimum height for layout
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  // ✅ FIXED: Flexible spacer instead of Spacer()
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // Main content with animations
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // Gentle icon
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primarySageGreen.withValues(
                                  alpha: 0.2,
                                ),
                                AppColors.primaryAccent.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 48,
                            color: AppColors.primarySageGreen,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingXL),

                        // Warm, understanding headline
                        Text(
                          l10n.notReadyYetTitle,
                          style: AppTextStyles.heading1.copyWith(
                            fontWeight: FontWeight.w300,
                            color: AppColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Empathetic explanation
                        Text(
                          l10n.notReadyYetExplanation,
                          style: AppTextStyles.bodyLarge.copyWith(
                            height: 1.6,
                            color: AppColors.textMedium,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppDimensions.paddingXL),

                        // What "ready" looks like
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            border: Border.all(
                              color: AppColors.primarySageGreen.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.successfulMembersTitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                              _buildReadinessItem(l10n.readinessCriteria1),
                              _buildReadinessItem(l10n.readinessCriteria2),
                              _buildReadinessItem(l10n.readinessCriteria3),
                              _buildReadinessItem(l10n.readinessCriteria4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ FIXED: Flexible spacer instead of Spacer()
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // Action buttons with delayed appearance
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 1000),
                    child: Column(
                      children: [
                        // Primary: Graceful exit
                        CustomButton(
                          text: l10n.understandTakeMeBack,
                          onPressed: () => _handleGracefulExit(),
                          type: ButtonType.primary,
                          isFullWidth: true,
                        ),

                        const SizedBox(height: AppDimensions.paddingM),

                        // Secondary: Future opportunity
                        if (_showNotifyOption)
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: child,
                              );
                            },
                            child: CustomButton(
                              text: l10n.notifyWhenReady,
                              onPressed: () => _handleNotifyRequest(),
                              type: ButtonType.secondary,
                              isFullWidth: true,
                            ),
                          ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Subtle encouragement
                        Text(
                          l10n.selfRespectMessage,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMedium,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // ✅ FIXED: Bottom padding for scroll clearance
                        const SizedBox(height: AppDimensions.paddingXL),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySageGreen,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGracefulExit() {
    // Analytics: Track rejection reason
    _trackRejectionReason();

    // Navigate back to app store or main site
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleNotifyRequest() {
    final l10n = AppLocalizations.of(context);

    ActionModalController.show(
      context: context,
      style: ActionModalStyle.center,
      type: ActionModalType.reminder,
      data: ActionModalData(
        headline: l10n.notifyModalTitle,
        subheadline: l10n.notifyModalDescription,
        ctaText: l10n.setReminder,
        onAction: () => _showEmailCapture(),
        backgroundColor: AppColors.primarySageGreen,
        accentColor: AppColors.primaryAccent,
        illustration: Icon(
          Icons.email_outlined,
          size: 64,
          color: AppColors.primaryAccent,
        ),
      ),
    );
  }

  void _showEmailCapture() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EmailCaptureBottomSheet(
            onEmailSubmitted: (email) => _saveEmailForFutureOutreach(email),
          ),
    );
  }

  Future<void> _saveEmailForFutureOutreach(String email) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Save to Firestore notyetready collection
      await FirebaseFirestore.instance.collection('notyetready').add({
        'email': email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'userAnswers': widget.userAnswers,
        'notifiedAt': null,
        'status': 'pending', // pending, notified, converted
        'source': 'readiness_assessment',
        'locale': Localizations.localeOf(context).languageCode,
      });

      // Analytics: Track future conversion opportunity
      _trackEmailCapture(email);

      Navigator.of(context).popUntil((route) => route.isFirst);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.emailSavedConfirmation,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),
          backgroundColor: AppColors.primarySageGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // Handle error gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving email. Please try again.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _trackRejectionReason() {
    // Analyze user answers to improve filtering
    // Track common rejection patterns
  }

  void _trackEmailCapture(String email) {
    // Track email capture for future campaigns
  }
}
