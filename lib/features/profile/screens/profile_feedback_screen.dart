// lib/features/profile/screens/profile_feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_email_service.dart';
import '../../../core/services/firebase_service.dart';

import '../../../core/shared/widgets/action_modal_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../generated/l10n.dart';
import '../../../app/locator.dart';
import '../widgets/profile_step_indicator.dart';
import '../widgets/reference_form_widget.dart';
import '../widgets/feedback_explanation_card.dart';
import '../widgets/feedback_privacy_notice.dart';
import 'profile_complete_screen.dart';

class ProfileFeedbackScreen extends StatefulWidget {
  const ProfileFeedbackScreen({super.key});

  @override
  State<ProfileFeedbackScreen> createState() => _ProfileFeedbackScreenState();
}

class _ProfileFeedbackScreenState extends State<ProfileFeedbackScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();
  final _emailService = EmailService();

  bool _isLoading = false;

  // Feedback request data
  List<Map<String, dynamic>> _requestedFeedback = [];
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _emailControllers = [];
  final List<String> _relationshipTypes = [
    'Friend',
    'Family Member',
    'Former Partner',
    'Colleague',
    'Roommate',
  ];
  final List<String> _selectedRelationshipTypes = [];

  String? _currentUserName;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadFeedbackData();

    // Initialize controllers for 3 feedback requests
    for (int i = 0; i < 3; i++) {
      _nameControllers.add(TextEditingController());
      _emailControllers.add(TextEditingController());
      _selectedRelationshipTypes.add(_relationshipTypes[0]);
    }
  }

  @override
  void dispose() {
    // Dispose of all text controllers
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFeedbackData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          // Store user info for emails
          _currentUserName =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          _currentUserEmail = user.email;

          // Check if feedback requests exist
          if (data['pendingFeedbackRequests'] != null &&
              data['pendingFeedbackRequests'] is List) {
            setState(() {
              _requestedFeedback = List<Map<String, dynamic>>.from(
                data['pendingFeedbackRequests'],
              );

              // Fill controllers with existing data if available
              for (int i = 0; i < _requestedFeedback.length && i < 3; i++) {
                final request = _requestedFeedback[i];
                _nameControllers[i].text = request['name'] ?? '';
                _emailControllers[i].text = request['email'] ?? '';
                _selectedRelationshipTypes[i] =
                    request['relationshipType'] ?? _relationshipTypes[0];
              }
            });
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorModal('Failed to load feedback data: ${e.toString()}');
      }
    }
  }

  Future<void> _saveAndContinue() async {
    final l10n = AppLocalizations.of(context);

    // Validate at least one feedback request is filled
    bool hasOneValidRequest = false;

    for (int i = 0; i < 3; i++) {
      final name = _nameControllers[i].text.trim();
      final email = _emailControllers[i].text.trim();

      if (name.isNotEmpty && email.isNotEmpty && Helpers.isValidEmail(email)) {
        hasOneValidRequest = true;
        break;
      }
    }

    if (!hasOneValidRequest) {
      // Show skip confirmation modal
      ActionModalController.show(
        context: context,
        data: ActionModalData(
          headline: l10n.skipFeedbackTitle,
          subheadline: l10n.skipFeedbackMessage,
          ctaText: l10n.skipAnyway,
          onAction: () => _skipFeedbackStep(),
          onDismiss: () {}, // Just close modal
          backgroundColor: AppColors.warning,
        ),
        type: ActionModalType.reminder,
        style: ActionModalStyle.center,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();
      final currentLocale = Localizations.localeOf(context).languageCode;

      if (user != null &&
          _currentUserName != null &&
          _currentUserEmail != null) {
        // Gather valid feedback requests
        final List<Map<String, dynamic>> validRequests = [];

        for (int i = 0; i < 3; i++) {
          final name = _nameControllers[i].text.trim();
          final email = _emailControllers[i].text.trim();
          final relationshipType = _selectedRelationshipTypes[i];

          if (name.isNotEmpty &&
              email.isNotEmpty &&
              Helpers.isValidEmail(email)) {
            final requestCode = Helpers.generateRandomString(20);

            validRequests.add({
              'name': name,
              'email': email,
              'relationshipType': relationshipType,
              'requestDate': Timestamp.now(),
              'status': 'pending',
              'requestCode': requestCode,
            });

            // Send email via Firebase Mail extension
            await _emailService.sendFeedbackRequestEmail(
              userName: _currentUserName!,
              userEmail: _currentUserEmail!,
              referenceName: name,
              referenceEmail: email,
              relationshipType: relationshipType,
              requestCode: requestCode,
              locale: currentLocale,
            );
          }
        }

        // Update profile data in Firestore
        await _firebaseService.updateDocument('profiles', user.uid, {
          'pendingFeedbackRequests': validRequests,
          'completionStatus.thirdPartyFeedback': 'completed',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
          'isProfileComplete': true,
        });

        if (mounted) {
          setState(() => _isLoading = false);

          // Show success modal
          ActionModalController.show(
            context: context,
            data: ActionModalData(
              headline: l10n.feedbackRequestsSent,
              subheadline: l10n.feedbackRequestsSuccess,
              ctaText: l10n.completeProfile,
              onAction: () => _navigateToCompletion(),
              illustration: const Icon(
                Icons.mark_email_read,
                size: 80,
                color: Colors.white,
              ),
              backgroundColor: AppColors.success,
            ),
            type: ActionModalType.achievement,
            style: ActionModalStyle.card,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorModal('Failed to save feedback requests: ${e.toString()}');
      }
    }
  }

  Future<void> _skipFeedbackStep() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update profile data in Firestore to mark this step as skipped
        await _firebaseService.updateDocument('profiles', user.uid, {
          'completionStatus.thirdPartyFeedback': 'skipped',
          'completionPercentage': FieldValue.increment(12.5),
          'lastUpdated': Timestamp.now(),
          'isProfileComplete': true, // Mark profile as complete
        });

        if (mounted) {
          setState(() => _isLoading = false);
          _navigateToCompletion();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorModal('Failed to skip feedback step: ${e.toString()}');
      }
    }
  }

  void _navigateToCompletion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ProfileCompleteScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  void _showErrorModal(String message) {
    ActionModalController.show(
      context: context,
      data: ActionModalData(
        headline: 'Error',
        subheadline: message,
        ctaText: 'Try Again',
        onAction: () => _loadFeedbackData(),
        backgroundColor: AppColors.error,
      ),
      type: ActionModalType.custom,
      style: ActionModalStyle.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.feedbackScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Step Indicator
                    const ProfileStepIndicator(currentStep: 8, totalSteps: 8),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Description
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 100),
                              child: Text(
                                l10n.feedbackScreenTitle,
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            DelayedDisplay(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                l10n.feedbackScreenSubtitle,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Explanation Card
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 300),
                              child: const FeedbackExplanationCard(),
                            ),

                            const SizedBox(height: AppDimensions.paddingXL),

                            // Feedback Request Forms
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 400),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingL,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.cardBackground,
                                      AppColors.primaryGold.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primarySageGreen
                                        .withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryDarkBlue
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.requestReferences,
                                      style: AppTextStyles.heading3.copyWith(
                                        fontSize: 18,
                                        color: AppColors.textDark,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingM,
                                    ),

                                    Text(
                                      l10n.requestReferencesDesc,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textMedium,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingL,
                                    ),

                                    // Reference Forms
                                    ...List.generate(3, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              index < 2
                                                  ? AppDimensions.paddingL
                                                  : 0,
                                        ),
                                        child: ReferenceFormWidget(
                                          index: index,
                                          title: _getReferenceTitle(
                                            l10n,
                                            index,
                                          ),
                                          nameController:
                                              _nameControllers[index],
                                          emailController:
                                              _emailControllers[index],
                                          relationshipTypes: _relationshipTypes,
                                          selectedRelationshipType:
                                              _selectedRelationshipTypes[index],
                                          onRelationshipTypeChanged: (
                                            String? newValue,
                                          ) {
                                            if (newValue != null) {
                                              setState(() {
                                                _selectedRelationshipTypes[index] =
                                                    newValue;
                                              });
                                            }
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingL),

                            // Privacy Notice
                            DelayedDisplay(
                              delay: const Duration(milliseconds: 500),
                              child: const FeedbackPrivacyNotice(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Button Bar
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.backgroundLight.withValues(alpha: 0),
                            AppColors.backgroundLight.withValues(alpha: 0.8),
                            AppColors.backgroundLight,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDarkBlue.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: DelayedDisplay(
                        delay: const Duration(milliseconds: 600),
                        child: Row(
                          children: [
                            // Skip Button
                            Expanded(
                              child: CustomButton(
                                text: l10n.skip,
                                onPressed: () => _skipFeedbackStep(),
                                type: ButtonType.secondary,
                              ),
                            ),

                            const SizedBox(width: AppDimensions.paddingM),

                            // Submit Button
                            Expanded(
                              flex: 2,
                              child: CustomButton(
                                text: l10n.sendRequests,
                                onPressed: _saveAndContinue,
                                isLoading: _isLoading,
                                type: ButtonType.primary,
                                icon: Icons.send,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  String _getReferenceTitle(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.reference1;
      case 1:
        return l10n.reference2;
      case 2:
        return l10n.reference3;
      default:
        return 'Reference ${index + 1}';
    }
  }
}
