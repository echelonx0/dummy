// lib/core/models/feature_flag.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FeatureFlag {
  final String id;
  final bool isEnabled;
  final List<String>? enabledForUserIds; // Premium users only
  final List<String>? enabledForTiers; // ['premium', 'free']
  final DateTime? enabledUntil; // Time-based flags
  final Map<String, dynamic>? metadata; // A/B test groups, etc.

  const FeatureFlag({
    required this.id,
    required this.isEnabled,
    this.enabledForUserIds,
    this.enabledForTiers,
    this.enabledUntil,
    this.metadata,
  });

  factory FeatureFlag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeatureFlag(
      id: doc.id,
      isEnabled: data['isEnabled'] ?? false,
      enabledForUserIds: List<String>.from(data['enabledForUserIds'] ?? []),
      enabledForTiers: List<String>.from(data['enabledForTiers'] ?? []),
      enabledUntil: (data['enabledUntil'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  // Check if flag is enabled for specific user
  bool isEnabledForUser({required String userId, String? userTier}) {
    // Global disabled
    if (!isEnabled) return false;

    // Time-based check
    if (enabledUntil != null && DateTime.now().isAfter(enabledUntil!)) {
      return false;
    }

    // User-specific check
    if (enabledForUserIds?.isNotEmpty == true) {
      return enabledForUserIds!.contains(userId);
    }

    // Tier-based check
    if (enabledForTiers?.isNotEmpty == true && userTier != null) {
      return enabledForTiers!.contains(userTier);
    }

    // Default to global enabled state
    return isEnabled;
  }
}
