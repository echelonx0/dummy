// lib/features/account/services/advanced_profile_service.dart

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/advanced_profile_models.dart';

class AdvancedProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Validates a URL both format and accessibility
  static Future<ValidationResult> validateUrl(
    String url,
    AdvancedProfileType type,
  ) async {
    // Basic format validation
    if (url.trim().isEmpty) {
      return ValidationResult.error('URL cannot be empty');
    }

    // Ensure URL has protocol
    String validUrl = url.trim();
    if (!validUrl.startsWith('http://') && !validUrl.startsWith('https://')) {
      validUrl = 'https://$validUrl';
    }

    // Type-specific pattern validation
    if (!type.urlPattern.hasMatch(validUrl)) {
      return ValidationResult.error(
        'Please enter a valid ${type.displayName} URL\nExample: ${type.placeholder}',
      );
    }

    // Check URL accessibility (with timeout)
    try {
      final response = await http
          .head(Uri.parse(validUrl), headers: {'User-Agent': 'Khedoo-App/1.0'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return ValidationResult(isValid: true, isReachable: true);
      } else {
        return ValidationResult(
          isValid: true, // Format is valid, but not reachable
          isReachable: false,
          errorMessage:
              'URL appears to be inaccessible (${response.statusCode})',
        );
      }
    } catch (e) {
      // Format is valid, but can't verify accessibility
      return ValidationResult(
        isValid: true,
        isReachable: false,
        errorMessage: 'Could not verify URL accessibility',
      );
    }
  }

  /// Saves an advanced profile link to Firestore
  static Future<bool> saveProfileLink(AdvancedProfileLink link) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final profileRef = _firestore.collection('profiles').doc(user.uid);

      await profileRef.update({
        'advancedProfile.${link.type.name}': link.toMap(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error saving profile link: $e');
      return false;
    }
  }

  /// Removes an advanced profile link
  static Future<bool> removeProfileLink(AdvancedProfileType type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final profileRef = _firestore.collection('profiles').doc(user.uid);

      await profileRef.update({
        'advancedProfile.${type.name}': FieldValue.delete(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error removing profile link: $e');
      return false;
    }
  }

  /// Gets all advanced profile links for current user
  static Future<List<AdvancedProfileLink>> getProfileLinks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();
      final data = profileDoc.data();

      if (data == null || data['advancedProfile'] == null) return [];

      final advancedProfile = data['advancedProfile'] as Map<String, dynamic>;
      final links = <AdvancedProfileLink>[];

      for (final entry in advancedProfile.entries) {
        try {
          final link = AdvancedProfileLink.fromMap(entry.value);
          links.add(link);
        } catch (e) {
          print('Error parsing profile link ${entry.key}: $e');
        }
      }

      return links;
    } catch (e) {
      print('Error getting profile links: $e');
      return [];
    }
  }

  /// Gets a specific profile link by type
  static Future<AdvancedProfileLink?> getProfileLink(
    AdvancedProfileType type,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();
      final data = profileDoc.data();

      if (data == null || data['advancedProfile'] == null) return null;

      final advancedProfile = data['advancedProfile'] as Map<String, dynamic>;
      final linkData = advancedProfile[type.name];

      if (linkData == null) return null;

      return AdvancedProfileLink.fromMap(linkData);
    } catch (e) {
      print('Error getting profile link ${type.name}: $e');
      return null;
    }
  }

  /// Updates completion percentage based on profile links
  static Future<void> updateProfileCompletion() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final links = await getProfileLinks();
      final linkCount = links.length;

      // Advanced profile contributes 10% to overall completion
      // Having 3+ links gives full advanced profile completion
      final advancedProfileCompletion = (linkCount / 3).clamp(0.0, 1.0);

      final profileRef = _firestore.collection('profiles').doc(user.uid);
      await profileRef.update({
        'completionStatus.advancedProfile':
            linkCount > 0 ? 'completed' : 'not_started',
        'advancedProfileScore': advancedProfileCompletion,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating profile completion: $e');
    }
  }

  /// Verifies a link (placeholder for future verification system)
  static Future<bool> verifyLink(AdvancedProfileLink link) async {
    // TODO: Implement verification logic
    // - Check if URL returns expected content
    // - For LinkedIn, check if it's a valid profile
    // - For social media, check if account exists
    // - Could use web scraping or platform APIs

    // For now, just check if URL is reachable
    final validation = await validateUrl(link.url, link.type);
    return validation.isReachable;
  }

  /// Gets suggested profile types based on user's interests/career
  static List<AdvancedProfileType> getSuggestedTypes({
    List<String>? interests,
    String? careerField,
  }) {
    final suggestions = <AdvancedProfileType>[];

    // Always suggest LinkedIn and personal website as professional basics
    suggestions.addAll([
      AdvancedProfileType.linkedin,
      AdvancedProfileType.personalWebsite,
    ]);

    // Career-based suggestions
    if (careerField != null) {
      final field = careerField.toLowerCase();

      if (field.contains('tech') ||
          field.contains('engineer') ||
          field.contains('developer')) {
        suggestions.add(AdvancedProfileType.github);
      }

      if (field.contains('design') ||
          field.contains('creative') ||
          field.contains('art')) {
        suggestions.addAll([
          AdvancedProfileType.behance,
          AdvancedProfileType.portfolio,
        ]);
      }

      if (field.contains('writer') ||
          field.contains('journalist') ||
          field.contains('content')) {
        suggestions.addAll([
          AdvancedProfileType.medium,
          AdvancedProfileType.substack,
        ]);
      }
    }

    // Interest-based suggestions
    if (interests != null) {
      final interestString = interests.join(' ').toLowerCase();

      if (interestString.contains('fitness') ||
          interestString.contains('running')) {
        suggestions.add(AdvancedProfileType.strava);
      }

      if (interestString.contains('reading') ||
          interestString.contains('books')) {
        suggestions.add(AdvancedProfileType.goodreads);
      }

      if (interestString.contains('music')) {
        suggestions.add(AdvancedProfileType.spotify);
      }

      if (interestString.contains('video') ||
          interestString.contains('content creation')) {
        suggestions.add(AdvancedProfileType.youtube);
      }
    }

    // Always suggest Instagram and Twitter as social basics
    suggestions.addAll([
      AdvancedProfileType.instagram,
      AdvancedProfileType.twitter,
    ]);

    // Remove duplicates and return
    return suggestions.toSet().toList();
  }
}
