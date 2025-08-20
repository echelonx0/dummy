// lib/features/dashboard/services/personal_growth_youtube_service.dart
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../constants/app_colors.dart';
import '../models/growth_media_item_model.dart';

class PersonalGrowthYouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // The personal development playlist from the URL
  static const String _personalDevelopmentPlaylistId =
      'PLgxLGFW13_PJY5IMnXaa8PEnqjeAcbY23';

  /// Get videos from the personal development playlist
  Future<List<GrowthMediaItem>> getPersonalDevelopmentVideos({
    int maxResults = 15,
  }) async {
    try {
      final playlist = await _yt.playlists.get(_personalDevelopmentPlaylistId);
      final videos =
          await _yt.playlists
              .getVideos(_personalDevelopmentPlaylistId)
              .take(maxResults)
              .toList();

      List<GrowthMediaItem> growthVideos = [];

      for (final video in videos) {
        // Get detailed video info
        final detailedVideo = await _yt.videos.get(video.id);

        growthVideos.add(
          _mapVideoToGrowthItem(
            detailedVideo,
            playlist.title,
            isPersonalDevelopment: true,
          ),
        );
      }

      return growthVideos;
    } catch (e) {
      throw Exception('Failed to fetch personal development playlist: $e');
    }
  }

  /// Search for additional relationship/growth content
  Future<List<GrowthMediaItem>> searchGrowthContent({
    int maxResults = 8,
    String query = 'relationship psychology personal development',
  }) async {
    try {
      final searchResults = await _yt.search.search(
        query,
        filter: TypeFilters.video,
      );

      List<GrowthMediaItem> results = [];

      for (final result in searchResults.take(maxResults)) {
        try {
          final video = await _yt.videos.get(result.id);
          results.add(_mapVideoToGrowthItem(video, result.author));
        } catch (e) {
          continue; // Skip videos that can't be accessed
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search growth content: $e');
    }
  }

  /// Get comprehensive growth media feed
  Future<List<GrowthMediaItem>> getComprehensiveGrowthFeed() async {
    try {
      final results = await Future.wait([
        getPersonalDevelopmentVideos(maxResults: 12), // Main playlist
        searchGrowthContent(
          maxResults: 6,
          query: 'attachment theory relationships psychology',
        ),
        searchGrowthContent(
          maxResults: 4,
          query: 'emotional intelligence dating readiness',
        ),
        searchGrowthContent(
          maxResults: 3,
          query: 'self awareness personal growth mindset',
        ),
      ]);

      List<GrowthMediaItem> combinedFeed = [];
      for (final result in results) {
        combinedFeed.addAll(result);
      }

      // Remove duplicates and sort by relevance
      final uniqueFeed = _removeDuplicates(combinedFeed);
      uniqueFeed.sort((a, b) => b.priority.compareTo(a.priority));

      return uniqueFeed.take(20).toList();
    } catch (e) {
      throw Exception('Failed to get comprehensive growth feed: $e');
    }
  }

  /// Map YouTube video to GrowthMediaItem
  GrowthMediaItem _mapVideoToGrowthItem(
    Video video,
    String authorName, {
    bool isPersonalDevelopment = false,
  }) {
    return GrowthMediaItem(
      id: video.id.value,
      mediaType: GrowthMediaType.video,
      source: authorName,
      title: video.title,
      description:
          video.description.length > 200
              ? '${video.description.substring(0, 200)}...'
              : video.description,
      timeAgo: _formatTimeAgo(video.uploadDate ?? DateTime.now()),
      duration: _formatDuration(video.duration),
      thumbnailUrl: video.thumbnails.highResUrl,
      videoUrl: video.url,
      views: video.engagement.viewCount,
      likes: video.engagement.likeCount,
      primaryColor: _getContentColor(video.title, isPersonalDevelopment),
      publishedAt: video.uploadDate,
      category: _categorizeContent(video.title, video.description),
      relevanceScore: _calculateRelevanceScore(video, isPersonalDevelopment),
      priority: _calculatePriority(video, isPersonalDevelopment),
      actionText: _getActionText(video.title),
      linkedInWorthy: _isLinkedInWorthy(video.title, video.description),
      journalPrompt: _generateJournalPrompt(video.title),
    );
  }

  /// Categorize content based on title and description
  GrowthCategory _categorizeContent(String title, String description) {
    final content = '${title.toLowerCase()} ${description.toLowerCase()}';

    if (content.contains(
      RegExp(r'attachment|relationship|dating|love|partner'),
    )) {
      return GrowthCategory.relationshipPsychology;
    } else if (content.contains(
      RegExp(r'emotional|intelligence|empathy|feelings'),
    )) {
      return GrowthCategory.emotionalIntelligence;
    } else if (content.contains(
      RegExp(r'mindset|growth|development|improvement'),
    )) {
      return GrowthCategory.personalDevelopment;
    } else if (content.contains(RegExp(r'communication|conversation|social'))) {
      return GrowthCategory.communication;
    } else if (content.contains(
      RegExp(r'self|awareness|consciousness|mindful'),
    )) {
      return GrowthCategory.selfAwareness;
    } else {
      return GrowthCategory.generalGrowth;
    }
  }

  /// Get content-specific color
  Color _getContentColor(String title, bool isFromMainPlaylist) {
    if (isFromMainPlaylist) {
      return AppColors.primarySageGreen; // Main playlist gets premium color
    }

    final titleLower = title.toLowerCase();

    if (titleLower.contains(RegExp(r'attachment|relationship'))) {
      return AppColors.primaryAccent; // Cream for relationships
    } else if (titleLower.contains(RegExp(r'emotional|intelligence'))) {
      return AppColors.primaryGold; // Gold for emotional topics
    } else if (titleLower.contains(RegExp(r'growth|development'))) {
      return AppColors.electricBlue; // Blue for development
    } else {
      return AppColors.textMedium; // Default
    }
  }

  /// Calculate how relevant content is to relationship readiness
  double _calculateRelevanceScore(Video video, bool isFromMainPlaylist) {
    if (isFromMainPlaylist) return 1.0; // Main playlist is always relevant

    final content =
        '${video.title.toLowerCase()} ${video.description.toLowerCase()}';
    double score = 0.3; // Base score

    // Relationship-focused content
    if (content.contains(
      RegExp(r'relationship|dating|love|partner|attachment'),
    )) {
      score += 0.4;
    }

    // Personal development
    if (content.contains(
      RegExp(r'personal|development|growth|self|awareness'),
    )) {
      score += 0.3;
    }

    // Psychology/emotional intelligence
    if (content.contains(
      RegExp(r'psychology|emotional|intelligence|therapy'),
    )) {
      score += 0.2;
    }

    // High engagement boost
    final views = video.engagement.viewCount;
    final likes = video.engagement.likeCount ?? 0;
    if (views > 0 && (likes / views) > 0.02) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate content priority for ordering
  int _calculatePriority(Video video, bool isFromMainPlaylist) {
    if (isFromMainPlaylist) return 2000; // High priority for main playlist

    final relevanceScore = _calculateRelevanceScore(video, false);
    final views = video.engagement.viewCount;
    final likes = video.engagement.likeCount ?? 0;
    final uploadDate = video.uploadDate ?? DateTime.now();
    final isRecent = DateTime.now().difference(uploadDate).inDays < 30;

    int priority = (relevanceScore * 1000).round(); // Base from relevance

    // Boost for high views
    if (views > 100000) {
      priority += 300;
    } else if (views > 50000) {
      priority += 200;
    } else if (views > 10000) {
      priority += 100;
    }

    // Boost for high engagement
    if (views > 0 && (likes / views) > 0.03) priority += 150;

    // Boost for recent content
    if (isRecent) priority += 100;

    return priority;
  }

  /// Get appropriate action text based on content
  String _getActionText(String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains(RegExp(r'learn|understand|discover'))) {
      return 'Learn';
    } else if (titleLower.contains(RegExp(r'practice|exercise|apply'))) {
      return 'Practice';
    } else if (titleLower.contains(RegExp(r'reflect|journal|think'))) {
      return 'Reflect';
    } else if (titleLower.contains(RegExp(r'grow|develop|improve'))) {
      return 'Grow';
    } else {
      return 'Watch';
    }
  }

  /// Check if content is worth sharing on LinkedIn
  bool _isLinkedInWorthy(String title, String description) {
    final content = '${title.toLowerCase()} ${description.toLowerCase()}';

    return content.contains(
      RegExp(
        r'professional|career|leadership|success|emotional intelligence|communication|development',
      ),
    );
  }

  /// Generate journal prompt based on video content
  String? _generateJournalPrompt(String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains(RegExp(r'attachment|relationship'))) {
      return 'How do my past relationships influence my current attachment patterns?';
    } else if (titleLower.contains(RegExp(r'emotional|intelligence'))) {
      return 'What emotions am I avoiding, and how does this affect my relationships?';
    } else if (titleLower.contains(RegExp(r'growth|development'))) {
      return 'What is one area of personal growth I want to focus on this month?';
    } else if (titleLower.contains(RegExp(r'self|awareness'))) {
      return 'What patterns in my behavior am I ready to acknowledge and change?';
    } else {
      return null;
    }
  }

  /// Format duration to readable string
  String? _formatDuration(Duration? duration) {
    if (duration == null) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format upload date to "time ago" string
  String _formatTimeAgo(DateTime uploadDate) {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Remove duplicate videos by ID
  List<GrowthMediaItem> _removeDuplicates(List<GrowthMediaItem> items) {
    final seen = <String>{};
    return items.where((item) => seen.add(item.id)).toList();
  }

  /// Cleanup resources
  void dispose() {
    _yt.close();
  }
}
