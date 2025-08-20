// lib/features/profile/screens/profile_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:khedoo/generated/l10n.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';
import '../widgets/profile_progress_tracker.dart';
import 'profile_basic_info_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen>
    with SingleTickerProviderStateMixin {
  final _authService = locator<AuthService>();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadProfileData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await _authService.getUserProfileData();

      if (mounted) {
        setState(() {
          _profileData = profileData;
          _isLoading = false;
        });

        // Animate progress bar if profile data exists
        if (profileData != null &&
            profileData['completionPercentage'] != null) {
          _animationController.animateTo(
            profileData['completionPercentage'] / 100,
          );
        } else {
          _animationController.animateTo(0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showErrorModal(
          context,
          message: 'Failed to load profile data: ${e.toString()}',
        );
      }
    }
  }

  void _startProfileCreation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileBasicInfoScreen()),
    );
  }

  double _getProfileCompletionPercentage() {
    if (_profileData == null || _profileData!['completionPercentage'] == null) {
      return 0.0;
    }

    return _profileData!['completionPercentage'];
  }

  Map<String, String> _getCompletionStatus() {
    if (_profileData == null || _profileData!['completionStatus'] == null) {
      return {};
    }

    final status = _profileData!['completionStatus'] as Map<String, dynamic>;
    final result = <String, String>{};

    for (final key in status.keys) {
      result[key] = status[key].toString();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.profileCreationTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Description
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          l10n.profileCreationTitle,
                          style: AppTextStyles.heading1,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      DelayedDisplay(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          l10n.profileCreationDesc,
                          style: AppTextStyles.bodyLarge,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Progress Overview
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Profile Progress',
                                style: AppTextStyles.heading3,
                              ),

                              const SizedBox(height: AppDimensions.paddingM),

                              // Overall Progress Bar
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 400),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Overall Completion',
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                        Text(
                                          '${_getProfileCompletionPercentage().toInt()}%',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppColors.primaryDarkBlue,
                                              ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: AppDimensions.paddingS,
                                    ),

                                    // Animated Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusS,
                                      ),
                                      child: AnimatedBuilder(
                                        animation: _progressAnimation,
                                        builder: (context, child) {
                                          return LinearProgressIndicator(
                                            value: _progressAnimation.value,
                                            backgroundColor: AppColors.divider,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(AppColors.primaryDarkBlue),
                                            minHeight: 8,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppDimensions.paddingL),

                              // Section Progress
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 500),
                                child: ProfileProgressTracker(
                                  completionStatus: _getCompletionStatus(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Info Cards
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 600),
                        child: _buildInfoCard(
                          title: 'Why Creating a Complete Profile Matters',
                          content:
                              'Your profile is the foundation of our matching system. The more complete your profile, the better our AI can understand you and find truly compatible matches.',
                          icon: Icons.psychology_outlined,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingL),

                      DelayedDisplay(
                        delay: const Duration(milliseconds: 700),
                        child: _buildInfoCard(
                          title: 'Save and Return Anytime',
                          content:
                              'Profile creation is designed to be thoughtful and can be completed in multiple sessions. Your progress is automatically saved.',
                          icon: Icons.save_outlined,
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXXL),

                      // Begin/Continue Button
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 800),
                        child: CustomButton(
                          text:
                              _getProfileCompletionPercentage() > 0
                                  ? 'Continue Profile Creation'
                                  : 'Begin Profile Creation',
                          onPressed: _startProfileCreation,
                          type: ButtonType.primary,
                          icon: Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 24),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label.copyWith(fontSize: 16)),
                const SizedBox(height: AppDimensions.paddingS),
                Text(content, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
