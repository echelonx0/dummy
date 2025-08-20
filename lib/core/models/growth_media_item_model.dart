// lib/features/dashboard/models/growth_media_item.dart
import 'package:flutter/material.dart';

enum GrowthMediaType {
  video,
  article,
  podcast,
  interactive,
}

enum GrowthCategory {
  relationshipPsychology,
  emotionalIntelligence,
  personalDevelopment,
  communication,
  selfAwareness,
  generalGrowth,
}

class GrowthMediaItem {
  final String id;
  final GrowthMediaType mediaType;
  final String source;
  final String title;
  final String description;
  final String timeAgo;
  final String? duration;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? articleUrl;
  final int? views;
  final int? likes;
  final Color primaryColor;
  final DateTime? publishedAt;
  final GrowthCategory category;
  final double relevanceScore;
  final int priority;
  final String actionText;
  final bool linkedInWorthy;
  final String? journalPrompt;

  GrowthMediaItem({
    required this.id,
    required this.mediaType,
    required this.source,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.duration,
    this.thumbnailUrl,
    this.videoUrl,
    this.articleUrl,
    this.views,
    this.likes,
    required this.primaryColor,
    this.publishedAt,
    required this.category,
    required this.relevanceScore,
    required this.priority,
    required this.actionText,
    required this.linkedInWorthy,
    this.journalPrompt,
  });

  // Helper getters
  bool get hasJournalPrompt => journalPrompt != null;
  bool get isHighEngagement => views != null && likes != null && views! > 0 && (likes! / views!) > 0.02;
  bool get isRecent => publishedAt != null && DateTime.now().difference(publishedAt!).inDays < 7;
  
  String get categoryDisplayName {
    switch (category) {
      case GrowthCategory.relationshipPsychology:
        return 'Relationship Psychology';
      case GrowthCategory.emotionalIntelligence:
        return 'Emotional Intelligence';
      case GrowthCategory.personalDevelopment:
        return 'Personal Development';
      case GrowthCategory.communication:
        return 'Communication';
      case GrowthCategory.selfAwareness:
        return 'Self-Awareness';
      case GrowthCategory.generalGrowth:
        return 'Personal Growth';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case GrowthCategory.relationshipPsychology:
        return Icons.favorite_border;
      case GrowthCategory.emotionalIntelligence:
        return Icons.psychology_outlined;
      case GrowthCategory.personalDevelopment:
        return Icons.trending_up;
      case GrowthCategory.communication:
        return Icons.chat_bubble_outline;
      case GrowthCategory.selfAwareness:
        return Icons.self_improvement;
      case GrowthCategory.generalGrowth:
        return Icons.auto_awesome;
    }
  }

  // Factory method for creating mock data (for testing)
  factory GrowthMediaItem.mock({
    required String id,
    required String title,
    GrowthCategory category = GrowthCategory.personalDevelopment,
  }) {
    return GrowthMediaItem(
      id: id,
      mediaType: GrowthMediaType.video,
      source: 'Personal Development Channel',
      title: title,
      description: 'Learn valuable insights about $title and how it applies to your personal growth journey.',
      timeAgo: '2d ago',
      duration: '8:45',
      thumbnailUrl: null,
      videoUrl: 'https://youtube.com/watch?v=$id',
      views: 15000,
      likes: 450,
      primaryColor: Colors.blue,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      category: category,
      relevanceScore: 0.8,
      priority: 1000,
      actionText: 'Learn',
      linkedInWorthy: true,
      journalPrompt: 'How does this concept apply to my current life situation?',
    );
  }
}