// lib/features/profile/services/profile_management_service.dart
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../app/locator.dart';

class ProfileManagementService {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  Future<ProfileData> loadUserData() async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    String? userName;
    if (user.displayName != null) {
      final nameParts = user.displayName!.split(' ');
      userName = nameParts.isNotEmpty ? nameParts.first : null;
    }

    final profileDoc = await _firebaseService.getDocumentById(
      'profiles',
      user.uid,
    );

    Map<String, dynamic>? profileData;
    if (profileDoc.exists) {
      profileData = profileDoc.data() as Map<String, dynamic>;
    }

    return ProfileData(
      userName: userName,
      userEmail: user.email,
      profileData: profileData,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String getTrustScoreDescription(double score) {
    if (score >= 90) return 'Excellent standing';
    if (score >= 80) return 'Good standing';
    if (score >= 60) return 'Fair standing';
    if (score >= 40) return 'Needs improvement';
    return 'Low standing';
  }
}

class ProfileData {
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? profileData;

  ProfileData({
    this.userName,
    this.userEmail,
    this.profileData,
  });

  double get completionPercentage => 
    (profileData?['completionPercentage'] ?? 0.0).toDouble();
  
  double get trustScore => 
    (profileData?['trustScore'] ?? 0.0).toDouble();
  
  bool get isComplete => completionPercentage >= 100;
}