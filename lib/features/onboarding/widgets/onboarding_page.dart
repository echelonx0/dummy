// lib/features/onboarding/widgets/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';

import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return isPortrait
        ? _buildPortraitLayout(context, screenSize)
        : _buildLandscapeLayout(context, screenSize);
  }

  Widget _buildPortraitLayout(BuildContext context, Size screenSize) {
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundLight, AppColors.backgroundLight],
              ),
            ),
          ),
        ),

        // Content container with scroll capability
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.08),

                // Image with subtle shadow
                DelayedDisplay(
                  delay: Duration(milliseconds: 100 * (pageIndex + 1)),
                  fadingDuration: const Duration(milliseconds: 700),
                  child: Container(
                    height: screenSize.height * 0.40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDarkBlue.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                  ),
                ),

                SizedBox(height: screenSize.height * 0.06),

                // Title with accent decoration
                DelayedDisplay(
                  delay: Duration(milliseconds: 200 * (pageIndex + 1)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Title text
                      Text(
                        title,
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Accent underline
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 120,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXS,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Description with enhanced typography
                DelayedDisplay(
                  delay: Duration(milliseconds: 300 * (pageIndex + 1)),
                  child: Text(
                    description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 20,
                      height: 1.6,
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: screenSize.height * 0.12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, Size screenSize) {
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.backgroundLight, AppColors.backgroundLight],
              ),
            ),
          ),
        ),

        // Main content
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              // Image section with enhanced visual treatment
              Expanded(
                flex: 5,
                child: DelayedDisplay(
                  delay: Duration(milliseconds: 100 * (pageIndex + 1)),
                  fadingDuration: const Duration(milliseconds: 700),
                  child: Container(
                    height: screenSize.height * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDarkBlue.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(5, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              // Text content with enhanced styling
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative element
                      DelayedDisplay(
                        delay: Duration(milliseconds: 150 * (pageIndex + 1)),
                        child: Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXS,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      // Title with enhanced typography
                      DelayedDisplay(
                        delay: Duration(milliseconds: 200 * (pageIndex + 1)),
                        child: Text(
                          title,
                          style: AppTextStyles.heading2.copyWith(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingL),

                      // Description with enhanced styling
                      DelayedDisplay(
                        delay: Duration(milliseconds: 300 * (pageIndex + 1)),
                        child: Text(
                          description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 18,
                            height: 1.6,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Feature items
                      DelayedDisplay(
                        delay: Duration(milliseconds: 400 * (pageIndex + 1)),
                        child: Row(
                          children: [
                            _buildFeatureItem(
                              Icons.psychology,
                              "AI Matchmaking",
                            ),
                            const SizedBox(width: AppDimensions.paddingL),
                            _buildFeatureItem(
                              Icons.favorite,
                              "Deep Connection",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: AppColors.primaryDarkBlue, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.label.copyWith(
            color: AppColors.primaryDarkBlue,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
