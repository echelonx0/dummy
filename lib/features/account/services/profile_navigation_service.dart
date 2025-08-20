// lib/features/profile/services/profile_navigation_service.dart
import 'package:flutter/material.dart';

import '../widgets/profile_wrapper.dart';

// Import other profile screens as needed

class ProfileNavigationService {
  static const String basicInfo = 'basic_info';
  static const String relationshipGoals = 'relationship_goals';
  static const String photos = 'photos';
  static const String interests = 'interests';
  static const String lifestyle = 'lifestyle';
  static const String deepQuestions = 'deep_questions';
  static const String prompts = 'prompts';
  static const String verification = 'verification';

  /// Navigate to a specific profile editing section
  /// [isEditMode] determines if we're editing (true) or in onboarding flow (false)
  static void navigateToSection(
    BuildContext context,
    String section, {
    bool isEditMode = true,
    Map<String, dynamic>? additionalData,
  }) {
    Widget destination;

    switch (section) {
      case basicInfo:
        destination = ProfileBasicInfoWrapper(isEditMode: isEditMode);
        break;
      case relationshipGoals:
        destination = ProfileRelationshipGoalsWrapper(isEditMode: isEditMode);
        break;
      // Add other cases as needed
      default:
        throw ArgumentError('Unknown profile section: $section');
    }

    if (isEditMode) {
      // Edit mode: Use modal presentation for better UX
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => destination,
          fullscreenDialog: true, // This creates a modal-style presentation
        ),
      );
    } else {
      // Onboarding mode: Regular navigation
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => destination));
    }
  }

  /// Get user-friendly section names for UI
  static String getSectionDisplayName(String section) {
    switch (section) {
      case basicInfo:
        return 'Basic Information';
      case relationshipGoals:
        return 'Relationship Goals';
      case photos:
        return 'Photos';
      case interests:
        return 'Interests';
      case lifestyle:
        return 'Lifestyle';
      case deepQuestions:
        return 'Deep Questions';
      case prompts:
        return 'Prompts';
      case verification:
        return 'Verification';
      default:
        return section;
    }
  }

  /// Get section icons for UI
  static IconData getSectionIcon(String section) {
    switch (section) {
      case basicInfo:
        return Icons.person_outline;
      case relationshipGoals:
        return Icons.favorite_outline;
      case photos:
        return Icons.camera_alt_outlined;
      case interests:
        return Icons.interests_outlined;
      case lifestyle:
        return Icons.handshake;
      case deepQuestions:
        return Icons.psychology_outlined;
      case prompts:
        return Icons.chat_bubble_outline;
      case verification:
        return Icons.verified_outlined;
      default:
        return Icons.edit_outlined;
    }
  }
}
