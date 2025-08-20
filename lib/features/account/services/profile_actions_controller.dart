// lib/features/profile/controllers/profile_actions_controller.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../auth/screens/modern_login_screen.dart';
import 'profile_navigation_service.dart';
import '../../profile/settings/delete_modal.dart';
import '../screens/profile_edit_modal.dart';
import '../services/profile_management_screen.dart';

class ProfileActionsController {
  final BuildContext context;
  final ProfileManagementService service;

  ProfileActionsController({required this.context, required this.service});

  // Navigation Actions
  void editProfile() {
    // Show selection modal for what to edit
    ProfileEditSelectionModal.show(context);
  }

  void editBasicInfo() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.basicInfo,
      isEditMode: true,
    );
  }

  void editPreferences() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.relationshipGoals,
      isEditMode: true,
    );
  }

  void editPhotos() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.photos,
      isEditMode: true,
    );
  }

  void editInterests() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.interests,
      isEditMode: true,
    );
  }

  void editLifestyle() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.lifestyle,
      isEditMode: true,
    );
  }

  void editDeepQuestions() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.deepQuestions,
      isEditMode: true,
    );
  }

  void editPrompts() {
    ProfileNavigationService.navigateToSection(
      context,
      ProfileNavigationService.prompts,
      isEditMode: true,
    );
  }

  void managePrivacy() {
    // TODO: Navigate to privacy settings
    debugPrint('Navigate to privacy settings');
  }

  void manageVisibility() {
    // TODO: Navigate to visibility settings
    debugPrint('Navigate to visibility settings');
  }

  void manageNotifications() {
    // TODO: Navigate to notification settings
    debugPrint('Navigate to notifications');
  }

  void openSupport() {
    // TODO: Open support/help screen
    debugPrint('Open support');
  }

  void improveProfile() {
    // Show modal with improvement suggestions
    _showProfileImprovementModal();
  }

  void viewTrustScoreDetails() {
    // TODO: Show detailed trust score breakdown
    debugPrint('Show trust score details');
  }

  // Account Actions
  void signOut() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await service.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDarkBlue,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  void deleteAccount() {
    DeleteAccountModal.show(context);
  }

  // Private Methods
  void _showProfileImprovementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ProfileImprovementModal(
            onSectionSelected: (section) {
              Navigator.pop(context);
              ProfileNavigationService.navigateToSection(
                context,
                section,
                isEditMode: true,
              );
            },
          ),
    );
  }

  // Helper Methods
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primarySageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Modal for profile improvement suggestions
class ProfileImprovementModal extends StatelessWidget {
  final Function(String) onSectionSelected;

  const ProfileImprovementModal({super.key, required this.onSectionSelected});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {
        'section': ProfileNavigationService.photos,
        'title': 'Add More Photos',
        'description': 'Profiles with 4+ photos get 3x more matches',
        'priority': 'High',
      },
      {
        'section': ProfileNavigationService.prompts,
        'title': 'Complete Prompts',
        'description': 'Thoughtful prompts increase conversation starters',
        'priority': 'Medium',
      },
      {
        'section': ProfileNavigationService.verification,
        'title': 'Verify Your Profile',
        'description': 'Verified profiles are trusted 5x more',
        'priority': 'High',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Improve Your Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...suggestions.map(
            (suggestion) => ListTile(
              leading: Icon(
                ProfileNavigationService.getSectionIcon(
                  suggestion['section'] as String,
                ),
                color:
                    suggestion['priority'] == 'High'
                        ? AppColors.error
                        : AppColors.primaryDarkBlue,
              ),
              title: Text(suggestion['title'] as String),
              subtitle: Text(suggestion['description'] as String),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      suggestion['priority'] == 'High'
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primaryDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion['priority'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        suggestion['priority'] == 'High'
                            ? AppColors.error
                            : AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onTap: () => onSectionSelected(suggestion['section'] as String),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
