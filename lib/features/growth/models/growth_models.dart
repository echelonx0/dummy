// lib/features/growth/models/growth_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// =============================================================================
// GROWTH JOURNEY MODELS
// =============================================================================

enum GrowthCategory {
  communication,
  emotional,
  social,
  selfAwareness,
  lifestyle,
  confidence,
}

enum TaskDifficulty { beginner, intermediate, advanced }

enum MoodType {
  excited,
  happy,
  content,
  neutral,
  anxious,
  sad,
  frustrated,
  confident,
  grateful,
  inspired,
}

// =============================================================================
// GROWTH PROFILE MODEL
// =============================================================================

class GrowthProfile {
  final String userId;
  final int overallGrowthScore;
  final Map<GrowthCategory, int> categoryScores;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;
  final List<String> completedAchievements;
  final int totalTasksCompleted;
  final int totalJournalEntries;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  // FIXED: Renamed field to avoid conflict with getter
  final Map<String, double>? readinessFactors;
  final List<String>? strengths;
  final List<String>? growthAreas;
  final bool? _isGrowthReady; // RENAMED: Added underscore to make it private

  GrowthProfile({
    required this.userId,
    required this.overallGrowthScore,
    required this.categoryScores,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivity,
    required this.completedAchievements,
    required this.totalTasksCompleted,
    required this.totalJournalEntries,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.readinessFactors,
    this.strengths,
    this.growthAreas,
    bool?
    isGrowthReady, // FIXED: Parameter name remains the same for API compatibility
  }) : _isGrowthReady = isGrowthReady; // FIXED: Assign to private field

  factory GrowthProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GrowthProfile(
      userId: doc.id,
      overallGrowthScore: data['overallGrowthScore'] ?? 0,
      categoryScores: (data['categoryScores'] as Map<String, dynamic>? ?? {})
          .map(
            (key, value) => MapEntry(
              GrowthCategory.values.firstWhere((e) => e.name == key),
              value as int,
            ),
          ),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
      completedAchievements: List<String>.from(
        data['completedAchievements'] ?? [],
      ),
      totalTasksCompleted: data['totalTasksCompleted'] ?? 0,
      totalJournalEntries: data['totalJournalEntries'] ?? 0,
      preferences: data['preferences'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      readinessFactors:
          data['readinessFactors'] != null
              ? Map<String, double>.from(data['readinessFactors'])
              : null,
      strengths:
          data['strengths'] != null
              ? List<String>.from(data['strengths'])
              : null,
      growthAreas:
          data['growthAreas'] != null
              ? List<String>.from(data['growthAreas'])
              : null,
      isGrowthReady:
          data['isGrowthReady'], // FIXED: Still uses same key for Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'overallGrowthScore': overallGrowthScore,
      'categoryScores': categoryScores.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'completedAchievements': completedAchievements,
      'totalTasksCompleted': totalTasksCompleted,
      'totalJournalEntries': totalJournalEntries,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'readinessFactors': readinessFactors,
      'strengths': strengths,
      'growthAreas': growthAreas,
      'isGrowthReady': _isGrowthReady, // FIXED: Use private field
    };
  }

  // FIXED: Getter now uses private field to avoid naming conflict
  bool get isGrowthReady => _isGrowthReady ?? (overallGrowthScore >= 70);

  // Keep existing getter
  bool get hasAdvancedInsights =>
      totalTasksCompleted >= 10 && totalJournalEntries >= 5;
}

// =============================================================================
// GROWTH TASK MODEL
// =============================================================================

class GrowthTask {
  final String id;
  final String title;
  final String description;
  final String detailedInstructions;
  final GrowthCategory category;
  final TaskDifficulty difficulty;
  final int estimatedMinutes;
  final int pointValue;
  final List<String> tags;
  final String encouragementMessage;
  final String completionCelebration;
  final bool isPersonalized;
  final DateTime? assignedDate;
  final DateTime? completedDate;
  final Map<String, dynamic> progressData;
  final bool isActive;

  GrowthTask({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedInstructions,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.pointValue,
    required this.tags,
    required this.encouragementMessage,
    required this.completionCelebration,
    required this.isPersonalized,
    this.assignedDate,
    this.completedDate,
    required this.progressData,
    required this.isActive,
  });

