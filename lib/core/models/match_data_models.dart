// ===============================================================
// MATCH DATA MODEL
// lib/core/models/match_profile.dart
// ===============================================================

class MatchProfile {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String? profileImageUrl;
  final String profession;
  final String bio;
  final List<String> sharedValues;
  final int compatibilityScore;
  final MatchStatus status;
  final DateTime? createdAt;
  final DateTime? lastInteraction;

  // Extended match data
  final String? location;
  final List<String>? interests;
  final String? education;
  final List<String>? photos;
  final Map<String, dynamic>? psychologicalProfile;

  const MatchProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.profileImageUrl,
    required this.profession,
    required this.bio,
    required this.sharedValues,
    required this.compatibilityScore,
    required this.status,
    this.createdAt,
    this.lastInteraction,
    this.location,
    this.interests,
    this.education,
    this.photos,
    this.psychologicalProfile,
  });

  factory MatchProfile.fromMap(Map<String, dynamic> map) {
    return MatchProfile(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      profileImageUrl: map['profileImageUrl'],
      profession: map['profession'] ?? '',
      bio: map['bio'] ?? '',
      sharedValues: List<String>.from(map['sharedValues'] ?? []),
      compatibilityScore: map['compatibilityScore']?.toInt() ?? 0,
      status: MatchStatus.fromString(map['status'] ?? 'pending'),
      createdAt: map['createdAt']?.toDate(),
      lastInteraction: map['lastInteraction']?.toDate(),
      location: map['location'],
      interests:
          map['interests'] != null ? List<String>.from(map['interests']) : null,
      education: map['education'],
      photos: map['photos'] != null ? List<String>.from(map['photos']) : null,
      psychologicalProfile: map['psychologicalProfile'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'age': age,
      'profileImageUrl': profileImageUrl,
      'profession': profession,
      'bio': bio,
      'sharedValues': sharedValues,
      'compatibilityScore': compatibilityScore,
      'status': status.value,
      'createdAt': createdAt,
      'lastInteraction': lastInteraction,
      'location': location,
      'interests': interests,
      'education': education,
      'photos': photos,
      'psychologicalProfile': psychologicalProfile,
    };
  }

  MatchProfile copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    String? profileImageUrl,
    String? profession,
    String? bio,
    List<String>? sharedValues,
    int? compatibilityScore,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? lastInteraction,
    String? location,
    List<String>? interests,
    String? education,
    List<String>? photos,
    Map<String, dynamic>? psychologicalProfile,
  }) {
    return MatchProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profession: profession ?? this.profession,
      bio: bio ?? this.bio,
      sharedValues: sharedValues ?? this.sharedValues,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      education: education ?? this.education,
      photos: photos ?? this.photos,
      psychologicalProfile: psychologicalProfile ?? this.psychologicalProfile,
    );
  }
}

// ===============================================================
// MATCH STATUS ENUM
// ===============================================================

enum MatchStatus {
  pending('pending'),
  interested('interested'),
  notInterested('not_interested'),
  mutual('mutual'),
  blocked('blocked'),
  expired('expired');

  const MatchStatus(this.value);
  final String value;

  static MatchStatus fromString(String value) {
    return MatchStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MatchStatus.pending,
    );
  }
}

// ===============================================================
// MATCH ACTION RESULT
// ===============================================================

class MatchActionResult {
  final bool success;
  final String? message;
  final MatchProfile? updatedMatch;
  final bool isMutualMatch;

  const MatchActionResult({
    required this.success,
    this.message,
    this.updatedMatch,
    this.isMutualMatch = false,
  });

  factory MatchActionResult.success({
    String? message,
    MatchProfile? updatedMatch,
    bool isMutualMatch = false,
  }) {
    return MatchActionResult(
      success: true,
      message: message,
      updatedMatch: updatedMatch,
      isMutualMatch: isMutualMatch,
    );
  }

  factory MatchActionResult.failure(String message) {
    return MatchActionResult(success: false, message: message);
  }
}
