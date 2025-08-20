// lib/features/profile/widgets/profile_edit_selection_modal.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../services/profile_navigation_service.dart';

class ProfileEditSelectionModal extends StatelessWidget {
  const ProfileEditSelectionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileEditSelectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'section': ProfileNavigationService.basicInfo,
        'title': 'Basic Information',
        'subtitle': 'Name, age, location, contact details',
        'icon': Icons.person_outline,
      },
      {
        'section': ProfileNavigationService.photos,
        'title': 'Photos',
        'subtitle': 'Profile pictures and gallery',
        'icon': Icons.camera_alt_outlined,
      },
      {
        'section': ProfileNavigationService.relationshipGoals,
        'title': 'Relationship Goals',
        'subtitle': 'What you\'re looking for, dealbreakers',
        'icon': Icons.favorite_outline,
      },
      {
        'section': ProfileNavigationService.interests,
        'title': 'Interests & Hobbies',
        'subtitle': 'Activities you enjoy, passions',
        'icon': Icons.interests_outlined,
      },
      {
        'section': ProfileNavigationService.lifestyle,
        'title': 'Lifestyle',
        'subtitle': 'Exercise, drinking, smoking, diet',
        'icon': Icons.fitness_center_outlined,
      },
      {
        'section': ProfileNavigationService.deepQuestions,
        'title': 'Deep Questions',
        'subtitle': 'Values, beliefs, life philosophy',
        'icon': Icons.psychology_outlined,
      },
      {
        'section': ProfileNavigationService.prompts,
        'title': 'Conversation Prompts',
        'subtitle': 'Questions to start conversations',
        'icon': Icons.chat_bubble_outline,
      },
      {
        'section': ProfileNavigationService.verification,
        'title': 'Verification',
        'subtitle': 'Verify your identity and profile',
        'icon': Icons.verified_outlined,
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Your Profile',
                    style: AppTextStyles.heading2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.inputBackground,
                  ),
                ),
              ],
            ),
          ),

          // Sections List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
              ),
              itemCount: sections.length,
              separatorBuilder:
                  (context, index) =>
                      const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final section = sections[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                    horizontal: AppDimensions.paddingS,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      section['icon'] as IconData,
                      color: AppColors.primarySageGreen,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    section['title'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    section['subtitle'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ProfileNavigationService.navigateToSection(
                      context,
                      section['section'] as String,
                      isEditMode: true,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Tip
          Container(
            margin: const EdgeInsets.all(AppDimensions.paddingL),
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primarySageGreen,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    'Complete profiles get 5x more quality matches',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primarySageGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