  factory GrowthTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GrowthTask(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      detailedInstructions: data['detailedInstructions'] ?? '',
      category: GrowthCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => GrowthCategory.selfAwareness,
      ),
      difficulty: TaskDifficulty.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => TaskDifficulty.beginner,
      ),
      estimatedMinutes: data['estimatedMinutes'] ?? 10,
      pointValue: data['pointValue'] ?? 10,
      tags: List<String>.from(data['tags'] ?? []),
      encouragementMessage: data['encouragementMessage'] ?? '',
      completionCelebration: data['completionCelebration'] ?? '',
      isPersonalized: data['isPersonalized'] ?? false,
      assignedDate:
          data['assignedDate'] != null
              ? (data['assignedDate'] as Timestamp).toDate()
              : null,
      completedDate:
          data['completedDate'] != null
              ? (data['completedDate'] as Timestamp).toDate()
              : null,
      progressData: data['progressData'] ?? {},
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'detailedInstructions': detailedInstructions,
      'category': category.name,
      'difficulty': difficulty.name,
      'estimatedMinutes': estimatedMinutes,
      'pointValue': pointValue,
      'tags': tags,
      'encouragementMessage': encouragementMessage,
      'completionCelebration': completionCelebration,
      'isPersonalized': isPersonalized,
      'assignedDate':
          assignedDate != null ? Timestamp.fromDate(assignedDate!) : null,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'progressData': progressData,
      'isActive': isActive,
    };
  }

  bool get isCompleted => completedDate != null;
  bool get isOverdue =>
      assignedDate != null &&
      DateTime.now().difference(assignedDate!).inDays > 7 &&
      !isCompleted;

  // Get category color
  Color get categoryColor {
    switch (category) {
      case GrowthCategory.communication:
        return const Color(0xFF8B5FBF); // Soulful Purple
      case GrowthCategory.emotional:
        return const Color(0xFFE8B4CB); // Nurturing Pink
      case GrowthCategory.social:
        return const Color(0xFF4A90E2); // Hope Blue
      case GrowthCategory.selfAwareness:
        return const Color(0xFF7FB069); // Growth Green
      case GrowthCategory.lifestyle:
        return const Color(0xFFF4D03F); // Warm Gold
      case GrowthCategory.confidence:
        return const Color(0xFFFF6B9D); // Coral Pink
    }
  }

  // Get difficulty emoji
  String get difficultyEmoji {
    switch (difficulty) {
      case TaskDifficulty.beginner:
        return '🌱';
      case TaskDifficulty.intermediate:
        return '🌿';
      case TaskDifficulty.advanced:
        return '🌳';
    }
  }
}

// =============================================================================
// JOURNAL ENTRY MODEL
// =============================================================================

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final MoodType mood;
  final int moodIntensity; // 1-10 scale
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastModified;
  final bool isPrivate;
  final Map<String, dynamic> metadata;
  final List<String> attachments; // Future: photos, voice notes
  final String? promptId; // If from guided prompt
  final Map<String, dynamic> aiInsights; // Premium feature

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodIntensity,
    required this.tags,
    required this.createdAt,
    this.lastModified,
    required this.isPrivate,
    required this.metadata,
    required this.attachments,
    this.promptId,
    required this.aiInsights,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      mood: MoodType.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => MoodType.neutral,
      ),
      moodIntensity: data['moodIntensity'] ?? 5,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastModified:
          data['lastModified'] != null
              ? (data['lastModified'] as Timestamp).toDate()
              : null,
      isPrivate: data['isPrivate'] ?? true,
      metadata: data['metadata'] ?? {},
      attachments: List<String>.from(data['attachments'] ?? []),
      promptId: data['promptId'],
      aiInsights: data['aiInsights'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood.name,
      'moodIntensity': moodIntensity,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified':
          lastModified != null ? Timestamp.fromDate(lastModified!) : null,
      'isPrivate': isPrivate,
      'metadata': metadata,
      'attachments': attachments,
      'promptId': promptId,
      'aiInsights': aiInsights,
    };
  }

  // Get mood color
  Color get moodColor {
    switch (mood) {
      case MoodType.excited:
        return const Color(0xFFFF6B9D); // Coral Pink
      case MoodType.happy:
        return const Color(0xFFF4D03F); // Warm Gold
      case MoodType.content:
        return const Color(0xFF7FB069); // Growth Green
      case MoodType.neutral:
        return const Color(0xFF9E9E9E); // Neutral Gray
      case MoodType.anxious:
        return const Color(0xFFFFB74D); // Anxiety Orange
      case MoodType.sad:
        return const Color(0xFF64B5F6); // Sad Blue
      case MoodType.frustrated:
        return const Color(0xFFEF5350); // Frustration Red
      case MoodType.confident:
        return const Color(0xFF8B5FBF); // Soulful Purple
      case MoodType.grateful:
        return const Color(0xFFE8B4CB); // Nurturing Pink
      case MoodType.inspired:
        return const Color(0xFF4A90E2); // Hope Blue
    }
  }

  // Get mood emoji
  String get moodEmoji {
    switch (mood) {
      case MoodType.excited:
        return '🤩';
      case MoodType.happy:
        return '😊';
      case MoodType.content:
        return '😌';
      case MoodType.neutral:
        return '😐';
      case MoodType.anxious:
        return '😰';
      case MoodType.sad:
        return '😢';
      case MoodType.frustrated:
        return '😤';
      case MoodType.confident:
        return '💪';
      case MoodType.grateful:
        return '🙏';
      case MoodType.inspired:
        return '✨';
    }
  }

  int get wordCount => content.split(' ').length;
}

