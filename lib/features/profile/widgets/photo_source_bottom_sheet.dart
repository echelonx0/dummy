// lib/features/profile/widgets/photo_source_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';

enum PhotoSource { camera, gallery }

class PhotoSourceBottomSheet extends StatelessWidget {
  final Function(PhotoSource) onSourceSelected;
  final int photoIndex;

  const PhotoSourceBottomSheet({
    super.key,
    required this.onSourceSelected,
    required this.photoIndex,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(PhotoSource) onSourceSelected,
    required int photoIndex,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => PhotoSourceBottomSheet(
            onSourceSelected: onSourceSelected,
            photoIndex: photoIndex,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = photoIndex == 0;

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingXL,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusXL),
            topRight: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),

            // Title
            Text(
              isPrimary ? 'Add Primary Photo' : 'Add Photo',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Description
            Text(
              isPrimary
                  ? 'Your primary photo is the first one people will see. Choose a clear photo where your face is visible.'
                  : 'Add photos that show your lifestyle, interests, and personality.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Animation
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Animation
                  Expanded(
                    child: Lottie.asset(
                      'assets/animations/camera_animation.json',
                      // Fallback to a basic icon if the animation is not available
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.camera_alt_outlined,
                            size: 64,
                            color: AppColors.primaryDarkBlue,
                          ),
                    ),
                  ),

                  // Gallery Animation
                  Expanded(
                    child: Lottie.asset(
                      'assets/animations/gallery_animation.json',
                      // Fallback to a basic icon if the animation is not available
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: AppColors.primaryDarkBlue,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Options
            Row(
              children: [
                // Camera Option
                Expanded(
                  child: _buildAnimatedOption(
                    context,
                    'Camera',
                    Icons.camera_alt_outlined,
                    () => onSourceSelected(PhotoSource.camera),
                    delay: 100,
                  ),
                ),

                const SizedBox(width: AppDimensions.paddingM),

                // Gallery Option
                Expanded(
                  child: _buildAnimatedOption(
                    context,
                    'Gallery',
                    Icons.photo_library_outlined,
                    () => onSourceSelected(PhotoSource.gallery),
                    delay: 200,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    required int delay,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeInOut,
      child: AnimatedSlide(
        offset: const Offset(0, 0),
        duration: Duration(milliseconds: 300 + delay),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingL,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primaryDarkBlue, size: 32),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
