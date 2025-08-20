// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app/locator.dart';
import '../../generated/l10n.dart'; // ✅ ADDED
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = locator<FirebaseService>();

  // Add debug logging
  void _debugLog(String message) {
    print('[AuthService] $message');
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // This is the key method - properly wait for auth state
  Future<User?> getCurrentUserAsync() async {
    _debugLog('Waiting for auth state...');

    // If currentUser is already available, return it
    if (_auth.currentUser != null) {
      _debugLog('User already available: ${_auth.currentUser!.uid}');
      return _auth.currentUser;
    }

    // Otherwise, wait for the first auth state change
    _debugLog('Waiting for auth state change...');
    final user = await _auth.authStateChanges().first;
    _debugLog('Auth state received: ${user?.uid ?? 'null'}');

    return user;
  }

  // Synchronous current user (can be null if not loaded yet)
  User? getCurrentUser() {
    final user = _auth.currentUser;
    _debugLog('getCurrentUser (sync): ${user?.uid ?? 'null'}');
    return user;
  }

  // Proper async authentication check
  Future<bool> isAuthenticated() async {
    _debugLog('Checking authentication...');
    final user = await getCurrentUserAsync();
    final isAuth = user != null;
    _debugLog('Is authenticated: $isAuth');
    return isAuth;
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    BuildContext? context, // ✅ ADDED for localization context
  ) async {
    try {
      _debugLog('Signing up user: $email');

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _debugLog('User created: ${userCredential.user!.uid}');

      // Set display name
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      // Create user document in Firestore
      await _firebaseService.setDocument('users', userCredential.user!.uid, {
        'uid': userCredential.user!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName $lastName',
        'dateOfRegistration': Timestamp.now(),
        'verified': false,
        'activeAccount': true,
      });

      // Create empty profile document
      await _firebaseService.setDocument('profiles', userCredential.user!.uid, {
        'uid': userCredential.user!.uid,
        'completionStatus': {
          'basicInfo': 'not_started',
          'photos': 'not_started',
          'coreValues': 'not_started',
          'lifestyle': 'not_started',
          'relationshipGoals': 'not_started',
          'deepQuestions': 'not_started',
          'psychologicalAssessment': 'not_started',
          'thirdPartyFeedback': 'not_started',
          'matchmakerSelection': 'not_started', // NEW: Track persona selection
        },
        'completionPercentage': 0.0,
        'isProfileComplete': false,
        'dateOfProfileCreation': Timestamp.now(),
        'matchmakerPreferences': {
          'persona': 'sage',
          'style': 'narrative',
          'frequency': 'weekly',
          'lastUpdated': Timestamp.now(),
        },
      });

      _debugLog('User documents created successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _debugLog('Auth exception: ${e.code} - ${e.message}');
      throw _handleAuthException(e, context);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext? context, // ✅ ADDED for localization context
  ) async {
    try {
      _debugLog('Signing in user: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _debugLog('Sign in successful: ${result.user!.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      _debugLog('Sign in failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e, context);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle([BuildContext? context]) async {
    try {
      _debugLog('Starting Google sign in...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _debugLog('Google sign in canceled by user');
        final l10n = context != null ? AppLocalizations.of(context) : null;
        throw Exception(
          l10n?.googleSignInCanceled ?? 'Google sign in was canceled',
        );
      }

      _debugLog('Google account selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _debugLog('Google sign in successful: ${userCredential.user!.uid}');

      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      _debugLog('Is new user: $isNewUser');

      if (isNewUser) {
        // Create user document in Firestore
        final String firstName =
            userCredential.user?.displayName?.split(' ').first ?? '';
        final String lastName =
            userCredential.user?.displayName?.split(' ').last ?? '';

        await _firebaseService.setDocument('users', userCredential.user!.uid, {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'firstName': firstName,
          'lastName': lastName,
          'displayName': userCredential.user!.displayName,
          'dateOfRegistration': Timestamp.now(),
          'verified': userCredential.user!.emailVerified,
          'activeAccount': true,
        });

        await _firebaseService.setDocument(
          'profiles',
          userCredential.user!.uid,
          {
            'uid': userCredential.user!.uid,
            'completionStatus': {
              'basicInfo': 'not_started',
              'photos': 'not_started',
              'coreValues': 'not_started',
              'lifestyle': 'not_started',
              'relationshipGoals': 'not_started',
              'deepQuestions': 'not_started',
              'psychologicalAssessment': 'not_started',
              'thirdPartyFeedback': 'not_started',
              'matchmakerSelection': 'not_started', // ADD THIS
            },
            'completionPercentage': 0.0,
            'isProfileComplete': false,
            'dateOfProfileCreation': Timestamp.now(),
            // ADD THIS BLOCK:
            'matchmakerPreferences': {
              'persona': 'sage',
              'style': 'narrative',
              'frequency': 'weekly',
              'lastUpdated': Timestamp.now(),
            },
          },
        );

        _debugLog('New user documents created');
      }

      return userCredential;
    } catch (e) {
      _debugLog('Google sign in error: $e');
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(
        l10n?.googleSignInFailed ??
            'Failed to sign in with Google: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _debugLog('Signing out user...');
      await _googleSignIn.signOut();
      await _auth.signOut();
      _debugLog('Sign out successful');
    } catch (e) {
      _debugLog('Sign out error: $e');
      rethrow;
    }
  }

  // Check if user has completed profile
  Future<bool> hasCompletedProfile() async {
    try {
      final user = await getCurrentUserAsync();

      if (user == null) {
        _debugLog('No user found for profile check');
        return false;
      }

      _debugLog('Checking profile completion for: ${user.uid}');

      final profileDoc = await _firebaseService.getDocumentById(
        'profiles',
        user.uid,
      );

      if (!profileDoc.exists) {
        _debugLog('Profile document does not exist');
        return false;
      }

      final profileData = profileDoc.data() as Map<String, dynamic>;
      final isComplete = profileData['isProfileComplete'] ?? false;
      _debugLog('Profile complete: $isComplete');

      return isComplete;
    } catch (e) {
      _debugLog('Error checking profile completion: $e');
      return false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfileData() async {
    try {
      final user = await getCurrentUserAsync();

      if (user == null) {
        _debugLog('No user found for profile data');
        return null;
      }

      _debugLog('Getting profile data for: ${user.uid}');

      final profileDoc = await _firebaseService.getDocumentById(
        'profiles',
        user.uid,
      );

      if (!profileDoc.exists) {
        _debugLog('Profile document does not exist');
        return null;
      }

      final data = profileDoc.data() as Map<String, dynamic>;
      _debugLog('Profile data retrieved successfully');
      return data;
    } catch (e) {
      _debugLog('Error getting profile data: $e');
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(
    String email, [
    BuildContext? context,
  ]) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification([BuildContext? context]) async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    BuildContext? context,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail, [BuildContext? context]) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // Update password
  Future<void> updatePassword(
    String newPassword, [
    BuildContext? context,
  ]) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // Delete user account
  Future<void> deleteAccount([BuildContext? context]) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid != null) {
        // First update the user document to mark it as inactive
        await _firebaseService.updateDocument('users', uid, {
          'activeAccount': false,
          'dateOfDeletion': Timestamp.now(),
        });
      }

      // Then delete the Firebase Auth account
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e, context);
    }
  }

  // ✅ FIXED: Handle Firebase Auth exceptions with localization
  Exception _handleAuthException(
    FirebaseAuthException e,
    BuildContext? context,
  ) {
    final l10n = context != null ? AppLocalizations.of(context) : null;

    switch (e.code) {
      case 'user-not-found':
        return Exception(l10n?.userNotFound ?? 'No user found with this email');
      case 'wrong-password':
        return Exception(l10n?.wrongPassword ?? 'Wrong password');
      case 'email-already-in-use':
        return Exception(
          l10n?.emailAlreadyInUse ?? 'This email is already in use',
        );
      case 'weak-password':
        return Exception(l10n?.weakPassword ?? 'The password is too weak');
      case 'invalid-email':
        return Exception(l10n?.invalidEmail ?? 'The email address is invalid');
      case 'operation-not-allowed':
        return Exception(l10n?.operationNotAllowed ?? 'Operation not allowed');
      case 'requires-recent-login':
        return Exception(
          l10n?.requiresRecentLogin ??
              'This operation requires recent authentication. Please log in again',
        );
      case 'user-disabled':
        return Exception(
          l10n?.userDisabled ?? 'This user account has been disabled',
        );
      case 'too-many-requests':
        return Exception(
          l10n?.tooManyRequests ?? 'Too many requests. Please try again later',
        );
      case 'network-request-failed':
        return Exception(
          l10n?.networkError ?? 'Network error. Please check your connection',
        );
      default:
        return Exception(
          l10n?.authenticationError ?? 'Authentication error: ${e.message}',
        );
    }
  }
}
