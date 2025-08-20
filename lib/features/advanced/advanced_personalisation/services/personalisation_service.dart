import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/personalisation_models.dart';
import '../utils/personalisation_questions.dart';

class PersonalizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  int calculateQualificationScore(Map<String, String> personalDetails) {
    int score = 0;

    for (final entry in personalDetails.entries) {
      final question = PersonalizationQuestions.personalQuestions.firstWhere(
        (q) => q.id == entry.key,
      );

      final option = question.options.firstWhere(
        (opt) => opt.value == entry.value,
      );

      score += option.points;
    }

    return score;
  }

  Future<void> savePersonalizationData({
    required Map<String, String> partnerPreferences,
    required Map<String, String> personalDetails,
    required int qualificationScore,
    required String userGender,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final clubEligible = qualificationScore >= 75;
    final clubType = userGender == 'female' ? 'cherry' : 'alpha';

    final data = PersonalizationData(
      userId: _userId!,
      partnerPreferences: partnerPreferences,
      personalDetails: personalDetails,
      qualificationScore: qualificationScore,
      clubEligible: clubEligible,
      clubType: clubEligible ? clubType : '',
      completedAt: DateTime.now(),
    );

    await _firestore
        .collection('advanced_personalization')
        .doc(_userId)
        .set(data.toFirestore());

    // Update user profile to mark advanced personalization complete
    await _firestore.collection('profiles').doc(_userId).update({
      'advancedPersonalizationComplete': true,
      'qualificationScore': qualificationScore,
      'clubEligible': clubEligible,
      'lastPersonalizationUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitClubApplication({required String clubType}) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore.collection('club_applications').doc(_userId).set({
      'userId': _userId,
      'clubType': clubType,
      'applicationStatus': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewStatus': 'pending',
      'nextStep': 'manual_review',
    });

    // Update personalization data
    await _firestore
        .collection('advanced_personalization')
        .doc(_userId)
        .update({
          'clubApplicationSubmitted': true,
          'applicationSubmittedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<PersonalizationData?> getPersonalizationData() async {
    if (_userId == null) return null;

    final doc =
        await _firestore
            .collection('advanced_personalization')
            .doc(_userId)
            .get();

    if (!doc.exists) return null;

    return PersonalizationData.fromFirestore(doc.data()!);
  }

  Stream<DocumentSnapshot> watchClubApplicationStatus() {
    if (_userId == null) {
      return Stream.error('User not authenticated');
    }

    return _firestore.collection('club_applications').doc(_userId).snapshots();
  }
}
