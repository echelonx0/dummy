// lib/features/profile/screens/profile_photo_upload_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:khedoo/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../profile/widgets/profile_step_indicator.dart';
import '../providers/photo_upload_provider.dart';
import '../services/profile_service.dart';
import '../widgets/photo_grid.dart';
import '../widgets/photo_source_bottom_sheet.dart';
import '../widgets/photo_preview_screen.dart';
import 'package:flutter/services.dart';

import 'profile_core_values_screen.dart';

// Wrap the screen with a provider at the route level
class ProfilePhotoUploadScreenWrapper extends StatelessWidget {
  const ProfilePhotoUploadScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => PhotoUploadProvider(
            userId: FirebaseAuth.instance.currentUser!.uid,
          ),
      child: const ProfilePhotoUploadScreen(),
    );
  }
}

class ProfilePhotoUploadScreen extends StatefulWidget {
  const ProfilePhotoUploadScreen({super.key});

  @override
  State<ProfilePhotoUploadScreen> createState() =>
      _ProfilePhotoUploadScreenState();
}

class _ProfilePhotoUploadScreenState extends State<ProfilePhotoUploadScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _loadingAnimationController;
  final ProfileService _profileService = ProfileService();
  // Define the current step in onboarding flow
  final int _currentStep = 2;
  final int _totalSteps = 8;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPhotos();
    });
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  // Load existing photos if available
  Future<void> _loadExistingPhotos() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null && profile.containsKey('photos')) {
        final List<dynamic> photos = profile['photos'] as List<dynamic>;
        if (photos.isNotEmpty) {
          Provider.of<PhotoUploadProvider>(
            context,
            listen: false,
          ).loadExistingPhotos(photos.cast<String>());
        }
      }
    } catch (e) {
      print('Error loading existing photos: $e');
    }
  }

  Future<void> _handleSaveAndContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<PhotoUploadProvider>(context, listen: false);

      // 2. Collect all photo URLs (both new uploads and existing remote photos)
      final List<String> allPhotoUrls = [];

      // Add primary photo first if it exists
      if (provider.primaryPhoto.exists) {
        final primaryPhotoUrl = provider.primaryPhoto.url;
        if (primaryPhotoUrl != null && primaryPhotoUrl.isNotEmpty) {
          allPhotoUrls.add(primaryPhotoUrl);
        }
      }

      // Add additional photos
      for (final photo in provider.additionalPhotos) {
        if (photo.exists && photo.url != null && photo.url!.isNotEmpty) {
          allPhotoUrls.add(photo.url!);
        }
      }

      // 3. Save photo URLs to user profile
      await _profileService.savePhotosToProfile(allPhotoUrls);

      // 4. Save onboarding progress
      await _profileService.saveOnboardingProgress(_currentStep);

      // 5. Navigate to next screen
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => const ProfileCoreValuesScreen(), // Next screen in flow
      ),
    );
  }

  void _skipAndContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save empty photos array to profile
      await _profileService.savePhotosToProfile([]);

      // Mark section as skipped in completionStatus
      await _profileService.saveOnboardingProgress(_currentStep);

      // Navigate to next screen
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error skipping: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPhotoSourceBottomSheet(int index) {
    PhotoSourceBottomSheet.show(
      context,
      onSourceSelected: (source) {
        final provider = Provider.of<PhotoUploadProvider>(
          context,
          listen: false,
        );

        if (source == PhotoSource.camera) {
          provider.addPhotoFromCamera(index);
        } else {
          provider.addPhotoFromGallery(index);
        }
      },
      photoIndex: index,
    );
  }

  void _showPhotoPreview(int index) {
    final provider = Provider.of<PhotoUploadProvider>(context, listen: false);
    final photo = provider.photos[index];

    // Only show preview if there's a photo to preview
    if (photo.exists) {
      PhotoPreviewScreen.show(
        context,
        photo: photo,
        onDelete: () => provider.removePhoto(index),
        onReplace: () => _showPhotoSourceBottomSheet(index),
      );
    } else {
      // If no photo exists, go straight to the source selection
      _showPhotoSourceBottomSheet(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.uploadPhotosTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            ProfileStepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),

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
                        l10n.uploadPhotosTitle,
                        style: AppTextStyles.heading2,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingM),

                    DelayedDisplay(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        l10n.uploadPhotosDesc,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Photo Upload Grid
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 300),
                      child: Consumer<PhotoUploadProvider>(
                        builder: (context, provider, child) {
                          // Show error if any
                          if (provider.error != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error!),
                                  action: SnackBarAction(
                                    label: 'Dismiss',
                                    onPressed: () {
                                      provider.clearError();
                                    },
                                  ),
                                ),
                              );
                              // Clear error after showing
                              provider.clearError();
                            });
                          }

                          return PhotoGrid(
                            photos: provider.photos,
                            onPhotoTap: _showPhotoPreview,
                            onPhotoDelete: provider.removePhoto,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXXL),

                    // Photo Guidelines
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        decoration: BoxDecoration(
                          color: AppColors.primarySageGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo Guidelines',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: AppDimensions.paddingM),

                            _buildGuideline(
                              'Choose clear, recent photos that show your face',
                              Icons.check_circle_outline,
                            ),

                            _buildGuideline(
                              'Include a mix of close-up and full-body photos',
                              Icons.check_circle_outline,
                            ),

                            _buildGuideline(
                              'Add photos showing your interests and lifestyle',
                              Icons.check_circle_outline,
                            ),

                            _buildGuideline(
                              'Avoid group photos where you\'re hard to identify',
                              Icons.cancel_outlined,
                              isPositive: false,
                            ),

                            _buildGuideline(
                              'Don\'t use heavily filtered or edited photos',
                              Icons.cancel_outlined,
                              isPositive: false,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Photo upload tip
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: AppDimensions.paddingL,
                        ),
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(
                            color: AppColors.primaryDarkBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              color: AppColors.primaryDarkBlue,
                              size: 24,
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Expanded(
                              child: Text(
                                'Profiles with 3+ photos receive 50% more interactions! Tap a photo to see a larger preview.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button Bar
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: DelayedDisplay(
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    // Skip Button
                    Expanded(
                      child: CustomButton(
                        text: l10n.skip,
                        onPressed: () {
                          // Show confirmation dialog
                          _showSkipConfirmation(context);
                        },
                        type: ButtonType.text,
                      ),
                    ),

                    const SizedBox(width: AppDimensions.paddingM),

                    // Continue Button
                    Expanded(
                      flex: 2,
                      child: Consumer<PhotoUploadProvider>(
                        builder: (context, provider, child) {
                          // Determine if we should show a warning
                          final bool showWarning = !provider.hasPrimaryPhoto;

                          return CustomButton(
                            text: 'Save & Continue',
                            onPressed: () {
                              if (showWarning) {
                                // Show warning about missing primary photo
                                _showPrimaryPhotoWarning(context);
                              } else {
                                // Proceed with upload
                                _handleSaveAndContinue();
                              }
                            },
                            isLoading: _isLoading,
                            type: ButtonType.primary,
                            icon: Icons.arrow_forward,
                          );
                        },
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

  // Show confirmation dialog for skipping
  void _showSkipConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Skip Photo Upload?',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
            ),
            content: Text(
              'Photos help people get to know you better and significantly increase your chances of making a connection. Are you sure you want to skip this step?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _skipAndContinue(); // Skip and continue to next screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Yes, Skip'),
              ),
            ],
          ),
    );
  }

  // Show warning about missing primary photo
  void _showPrimaryPhotoWarning(BuildContext context) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    'Missing Primary Photo',
                    style: AppTextStyles.heading3,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your primary photo is the first impression people will have of you. Profiles with primary photos receive significantly more interest.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Add Primary Photo',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _handleSaveAndContinue(); // Proceed anyway
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
    );
  }

  Widget _buildGuideline(String text, IconData icon, {bool isPositive = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
