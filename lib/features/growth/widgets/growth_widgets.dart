// lib/features/growth/widgets/growth_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../models/growth_models.dart';

// =============================================================================
// GROWTH THEME COLORS
// =============================================================================

class GrowthColors {
  static const Color soulfulPurple = Color(0xFF8B5FBF);
  static const Color nurturingPink = Color(0xFFE8B4CB);
  static const Color growthGreen = Color(0xFF7FB069);
  static const Color hopeBlue = Color(0xFF4A90E2);
  static const Color warmGold = Color(0xFFF4D03F);
  static const Color softLavender = Color(0xFFF3E8FF);
  static const Color gentleMint = Color(0xFFE8F5E8);
  static const Color creamyWhite = Color(0xFFFFFBF5);
  static const Color whisperGray = Color(0xFFF8F7F5);
}

// =============================================================================
// GLASSMORPHISM CONTAINER
// =============================================================================

// REPLACE your current GlassmorphicContainer class with this:

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width; // <- CHANGED: Made nullable (optional)
  final double? height; // <- CHANGED: Made nullable (optional)
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double opacity;
  final double blur;
  final List<BoxShadow>? shadows;
  final Border? border;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width, // <- CHANGED: No default value
    this.height, // <- CHANGED: No default value
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.backgroundColor,
    this.opacity = 0.2,
    this.blur = 20,
    this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          width, // <- Will be null if not specified, Container handles this properly
      height:
          height, // <- Will be null if not specified, Container handles this properly
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ?? Colors.white).withValues(
                alpha: opacity,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
// =============================================================================
// GROWTH DASHBOARD CARD
// =============================================================================

class GrowthDashboardCard extends StatelessWidget {
  final GrowthProfile? profile;
  final VoidCallback onTap;
  final bool isLoading;

  const GrowthDashboardCard({
    super.key,
    this.profile,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (profile == null) {
      return _buildErrorCard();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation),
          child: Opacity(
            opacity: animation,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              child: GlassmorphicContainer(
                height: 220,
                padding: const EdgeInsets.all(24),
                backgroundColor: GrowthColors.softLavender,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                GrowthColors.soulfulPurple,
                                GrowthColors.hopeBlue,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: GrowthColors.soulfulPurple.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Growth Journey',
                                style: AppTextStyles.heading3.copyWith(
                                  color: GrowthColors.soulfulPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getGrowthLevel(profile!.overallGrowthScore),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: GrowthColors.hopeBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: GrowthColors.warmGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GrowthColors.warmGold.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            '${profile!.overallGrowthScore} pts',
                            style: AppTextStyles.caption.copyWith(
                              color: GrowthColors.warmGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress bar
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0.0,
                        end: (profile!.overallGrowthScore / 500).clamp(
                          0.0,
                          1.0,
                        ),
                      ),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, progress, child) {
                        return LinearPercentIndicator(
                          lineHeight: 12,
                          percent: progress,
                          backgroundColor: GrowthColors.softLavender,
                          progressColor: GrowthColors.soulfulPurple,
                          barRadius: const Radius.circular(6),
                          padding: EdgeInsets.zero,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildStatChip(
                          '🔥 ${profile!.currentStreak}',
                          'Day Streak',
                          GrowthColors.nurturingPink,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          '✅ ${profile!.totalTasksCompleted}',
                          'Tasks Done',
                          GrowthColors.growthGreen,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          '📝 ${profile!.totalJournalEntries}',
                          'Reflections',
                          GrowthColors.hopeBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return GlassmorphicContainer(
      height: 220,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  GrowthColors.soulfulPurple,
                ),
                strokeWidth: 3,
              ),
            ),
          ),
          Text(
            'Loading your growth journey... 🌱',
            style: AppTextStyles.bodyMedium.copyWith(
              color: GrowthColors.soulfulPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return GlassmorphicContainer(
      height: 220,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh, color: GrowthColors.nurturingPink, size: 48),
          const SizedBox(height: 16),
          Text(
            'Let\'s start your growth journey!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: GrowthColors.soulfulPurple,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getGrowthLevel(int score) {
    if (score >= 500) return 'Love Magnet 🧲';
    if (score >= 300) return 'Heart Healer 💚';
    if (score >= 150) return 'Soul Seeker 🔍';
    if (score >= 50) return 'Growth Explorer 🌱';
    return 'Love Beginner 💫';
  }
}

// =============================================================================
// GROWTH TASK CARD
// =============================================================================

// Key fixes for the widgets that were causing constraint issues:

// 1. GrowthTaskCard - Remove infinite height, let it size naturally
class GrowthTaskCard extends StatelessWidget {
  final GrowthTask task;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  final bool isCompleting;

  const GrowthTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onTap,
    this.isCompleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassmorphicContainer(
                  // REMOVED: height parameter - let it size naturally
                  padding: const EdgeInsets.all(20),
                  backgroundColor:
                      task.isCompleted
                          ? GrowthColors.gentleMint
                          : GrowthColors.creamyWhite,
                  border: Border.all(
                    color:
                        task.isCompleted
                            ? GrowthColors.growthGreen.withValues(alpha: 0.4)
                            : task.categoryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ADDED: Minimize height
                    children: [
                      // ... rest of your widget content stays the same
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    task.isCompleted
                                        ? [
                                          GrowthColors.growthGreen,
                                          GrowthColors.growthGreen.withValues(
                                            alpha: 0.8,
                                          ),
                                        ]
                                        : [
                                          task.categoryColor,
                                          task.categoryColor.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (task.isCompleted
                                          ? GrowthColors.growthGreen
                                          : task.categoryColor)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              task.isCompleted
                                  ? Icons.check_circle
                                  : _getCategoryIcon(task.category),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration:
                                        task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        task.isCompleted
                                            ? GrowthColors.growthGreen
                                            : GrowthColors.soulfulPurple,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      task.difficultyEmoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: task.categoryColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${task.estimatedMinutes} min • ${task.pointValue} pts',
                                        style: AppTextStyles.caption.copyWith(
                                          color: task.categoryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        task.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: task.categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.categoryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: task.categoryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.encouragementMessage,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: task.categoryColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!task.isCompleted)
                        _buildCompleteButton()
                      else
                        _buildCompletedBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Keep your existing helper methods unchanged
  Widget _buildCompleteButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * animation),
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTapDown: (_) => HapticFeedback.lightImpact(),
              onTap: isCompleting ? null : onComplete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      task.categoryColor,
                      task.categoryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: task.categoryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleting)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleting ? 'Completing...' : 'Complete Task ✨',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GrowthColors.growthGreen,
                  GrowthColors.growthGreen.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: GrowthColors.growthGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Completed! You\'re amazing! 🎉',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(GrowthCategory category) {
    switch (category) {
      case GrowthCategory.communication:
        return Icons.chat_bubble_outline;
      case GrowthCategory.emotional:
        return Icons.favorite_outline;
      case GrowthCategory.social:
        return Icons.people_outline;
      case GrowthCategory.selfAwareness:
        return Icons.psychology_outlined;
      case GrowthCategory.lifestyle:
        return Icons.spa_outlined;
      case GrowthCategory.confidence:
        return Icons.star_outline;
    }
  }
}

// 2. JournalEntryCard - Also ensure natural sizing
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassmorphicContainer(
                  // REMOVED: height parameter - let it size naturally
                  padding: const EdgeInsets.all(20),
                  backgroundColor: GrowthColors.creamyWhite,
                  border: Border.all(
                    color: entry.moodColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ADDED: Minimize height
                    children: [
                      // ... rest of your content stays the same
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: entry.moodColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: entry.moodColor.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                entry.moodEmoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: GrowthColors.soulfulPurple,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(entry.createdAt),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: entry.moodColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.moodIntensity}/10',
                              style: AppTextStyles.caption.copyWith(
                                color: entry.moodColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              entry.tags.take(3).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GrowthColors.hopeBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: AppTextStyles.caption.copyWith(
                                      color: GrowthColors.hopeBlue,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// 3. GrowthStatsWidget - Ensure proper sizing
class GrowthStatsWidget extends StatelessWidget {
  final GrowthAnalytics? analytics;
  final bool isLoading;

  const GrowthStatsWidget({super.key, this.analytics, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingStats();
    }

    if (analytics == null) {
      return _buildEmptyStats();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation,
          child: GlassmorphicContainer(
            // REMOVED: height parameter - let it size naturally
            padding: const EdgeInsets.all(20),
            backgroundColor: GrowthColors.gentleMint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ADDED: Minimize height
              children: [
                Text(
                  'This Month\'s Growth 📈',
                  style: AppTextStyles.heading3.copyWith(
                    color: GrowthColors.growthGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatBox(
                      '✅',
                      '${analytics!.tasksCompleted}',
                      'Tasks Completed',
                      GrowthColors.growthGreen,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBox(
                      '📝',
                      '${analytics!.journalEntries}',
                      'Journal Entries',
                      GrowthColors.hopeBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatBox(
                      '🔥',
                      '${analytics!.streakDays}',
                      'Streak Days',
                      GrowthColors.nurturingPink,
                    ),
                    const SizedBox(width: 12),
                    _buildStatBox(
                      '💖',
                      '${analytics!.datingReadinessScore.toInt()}%',
                      'Love Readiness',
                      GrowthColors.soulfulPurple,
                    ),
                  ],
                ),
                if (analytics!.insights.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GrowthColors.warmGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GrowthColors.warmGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: GrowthColors.warmGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your growth trend: ${analytics!.growthTrend} 🌟',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: GrowthColors.warmGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStats() {
    return GlassmorphicContainer(
      // REMOVED: height parameter
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ADDED: Minimize height
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(GrowthColors.growthGreen),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Calculating your amazing progress... 📊',
            style: AppTextStyles.bodyMedium.copyWith(
              color: GrowthColors.growthGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStats() {
    return GlassmorphicContainer(
      // REMOVED: height parameter
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ADDED: Minimize height
        children: [
          Icon(Icons.insights, color: GrowthColors.hopeBlue, size: 48),
          const SizedBox(height: 16),
          Text(
            'Start your journey to see beautiful insights! 🌱',
            style: AppTextStyles.bodyMedium.copyWith(
              color: GrowthColors.hopeBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CELEBRATION OVERLAY
// =============================================================================

class CelebrationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const CelebrationOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleController.forward();
    _fadeController.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _fadeController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: Colors.black.withValues(alpha: 0.5),
            child: GestureDetector(
              onTap: _dismiss,
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(32),
                    backgroundColor: GrowthColors.warmGold,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, animation, child) {
                            return Transform.scale(
                              scale: animation,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GrowthColors.warmGold,
                                      GrowthColors.nurturingPink,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: GrowthColors.warmGold.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.celebration,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        Text(
                          widget.message,
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Tap anywhere to continue',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
