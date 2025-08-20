// lib/features/dashboard/widgets/personal_growth_media_carousel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/growth_media_item_model.dart';
import '../../../core/services/personal_growth_media_service.dart';

import 'error_widget.dart';
import 'skeleton_loader.dart';

class PersonalGrowthMediaCarousel extends StatefulWidget {
  final VoidCallback? onLinkedInConnect;
  final VoidCallback? onJournalStart;
  final VoidCallback? onCharacterSelect;

  const PersonalGrowthMediaCarousel({
    super.key,
    this.onLinkedInConnect,
    this.onJournalStart,
    this.onCharacterSelect,
  });

  @override
  State<PersonalGrowthMediaCarousel> createState() =>
      _PersonalGrowthMediaCarouselState();
}

class _PersonalGrowthMediaCarouselState
    extends State<PersonalGrowthMediaCarousel>
    with SingleTickerProviderStateMixin {
  final PersonalGrowthYouTubeService _youtubeService =
      PersonalGrowthYouTubeService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<GrowthMediaItem>? _mediaItems;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Start animation immediately for smooth loading
    _animationController.forward();

    _loadMediaContent();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> _loadMediaContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final mediaItems = await _youtubeService.getComprehensiveGrowthFeed();

      if (mounted) {
        setState(() {
          _mediaItems = mediaItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to load content. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen.withValues(alpha: 0.2),
                AppColors.primaryAccent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.psychology_outlined,
            color: AppColors.primarySageGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Growth Journey',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              Text(
                'Free personal development content',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: AppColors.primarySageGreen,
            size: 20,
          ),
          onPressed: _loadMediaContent,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SizedBox(
        height: 320,
        child: const LoadingCarousel(itemCount: 3, itemWidth: 260, spacing: 12),
      );
    } else if (_error != null) {
      return GrowthErrorWidget(
        error: _error,
        onRetry: _loadMediaContent,
        title: 'Growth Content Unavailable',
        subtitle: 'Check your connection and try again',
        icon: Icons.cloud_off_outlined,
      );
    } else if (_mediaItems == null || _mediaItems!.isEmpty) {
      return GrowthEmptyWidget(
        title: 'No Growth Content',
        subtitle: 'New personal development content coming soon',
        icon: Icons.psychology_outlined,
        onAction: _loadMediaContent,
        actionText: 'Refresh',
      );
    } else {
      return SizedBox(height: 320, child: _buildMediaStream());
    }
  }

  Widget _buildMediaStream() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _mediaItems!.length + 3, // Add 3 CTA cards
      itemBuilder: (context, index) {
        // Insert CTA cards at strategic positions
        if (index == 2) {
          return _buildLinkedInCard();
        } else if (index == 6) {
          return _buildJournalCard();
        } else if (index == 10) {
          return _buildCharacterCard();
        }

        // Adjust index for media items
        final mediaIndex =
            index -
            (index > 10
                ? 3
                : index > 6
                ? 2
                : index > 2
                ? 1
                : 0);
        if (mediaIndex >= _mediaItems!.length) return const SizedBox.shrink();

        final item = _mediaItems![mediaIndex];
        return Padding(
          padding: EdgeInsets.only(
            right: index < _mediaItems!.length + 2 ? 12 : 0,
          ),
          child: _buildMediaCard(item),
        );
      },
    );
  }

  Widget _buildMediaCard(GrowthMediaItem item) {
    return GestureDetector(
      onTap: () => _handleMediaTap(item),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail section
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.primaryColor.withValues(alpha: 0.3),
                    item.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Thumbnail or fallback
                  if (item.thumbnailUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        item.thumbnailUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildFallbackThumbnail(item),
                      ),
                    )
                  else
                    _buildFallbackThumbnail(item),

                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.categoryIcon,
                            size: 12,
                            color: AppColors.primaryAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category.name.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Duration badge
                  if (item.duration != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkBlue.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.duration!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // LinkedIn worthy indicator
                  if (item.linkedInWorthy)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primarySageGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_center,
                          size: 12,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.source,
                            style: AppTextStyles.caption.copyWith(
                              color: item.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMedium,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                        height: 1.2,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Bottom row with engagement and action
                    Row(
                      children: [
                        // Engagement metrics
                        if (item.views != null) ...[
                          Icon(
                            Icons.visibility_outlined,
                            size: 10,
                            color: AppColors.textMedium,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatNumber(item.views!),
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.likes != null) ...[
                          Icon(
                            Icons.favorite_outline,
                            size: 10,
                            color: AppColors.textMedium,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatNumber(item.likes!),
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 9,
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Action button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: item.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            item.actionText,
                            style: AppTextStyles.caption.copyWith(
                              color: item.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedInCard() {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySageGreen,
            AppColors.primaryAccent.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onLinkedInConnect?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business_center,
                    color: AppColors.primaryDarkBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Connect Your LinkedIn',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Share your growth journey professionally and build credibility.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Text(
                      'Link Profile',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryDarkBlue,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalCard() {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold,
            AppColors.primaryAccent.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onJournalStart?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: AppColors.primaryDarkBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Start Your Growth Journal',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Daily reflection for deeper self-awareness and relationship readiness.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Text(
                      'Begin Journaling',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryDarkBlue,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard() {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.electricBlue,
            AppColors.primaryAccent.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onCharacterSelect?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primaryDarkBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Choose Your Coach',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryDarkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Select a feedback character that matches your growth style.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Text(
                      'Select Coach',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryDarkBlue,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(GrowthMediaItem item) {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: item.primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(item.categoryIcon, size: 28, color: item.primaryColor),
      ),
    );
  }

  void _handleMediaTap(GrowthMediaItem item) {
    _playMedia(item);
  }

  void _playMedia(GrowthMediaItem item) async {
    try {
      if (item.videoUrl != null) {
        await _launchVideo(item);
      } else if (item.articleUrl != null) {
        await _launchArticle(item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open: ${item.title}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _launchVideo(GrowthMediaItem item) async {
    if (item.videoUrl != null) {
      final Uri videoUri = Uri.parse(item.videoUrl!);

      // Try YouTube app first, then browser
      final Uri youtubeAppUri = Uri.parse(
        item.videoUrl!.replaceFirst(
          'https://www.youtube.com/watch?v=',
          'youtube://',
        ),
      );

      bool launched = false;

      if (await canLaunchUrl(youtubeAppUri)) {
        launched = await launchUrl(
          youtubeAppUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && await canLaunchUrl(videoUri)) {
        launched = await launchUrl(
          videoUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open video'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _launchArticle(GrowthMediaItem item) async {
    if (item.articleUrl != null) {
      final Uri articleUri = Uri.parse(item.articleUrl!);

      if (await canLaunchUrl(articleUri)) {
        await launchUrl(articleUri, mode: LaunchMode.inAppBrowserView);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open article'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
