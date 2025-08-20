// lib/features/advanced_personalization/utils/personalization_launcher.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/shared/widgets/action_modal_widget.dart';
import '../screens/advanced_personalization_flutter.dart';

class PersonalizationLauncher {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Launch Advanced Personalization Module
  /// Checks if user is eligible and hasn't completed it yet
  static Future<void> launch(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Check if user has already completed advanced personalization
      final personalizationDoc =
          await _firestore
              .collection('advanced_personalization')
              .doc(user.uid)
              .get();

      if (personalizationDoc.exists) {
        // Already completed - show status or skip
        _showAlreadyCompletedMessage(context);
        return;
      }

      // Check user profile for eligibility
      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();

      if (!profileDoc.exists) {
        _showCompleteProfileMessage(context);
        return;
      }

      final profileData = profileDoc.data()!;
      final completionPercentage = profileData['completionPercentage'] ?? 0;
      final userGender = profileData['gender'] ?? 'female';

      if (completionPercentage < 80) {
        _showCompleteProfileMessage(context);
        return;
      }

      // Launch the module
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  AdvancedPersonalizationScreen(userGender: userGender),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading personalization module'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show teaser modal to encourage advanced personalization
  static void showTeaser(BuildContext context) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.feature,
      data: ActionModalData(
        headline: 'Unlock Advanced Matching',
        subheadline:
            'Get access to our most sophisticated compatibility algorithm based on deep preferences and lifestyle factors.',
        ctaText: 'Get Started',
        onAction: () => launch(context),
        illustration: Icon(Icons.auto_awesome, size: 64, color: Colors.white),
        badge: 'New Feature',
      ),
    );
  }

  static void _showAlreadyCompletedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Advanced personalization already completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void _showCompleteProfileMessage(BuildContext context) {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.card,
      type: ActionModalType.reminder,
      data: ActionModalData(
        headline: 'Complete Your Profile First',
        subheadline:
            'Advanced personalization requires at least 80% profile completion for the best results.',
        ctaText: 'Complete Profile',
        onAction: () {
          // Navigate to profile completion
          Navigator.of(context).pushNamed('/profile/complete');
        },
      ),
    );
  }

  /// Check if user should see the advanced personalization prompt
  static Future<bool> shouldShowPrompt() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if already completed
      final personalizationDoc =
          await _firestore
              .collection('advanced_personalization')
              .doc(user.uid)
              .get();

      if (personalizationDoc.exists) return false;

      // Check profile completion
      final profileDoc =
          await _firestore.collection('profiles').doc(user.uid).get();

      if (!profileDoc.exists) return false;

      final profileData = profileDoc.data()!;
      final completionPercentage = profileData['completionPercentage'] ?? 0;
      final relationshipReadiness = profileData['relationshipReadiness'] ?? 0;

      // Show prompt if profile is >80% complete and relationship readiness >70
      return completionPercentage >= 80 && relationshipReadiness >= 70;
    } catch (e) {
      return false;
    }
  }
}
