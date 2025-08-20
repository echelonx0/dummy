// lib/features/growth/widgets/enhanced_growth_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../models/growth_models.dart';

// =============================================================================
// ENHANCED GLASSMORPHIC CONTAINER
// =============================================================================

class EnhancedGlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double opacity;
  final double blur;
  final List<BoxShadow>? shadows;
  final Border? border;
  final Gradient? gradient;

  const EnhancedGlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppDimensions.paddingL),
    this.margin,
    this.borderRadius = AppDimensions.cardBorderRadius,
    this.backgroundColor,
    this.opacity = 0.1,
    this.blur = 20,
    this.shadows,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: AppColors.primaryDarkBlue.withValues(
                  alpha: 0.08.clamp(0.0, 1.0),
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8.clamp(0.0, 1.0)),
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
                alpha: opacity.clamp(0.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  border ??
                  Border.all(
                    color: AppColors.primaryAccent.withValues(
                      alpha: 0.1.clamp(0.0, 1.0),
                    ),
                    width: 1,
                  ),
              gradient:
                  gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryAccent.withValues(
                        alpha: 0.05.clamp(0.0, 1.0),
                      ),
                      AppColors.primaryGold.withValues(
                        alpha: 0.03.clamp(0.0, 1.0),
                      ),
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
// ROMANTIC GROWTH DASHBOARD CARD
// =============================================================================

class RomanticGrowthDashboardCard extends StatelessWidget {
  final GrowthProfile? profile;
  final VoidCallback onTap;
  final bool isLoading;

  const RomanticGrowthDashboardCard({
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
      return _buildWelcomeCard();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * animation),
          child: Opacity(
            opacity: animation.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              child: EnhancedGlassmorphicContainer(
                backgroundColor: AppColors.softPink,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryAccent.withValues(
                      alpha: 0.1.clamp(0.0, 1.0),
                    ),
                    AppColors.primaryGold.withValues(
                      alpha: 0.1.clamp(0.0, 1.0),
                    ),
                    AppColors.primarySageGreen.withValues(
                      alpha: 0.05.clamp(0.0, 1.0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildProgressSection(),
                    const SizedBox(height: AppDimensions.paddingM),
                    _buildStatsRow(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withValues(
                  alpha: 0.3.clamp(0.0, 1.0),
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Love Journey',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getGrowthLevel(profile!.overallGrowthScore),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.accentGradient),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${profile!.overallGrowthScore}',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final progress = (profile!.overallGrowthScore / 500).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Love Readiness',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.softPink,
              ),
              child: LinearProgressIndicator(
                value: animatedProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAccent,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatChip(
          '🔥 ${profile!.currentStreak}',
          'Streak',
          AppColors.primaryAccent,
        ),
        const SizedBox(width: AppDimensions.paddingS),
        _buildStatChip(
          '✅ ${profile!.totalTasksCompleted}',
          'Growth',
          AppColors.primarySageGreen,
        ),
        const SizedBox(width: AppDimensions.paddingS),
        _buildStatChip(
          '💭 ${profile!.totalJournalEntries}',
          'Insights',
          AppColors.primaryGold,
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingS,
          horizontal: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1.clamp(0.0, 1.0)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: color.withValues(alpha: 0.2.clamp(0.0, 1.0)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8.clamp(0.0, 1.0)),
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return EnhancedGlassmorphicContainer(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
            strokeWidth: 3,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Preparing your love journey... 💕',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return EnhancedGlassmorphicContainer(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: AppColors.primaryAccent, size: 48),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Begin Your Love Journey',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDarkBlue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Grow into the best version of yourself',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getGrowthLevel(int score) {
    if (score >= 500) return 'Love Ready 💕';
    if (score >= 300) return 'Heart Open 💖';
    if (score >= 150) return 'Soul Growing 🌱';
    if (score >= 50) return 'Love Explorer ✨';
    return 'New Beginning 💫';
  }
}

// =============================================================================
// ROMANTIC GROWTH TASK CARD
// =============================================================================

class RomanticGrowthTaskCard extends StatelessWidget {
  final GrowthTask task;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  final bool isCompleting;

  const RomanticGrowthTaskCard({
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
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                child: EnhancedGlassmorphicContainer(
                  backgroundColor:
                      task.isCompleted
                          ? AppColors.success.withValues(
                            alpha: 0.05.clamp(0.0, 1.0),
                          )
                          : AppColors.softPink,
                  border: Border.all(
                    color:
                        task.isCompleted
                            ? AppColors.success.withValues(
                              alpha: 0.3.clamp(0.0, 1.0),
                            )
                            : AppColors.primaryAccent.withValues(
                              alpha: 0.2.clamp(0.0, 1.0),
                            ),
                    width: 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTaskHeader(),
                      const SizedBox(height: AppDimensions.paddingM),
                      _buildTaskDescription(),
                      const SizedBox(height: AppDimensions.paddingM),
                      _buildEncouragementSection(),
                      const SizedBox(height: AppDimensions.paddingL),
                      _buildActionButton(),
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

  Widget _buildTaskHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient:
                task.isCompleted
                    ? LinearGradient(
                      colors: [AppColors.success, AppColors.success],
                    )
                    : LinearGradient(colors: AppColors.primaryGradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (task.isCompleted
                        ? AppColors.success
                        : AppColors.primaryAccent)
                    .withValues(alpha: 0.3.clamp(0.0, 1.0)),
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
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                  color:
                      task.isCompleted
                          ? AppColors.success
                          : AppColors.primaryDarkBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    task.difficultyEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withValues(
                        alpha: 0.1.clamp(0.0, 1.0),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Text(
                      '${task.estimatedMinutes} min • ${task.pointValue} pts',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDescription() {
    return Text(
      task.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEncouragementSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1.clamp(0.0, 1.0)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.2.clamp(0.0, 1.0)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: AppColors.primaryGold, size: 16),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              task.encouragementMessage,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGold,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (task.isCompleted) {
      return _buildCompletedBadge();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCompleting ? null : onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          elevation: 6,
          shadowColor: AppColors.primaryAccent.withValues(
            alpha: 0.3.clamp(0.0, 1.0),
          ),
        ),
        child:
            isCompleting
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, size: 18),
                    const SizedBox(width: AppDimensions.paddingS),
                    Text(
                      'Complete Task',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation.clamp(0.0, 1.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.8.clamp(0.0, 1.0)),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(
                    alpha: 0.3.clamp(0.0, 1.0),
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 20),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  'Completed! You\'re amazing! 🎉',
                  style: AppTextStyles.button.copyWith(
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

// =============================================================================
// ROMANTIC JOURNAL ENTRY CARD
// =============================================================================

class RomanticJournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const RomanticJournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - animation)),
          child: Opacity(
            opacity: animation.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                child: EnhancedGlassmorphicContainer(
                  backgroundColor: AppColors.softPink,
                  border: Border.all(
                    color: _getMoodColor(
                      entry.mood,
                    ).withValues(alpha: 0.3.clamp(0.0, 1.0)),
                    width: 1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEntryHeader(),
                      const SizedBox(height: AppDimensions.paddingM),
                      _buildEntryContent(),
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingS),
                        _buildTagsSection(),
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

  Widget _buildEntryHeader() {
    return Row(
      children: [
        // Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: _getMoodColor(entry.mood).withValues(alpha: 0.2.clamp(0.0, 1.0)),
        //     shape: BoxShape.circle,
        //     border: Border.all(
        //       color: _getMoodColor(entry.mood).withValues(alpha: 0.4.clamp(0.0, 1.0)),
        //       width: 1,
        //     ),
        //   ),
        //   child: Center(
        //     child: Text(
        //       _getMoodEmoji(entry.mood),
        //       style: const TextStyle(fontSize: 18),
        //     ),
        //   ),
        // ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
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
            horizontal: AppDimensions.paddingS,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getMoodColor(
              entry.mood,
            ).withValues(alpha: 0.15.clamp(0.0, 1.0)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Text(
            '${entry.moodIntensity}/10',
            style: AppTextStyles.caption.copyWith(
              color: _getMoodColor(entry.mood),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryContent() {
    return Text(
      entry.content,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          entry.tags.take(3).map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySageGreen.withValues(
                  alpha: 0.1.clamp(0.0, 1.0),
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                '#$tag',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primarySageGreen,
                  fontSize: 9,
                ),
              ),
            );
          }).toList(),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.excited:
        return AppColors.primaryGold;
      case MoodType.happy:
        return AppColors.primaryAccent;
      case MoodType.content:
        return AppColors.success;
      case MoodType.neutral:
        return AppColors.textMedium;
      case MoodType.anxious:
        return AppColors.warning;
      case MoodType.sad:
        return AppColors.primarySageGreen;
      case MoodType.frustrated:
        return AppColors.error;
      case MoodType.confident:
        return AppColors.primaryDarkBlue;
      case MoodType.grateful:
        return AppColors.primaryAccent;
      case MoodType.inspired:
        return AppColors.primaryGold;
    }
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

// =============================================================================
// ROMANTIC GROWTH STATS WIDGET
// =============================================================================

class RomanticGrowthStatsWidget extends StatelessWidget {
  final GrowthAnalytics? analytics;
  final bool isLoading;

  const RomanticGrowthStatsWidget({
    super.key,
    this.analytics,
    this.isLoading = false,
  });

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
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation.clamp(0.0, 1.0),
          child: EnhancedGlassmorphicContainer(
            backgroundColor: AppColors.softPink,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primarySageGreen.withValues(
                  alpha: 0.05.clamp(0.0, 1.0),
                ),
                AppColors.primaryGold.withValues(alpha: 0.05.clamp(0.0, 1.0)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatsHeader(),
                const SizedBox(height: AppDimensions.paddingL),
                _buildStatsGrid(),
                if (analytics!.insights.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingL),
                  _buildInsightSection(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Text(
          'Growth logs 📈',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatBox(
              '✅',
              '${analytics!.tasksCompleted}',
              'Tasks Done',
              AppColors.success,
            ),
            const SizedBox(width: AppDimensions.paddingM),
            _buildStatBox(
              '📝',
              '${analytics!.journalEntries}',
              'Reflections',
              AppColors.primarySageGreen,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          children: [
            _buildStatBox(
              '🔥',
              '${analytics!.streakDays}',
              'Day Streak',
              AppColors.primaryAccent,
            ),
            const SizedBox(width: AppDimensions.paddingM),
            _buildStatBox(
              '💕',
              '${analytics!.datingReadinessScore.toInt()}%',
              'Love Ready',
              AppColors.primaryGold,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1.clamp(0.0, 1.0)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: color.withValues(alpha: 0.2.clamp(0.0, 1.0)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppDimensions.paddingS),
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
                color: color.withValues(alpha: 0.8.clamp(0.0, 1.0)),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1.clamp(0.0, 1.0)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.2.clamp(0.0, 1.0)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              'Your growth trend: ${analytics!.growthTrend} 🌟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return EnhancedGlassmorphicContainer(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
            strokeWidth: 3,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Calculating your amazing progress... 📊',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStats() {
    return EnhancedGlassmorphicContainer(
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights, color: AppColors.primarySageGreen, size: 48),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Start your journey to see beautiful insights! 🌱',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primarySageGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ROMANTIC CELEBRATION OVERLAY
// =============================================================================

class RomanticCelebrationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final String? subtitle;

  const RomanticCelebrationOverlay({
    super.key,
    required this.message,
    required this.onDismiss,
    this.subtitle,
  });

  @override
  State<RomanticCelebrationOverlay> createState() =>
      _RomanticCelebrationOverlayState();
}

class _RomanticCelebrationOverlayState extends State<RomanticCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    _confettiController.forward();

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
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Material(
            color: AppColors.primaryDarkBlue.withValues(
              alpha: 0.6.clamp(0.0, 1.0),
            ),
            child: GestureDetector(
              onTap: _dismiss,
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value.clamp(0.0, 1.0),
                  child: EnhancedGlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.85,
                    backgroundColor: AppColors.softPink,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryAccent.withValues(
                          alpha: 0.1.clamp(0.0, 1.0),
                        ),
                        AppColors.primaryGold.withValues(
                          alpha: 0.1.clamp(0.0, 1.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                          builder: (context, animation, child) {
                            return Transform.scale(
                              scale: animation.clamp(0.0, 1.0),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAccent.withValues(
                                        alpha: 0.4.clamp(0.0, 1.0),
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
                        const SizedBox(height: AppDimensions.paddingL),
                        Text(
                          widget.message,
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primaryDarkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: AppDimensions.paddingS),
                          Text(
                            widget.subtitle!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppDimensions.paddingL),
                        Text(
                          'Tap anywhere to continue',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w500,
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

// =============================================================================
// ROMANTIC QUICK ACTION BUTTON
// =============================================================================

class RomanticQuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RomanticQuickActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: EnhancedGlassmorphicContainer(
        backgroundColor: color.withValues(alpha: 0.05.clamp(0.0, 1.0)),
        border: Border.all(color: color.withValues(alpha: 0.2.clamp(0.0, 1.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6.clamp(0.0, 1.0)),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.8.clamp(0.0, 1.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ROMANTIC SECTION HEADER
// =============================================================================

class RomanticSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;
  final Color? color;

  const RomanticSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sectionColor = color ?? AppColors.primaryDarkBlue;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: sectionColor.withValues(alpha: 0.1.clamp(0.0, 1.0)),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: sectionColor, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  color: sectionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onActionTap!();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: sectionColor.withValues(alpha: 0.1.clamp(0.0, 1.0)),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Text(
                actionText!,
                style: AppTextStyles.caption.copyWith(
                  color: sectionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
