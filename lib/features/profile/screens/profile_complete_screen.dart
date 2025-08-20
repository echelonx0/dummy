// lib/features/profile/screens/profile_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:lottie/lottie.dart';
import '../../../app/app_nav.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/assets.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../app/locator.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  String? _userName;
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Get user name
        if (user.displayName != null) {
          final nameParts = user.displayName!.split(' ');
          if (nameParts.isNotEmpty) {
            setState(() {
              _userName = nameParts.first;
            });
          }
        }

        // Get profile data
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          setState(() {
            _profileData = profileDoc.data() as Map<String, dynamic>;
          });
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getProfileCompletionText() {
    if (_profileData == null) return '';

    final completionPercentage = _profileData!['completionPercentage'] ?? 0.0;

    if (completionPercentage >= 100) {
      return '100% Complete - All sections filled out';
    } else if (completionPercentage >= 87.5) {
      return '${completionPercentage.toInt()}% Complete - Great job!';
    } else {
      return '${completionPercentage.toInt()}% Complete';
    }
  }

  String _getAttachmentStyleText() {
    if (_profileData == null) return '';

    final attachmentStyle = _profileData!['attachmentStyle'];

    switch (attachmentStyle) {
      case 'secure':
        return 'Secure attachment style';
      case 'anxious':
        return 'Anxious attachment style';
      case 'avoidant':
        return 'Avoidant attachment style';
      default:
        return '';
    }
  }

  String _getCommunicationStyleText() {
    if (_profileData == null) return '';

    final communicationStyle = _profileData!['communicationStyle'];

    switch (communicationStyle) {
      case 'direct':
        return 'Direct communicator';
      case 'expressive':
        return 'Expressive communicator';
      case 'reflective':
        return 'Reflective communicator';
      case 'analytical':
        return 'Analytical communicator';
      case 'considerate':
        return 'Considerate communicator';
      default:
        return '';
    }
  }

  void _navigateToDashboard() {
    // Navigate to the dashboard or main app screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 600,
                        minHeight: size.height - 2 * AppDimensions.paddingL,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Success Image
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 100),
                            child: Lottie.asset(
                              Assets
                                  .successAnimation, // This should be a success image or animation
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),

                          // Congratulations Text
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Congratulations${_userName != null ? ', $_userName' : ''}!',
                              style: AppTextStyles.heading1,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          // Subtitle
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              'Your profile is now complete',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppColors.textMedium,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXXL),

                          // Profile Summary Card
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingL,
                              ),
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
                                children: [
                                  Text(
                                    'Profile Summary',
                                    style: AppTextStyles.heading3,
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  // Profile Stats
                                  _buildProfileStat(
                                    Icons.check_circle_outline,
                                    'Completion',
                                    _getProfileCompletionText(),
                                    AppColors.success,
                                  ),

                                  const Divider(
                                    height: AppDimensions.paddingXL,
                                  ),

                                  _buildProfileStat(
                                    Icons.favorite_border,
                                    'Relationship Type',
                                    _profileData?['relationshipType'] ??
                                        'Not specified',
                                    AppColors.primaryGold,
                                  ),

                                  const Divider(
                                    height: AppDimensions.paddingXL,
                                  ),

                                  _buildProfileStat(
                                    Icons.psychology_outlined,
                                    'Attachment Style',
                                    _getAttachmentStyleText(),
                                    AppColors.primaryDarkBlue,
                                  ),

                                  const Divider(
                                    height: AppDimensions.paddingXL,
                                  ),

                                  _buildProfileStat(
                                    Icons.chat_bubble_outline,
                                    'Communication Style',
                                    _getCommunicationStyleText(),
                                    AppColors.primarySageGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXL),

                          // Next Steps Card
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 500),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingL,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDarkBlue.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: AppColors.primaryDarkBlue,
                                        size: 24,
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.paddingM,
                                      ),
                                      Text(
                                        'What happens next?',
                                        style: AppTextStyles.heading3.copyWith(
                                          color: AppColors.primaryDarkBlue,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: AppDimensions.paddingL,
                                  ),

                                  _buildNextStep(
                                    1,
                                    'Our AI will analyze your profile',
                                    'We\'ll generate insights about your relationship patterns and compatibility factors.',
                                  ),

                                  _buildNextStep(
                                    2,
                                    'We\'ll identify potential matches',
                                    'Based on psychological compatibility, our AI will suggest people who complement your personality.',
                                  ),

                                  _buildNextStep(
                                    3,
                                    'Our AI matchmaker will facilitate introductions',
                                    'You\'ll get to know potential matches through guided conversations before deciding to connect directly.',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppDimensions.paddingXXL),

                          // Continue Button
                          DelayedDisplay(
                            delay: const Duration(milliseconds: 600),
                            child: CustomButton(
                              text: 'Continue to Dashboard',
                              onPressed: _navigateToDashboard,
                              type: ButtonType.primary,
                              icon: Icons.arrow_forward,
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

  Widget _buildProfileStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: AppDimensions.paddingM),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                ),
              ),

              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.paddingM),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXS),

                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
