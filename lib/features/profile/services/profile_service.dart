// lib/features/profile/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to user profiles collection
  CollectionReference get _profiles => _firestore.collection('profiles');

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Save photos to user profile
  Future<void> savePhotosToProfile(List<String> photoUrls) async {
    if (currentUserId.isEmpty) {
      throw Exception('No authenticated user found');
    }

    try {
      // First, get current profile to ensure we don't overwrite other data
      final docSnapshot = await _profiles.doc(currentUserId).get();

      Map<String, dynamic> profileData;

      if (docSnapshot.exists) {
        // Use existing data
        profileData = docSnapshot.data() as Map<String, dynamic>;
      } else {
        // Initialize new profile document
        profileData = {
          'uid': currentUserId,
          'dateOfRegistration': FieldValue.serverTimestamp(),
          'activeAccount': true,
        };
      }

      // Update photos field, keeping primary photo first
      profileData['photos'] = photoUrls;

      // Update completion status if needed
      if (profileData['completionStatus'] == null) {
        profileData['completionStatus'] = {};
      }

      // Mark photo section as completed
      profileData['completionStatus']['photos'] = 'completed';

      // Update completion percentage if it exists
      if (profileData['completionPercentage'] != null) {
        // This is a simplified calculation - in a real app, you'd have more complex logic
        // to calculate the overall completion percentage based on all sections
        final double currentPercentage =
            profileData['completionPercentage'] as double? ?? 0.0;
        // Add 10% for completing photos (adjust as needed)
        final double newPercentage = currentPercentage + 10.0;
        profileData['completionPercentage'] =
            newPercentage > 100.0 ? 100.0 : newPercentage;
      } else {
        // Initialize completion percentage
        profileData['completionPercentage'] = 10.0;
      }

      // Save to Firestore
      await _profiles
          .doc(currentUserId)
          .set(profileData, SetOptions(merge: true));

      print('Photos saved to profile successfully: $photoUrls');
    } catch (e) {
      print('Error saving photos to profile: $e');
      throw Exception('Failed to save photos to profile: $e');
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId.isEmpty) return null;

    try {
      final doc = await _profiles.doc(currentUserId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }

    return null;
  }

  // Save current onboarding step
  Future<void> saveOnboardingProgress(int currentStep) async {
    if (currentUserId.isEmpty) {
      throw Exception('No authenticated user found');
    }

    try {
      await _profiles.doc(currentUserId).set({
        'onboardingProgress': {
          'currentStep': currentStep,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      // print('Onboarding progress saved: Step $currentStep');
    } catch (e) {
      //  print('Error saving onboarding progress: $e');
      throw Exception('Failed to save onboarding progress: $e');
    }
  }
}
