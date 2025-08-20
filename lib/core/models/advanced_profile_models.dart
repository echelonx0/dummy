// lib/core/models/advanced_profile.dart
import 'package:flutter/material.dart';

enum AdvancedProfileType {
  linkedin,
  personalWebsite,
  instagram,
  twitter,
  github,
  behance,
  portfolio,
  youtube,
  tiktok,
  spotify,
  goodreads,
  strava,
  medium,
  substack,
  custom,
}

extension AdvancedProfileTypeExtension on AdvancedProfileType {
  String get displayName {
    switch (this) {
      case AdvancedProfileType.linkedin:
        return 'LinkedIn Profile';
      case AdvancedProfileType.personalWebsite:
        return 'Personal Website';
      case AdvancedProfileType.instagram:
        return 'Instagram';
      case AdvancedProfileType.twitter:
        return 'Twitter/X';
      case AdvancedProfileType.github:
        return 'GitHub';
      case AdvancedProfileType.behance:
        return 'Behance';
      case AdvancedProfileType.portfolio:
        return 'Portfolio';
      case AdvancedProfileType.youtube:
        return 'YouTube';
      case AdvancedProfileType.tiktok:
        return 'TikTok';
      case AdvancedProfileType.spotify:
        return 'Spotify';
      case AdvancedProfileType.goodreads:
        return 'Goodreads';
      case AdvancedProfileType.strava:
        return 'Strava';
      case AdvancedProfileType.medium:
        return 'Medium';
      case AdvancedProfileType.substack:
        return 'Substack';
      case AdvancedProfileType.custom:
        return 'Custom Link';
    }
  }

  String get subtitle {
    switch (this) {
      case AdvancedProfileType.linkedin:
        return 'Professional background';
      case AdvancedProfileType.personalWebsite:
        return 'Your personal domain';
      case AdvancedProfileType.instagram:
        return 'Visual storytelling';
      case AdvancedProfileType.twitter:
        return 'Thoughts and insights';
      case AdvancedProfileType.github:
        return 'Code and projects';
      case AdvancedProfileType.behance:
        return 'Creative portfolio';
      case AdvancedProfileType.portfolio:
        return 'Professional work';
      case AdvancedProfileType.youtube:
        return 'Video content';
      case AdvancedProfileType.tiktok:
        return 'Short-form videos';
      case AdvancedProfileType.spotify:
        return 'Music taste';
      case AdvancedProfileType.goodreads:
        return 'Reading preferences';
      case AdvancedProfileType.strava:
        return 'Fitness journey';
      case AdvancedProfileType.medium:
        return 'Written thoughts';
      case AdvancedProfileType.substack:
        return 'Newsletter/writing';
      case AdvancedProfileType.custom:
        return 'Other online presence';
    }
  }

  IconData get icon {
    switch (this) {
      case AdvancedProfileType.linkedin:
        return Icons.business_center;
      case AdvancedProfileType.personalWebsite:
        return Icons.language;
      case AdvancedProfileType.instagram:
        return Icons.photo_camera;
      case AdvancedProfileType.twitter:
        return Icons.chat_bubble_outline;
      case AdvancedProfileType.github:
        return Icons.code;
      case AdvancedProfileType.behance:
        return Icons.palette;
      case AdvancedProfileType.portfolio:
        return Icons.work_outline;
      case AdvancedProfileType.youtube:
        return Icons.play_circle_outline;
      case AdvancedProfileType.tiktok:
        return Icons.music_video;
      case AdvancedProfileType.spotify:
        return Icons.music_note;
      case AdvancedProfileType.goodreads:
        return Icons.menu_book;
      case AdvancedProfileType.strava:
        return Icons.directions_run;
      case AdvancedProfileType.medium:
        return Icons.article;
      case AdvancedProfileType.substack:
        return Icons.email;
      case AdvancedProfileType.custom:
        return Icons.link;
    }
  }

