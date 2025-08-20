// lib/core/models/onboarding_data.dart
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

class OnboardingPageData {
  final String image;
  final String? titleKey;
  final String? descriptionKey;
  final String? customTitle;
  final String? customDescription;
  final List<String>? featureKeys; // ✅ CHANGED: Now uses localization keys
  final IconData? featureIcon;

  const OnboardingPageData({
    required this.image,
    this.titleKey,
    this.descriptionKey,
    this.customTitle,
    this.customDescription,
    this.featureKeys, // ✅ CHANGED: Renamed from features to featureKeys
    this.featureIcon,
  }) : assert(
         (titleKey != null && customTitle == null) ||
             (titleKey == null && customTitle != null),
         'Either provide titleKey or customTitle, not both',
       );

  String getTitle(AppLocalizations l10n) {
    return customTitle ?? _getLocalizedTitle(l10n);
  }

  String getDescription(AppLocalizations l10n) {
    return customDescription ?? _getLocalizedDescription(l10n);
  }

  // ✅ ADDED: Method to get localized features
  List<String> getFeatures(AppLocalizations l10n) {
    if (featureKeys == null) return [];
    return featureKeys!.map((key) => _getLocalizedFeature(l10n, key)).toList();
  }

  String _getLocalizedTitle(AppLocalizations l10n) {
    switch (titleKey) {
      case 'onboardingTitle1':
        return l10n.onboardingTitle1;
      case 'onboardingTitle2':
        return l10n.onboardingTitle2;
      case 'onboardingTitle3':
        return l10n.onboardingTitle3;
      default:
        return l10n
            .missingLocalization; // ✅ FIXED: Now uses localized error message
    }
  }

  String _getLocalizedDescription(AppLocalizations l10n) {
    switch (descriptionKey) {
      case 'onboardingDesc1':
        return l10n.onboardingDesc1;
      case 'onboardingDesc2':
        return l10n.onboardingDesc2;
      case 'onboardingDesc3':
        return l10n.onboardingDesc3;
      default:
        return l10n
            .missingLocalization; // ✅ FIXED: Now uses localized error message
    }
  }

  // ✅ ADDED: Method to get localized feature text
  String _getLocalizedFeature(AppLocalizations l10n, String featureKey) {
    switch (featureKey) {
      // Page 1 features
      case 'featureAiPowered':
        return l10n.featureAiPowered;
      case 'featurePsychologicalMatching':
        return l10n.featurePsychologicalMatching;

      // Page 2 features
      case 'featureValuesAlignment':
        return l10n.featureValuesAlignment;
      case 'featureAttachmentStyle':
        return l10n.featureAttachmentStyle;

      // Page 3 features
      case 'featureGuidedIntroduction':
        return l10n.featureGuidedIntroduction;
      case 'featureQualityOverQuantity':
        return l10n.featureQualityOverQuantity;

      default:
        return l10n.missingLocalization; // ✅ FIXED: Localized error message
    }
  }
}

// ✅ FIXED: Now uses localization keys for all text
final List<OnboardingPageData> onboardingPages = [
  const OnboardingPageData(
    image: 'assets/images/onboarding_bg_1.jpeg',
    titleKey: 'onboardingTitle1',
    descriptionKey: 'onboardingDesc1',
    featureKeys: [
      'featureAiPowered',
      'featurePsychologicalMatching',
    ], // ✅ FIXED: Now uses keys
    featureIcon: Icons.psychology,
  ),
  const OnboardingPageData(
    image: 'assets/images/onboarding_bg_2.jpeg',
    titleKey: 'onboardingTitle2',
    descriptionKey: 'onboardingDesc2',
    featureKeys: [
      'featureValuesAlignment',
      'featureAttachmentStyle',
    ], // ✅ FIXED: Now uses keys
    featureIcon: Icons.favorite_border,
  ),
  const OnboardingPageData(
    image: 'assets/images/onboarding_bg_3.jpeg',
    titleKey: 'onboardingTitle3',
    descriptionKey: 'onboardingDesc3',
    featureKeys: [
      'featureGuidedIntroduction',
      'featureQualityOverQuantity',
    ], // ✅ FIXED: Now uses keys
    featureIcon: Icons.handshake,
  ),
];