// =============================================================================
// GROWTH ACHIEVEMENT MODEL
// =============================================================================

class GrowthAchievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final GrowthCategory category;
  final int pointValue;
  final Map<String, dynamic> requirements;
  final bool isSecret; // Hidden until unlocked
  final int rarity; // 1-5, 5 being rarest
  final DateTime? unlockedAt;
  final String celebrationMessage;

  GrowthAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.pointValue,
    required this.requirements,
    required this.isSecret,
    required this.rarity,
    this.unlockedAt,
    required this.celebrationMessage,
  });

  factory GrowthAchievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GrowthAchievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '🏆',
      category: GrowthCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => GrowthCategory.selfAwareness,
      ),
      pointValue: data['pointValue'] ?? 0,
      requirements: data['requirements'] ?? {},
      isSecret: data['isSecret'] ?? false,
      rarity: data['rarity'] ?? 1,
      unlockedAt:
          data['unlockedAt'] != null
              ? (data['unlockedAt'] as Timestamp).toDate()
              : null,
      celebrationMessage: data['celebrationMessage'] ?? '',
    );
  }

  bool get isUnlocked => unlockedAt != null;

  // Get rarity color
  Color get rarityColor {
    switch (rarity) {
      case 1:
        return const Color(0xFF9E9E9E); // Common - Gray
      case 2:
        return const Color(0xFF4CAF50); // Uncommon - Green
      case 3:
        return const Color(0xFF2196F3); // Rare - Blue
      case 4:
        return const Color(0xFF9C27B0); // Epic - Purple
      case 5:
        return const Color(0xFFFF9800); // Legendary - Orange
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// =============================================================================
// GROWTH ANALYTICS MODEL
// =============================================================================

class GrowthAnalytics {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int tasksCompleted;
  final int journalEntries;
  final double averageMoodScore;
  final Map<GrowthCategory, int> categoryProgress;
  final int streakDays;
  final List<String> topTags;
  final Map<String, dynamic> insights;
  final double datingReadinessScore;
  final Map<String, int> weeklyActivity;

  GrowthAnalytics({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.tasksCompleted,
    required this.journalEntries,
    required this.averageMoodScore,
    required this.categoryProgress,
    required this.streakDays,
    required this.topTags,
    required this.insights,
    required this.datingReadinessScore,
    required this.weeklyActivity,
  });

  factory GrowthAnalytics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GrowthAnalytics(
      userId: data['userId'] ?? '',
      periodStart: (data['periodStart'] as Timestamp).toDate(),
      periodEnd: (data['periodEnd'] as Timestamp).toDate(),
      tasksCompleted: data['tasksCompleted'] ?? 0,
      journalEntries: data['journalEntries'] ?? 0,
      averageMoodScore: (data['averageMoodScore'] ?? 0.0).toDouble(),
      categoryProgress:
          (data['categoryProgress'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(
              GrowthCategory.values.firstWhere((e) => e.name == key),
              value as int,
            ),
          ),
      streakDays: data['streakDays'] ?? 0,
      topTags: List<String>.from(data['topTags'] ?? []),
      insights: data['insights'] ?? {},
      datingReadinessScore: (data['datingReadinessScore'] ?? 0.0).toDouble(),
      weeklyActivity: Map<String, int>.from(data['weeklyActivity'] ?? {}),
    );
  }

  // Calculate overall progress
  double get overallProgress {
    final totalActivities = tasksCompleted + journalEntries;
    return totalActivities / 30.0; // Target: 30 activities per period
  }

  // Get growth trend
  String get growthTrend {
    if (datingReadinessScore >= 80) return 'Excellent';
    if (datingReadinessScore >= 60) return 'Growing';
    if (datingReadinessScore >= 40) return 'Developing';
    return 'Starting';
  }
}