  String get placeholder {
    switch (this) {
      case AdvancedProfileType.linkedin:
        return 'https://linkedin.com/in/yourprofile';
      case AdvancedProfileType.personalWebsite:
        return 'https://yourname.com';
      case AdvancedProfileType.instagram:
        return 'https://instagram.com/username';
      case AdvancedProfileType.twitter:
        return 'https://twitter.com/username';
      case AdvancedProfileType.github:
        return 'https://github.com/username';
      case AdvancedProfileType.behance:
        return 'https://behance.net/username';
      case AdvancedProfileType.portfolio:
        return 'https://yourportfolio.com';
      case AdvancedProfileType.youtube:
        return 'https://youtube.com/c/yourchannel';
      case AdvancedProfileType.tiktok:
        return 'https://tiktok.com/@username';
      case AdvancedProfileType.spotify:
        return 'https://open.spotify.com/user/username';
      case AdvancedProfileType.goodreads:
        return 'https://goodreads.com/user/show/username';
      case AdvancedProfileType.strava:
        return 'https://strava.com/athletes/username';
      case AdvancedProfileType.medium:
        return 'https://medium.com/@username';
      case AdvancedProfileType.substack:
        return 'https://yourname.substack.com';
      case AdvancedProfileType.custom:
        return 'https://example.com';
    }
  }

  // Basic URL pattern validation
  RegExp get urlPattern {
    switch (this) {
      case AdvancedProfileType.linkedin:
        return RegExp(r'^https?://(www\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$');
      case AdvancedProfileType.instagram:
        return RegExp(r'^https?://(www\.)?instagram\.com/[a-zA-Z0-9_.]+/?$');
      case AdvancedProfileType.twitter:
        return RegExp(
          r'^https?://(www\.)?(twitter\.com|x\.com)/[a-zA-Z0-9_]+/?$',
        );
      case AdvancedProfileType.github:
        return RegExp(r'^https?://(www\.)?github\.com/[a-zA-Z0-9-]+/?$');
      case AdvancedProfileType.behance:
        return RegExp(r'^https?://(www\.)?behance\.net/[a-zA-Z0-9_]+/?$');
      case AdvancedProfileType.youtube:
        return RegExp(
          r'^https?://(www\.)?youtube\.com/(c|channel|user)/[a-zA-Z0-9_-]+/?$',
        );
      case AdvancedProfileType.tiktok:
        return RegExp(r'^https?://(www\.)?tiktok\.com/@[a-zA-Z0-9_.]+/?$');
      case AdvancedProfileType.spotify:
        return RegExp(r'^https?://open\.spotify\.com/user/[a-zA-Z0-9_]+/?$');
      case AdvancedProfileType.goodreads:
        return RegExp(
          r'^https?://(www\.)?goodreads\.com/user/show/[a-zA-Z0-9_-]+/?$',
        );
      case AdvancedProfileType.strava:
        return RegExp(r'^https?://(www\.)?strava\.com/athletes/[0-9]+/?$');
      case AdvancedProfileType.medium:
        return RegExp(r'^https?://(www\.)?medium\.com/@[a-zA-Z0-9_.-]+/?$');
      case AdvancedProfileType.substack:
        return RegExp(r'^https?://[a-zA-Z0-9-]+\.substack\.com/?$');
      default:
        // Generic URL validation for website and custom
        return RegExp(r'^https?://(www\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$');
    }
  }
}

class AdvancedProfileLink {
  final AdvancedProfileType type;
  final String url;
  final String? customTitle; // For custom links
  final DateTime addedAt;
  final bool isVerified;

  const AdvancedProfileLink({
    required this.type,
    required this.url,
    this.customTitle,
    required this.addedAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'url': url,
      'customTitle': customTitle,
      'addedAt': addedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory AdvancedProfileLink.fromMap(Map<String, dynamic> map) {
    return AdvancedProfileLink(
      type: AdvancedProfileType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AdvancedProfileType.custom,
      ),
      url: map['url'] ?? '',
      customTitle: map['customTitle'],
      addedAt: DateTime.parse(map['addedAt']),
      isVerified: map['isVerified'] ?? false,
    );
  }

  AdvancedProfileLink copyWith({
    AdvancedProfileType? type,
    String? url,
    String? customTitle,
    DateTime? addedAt,
    bool? isVerified,
  }) {
    return AdvancedProfileLink(
      type: type ?? this.type,
      url: url ?? this.url,
      customTitle: customTitle ?? this.customTitle,
      addedAt: addedAt ?? this.addedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

// Validation results
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final bool isReachable; // For URL accessibility check

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.isReachable = false,
  });

  static ValidationResult success() =>
      const ValidationResult(isValid: true, isReachable: true);

  static ValidationResult error(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}
