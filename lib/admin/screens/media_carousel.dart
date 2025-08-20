// lib/src/features/media/presentation/widgets/simplified_racing_media_widget.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';

// Simplified Media Item Model
class MediaItem {
  final String id;
  final String youtubeUrl;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  MediaItem({
    required this.id,
    required this.youtubeUrl,
    required this.title,
    this.description,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  factory MediaItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MediaItem(
      id: doc.id,
      youtubeUrl: data['youtubeUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get videoId {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regex.firstMatch(youtubeUrl);
    return match?.group(1) ?? '';
  }

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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
}

// Simplified Providers
final mediaStreamProvider = StreamProvider<List<MediaItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('media_items')
      .where('isActive', isEqualTo: true)
      .where('expiresAt', isGreaterThan: Timestamp.now())
      .orderBy('expiresAt')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => MediaItem.fromFirestore(doc))
                .where((item) => !item.isExpired)
                .toList(),
      );
});

final isRefreshingProvider = StateProvider<bool>((ref) => false);

// Main Widget (keeping your exact UI design)
class MediaCarousel extends ConsumerWidget {
  const MediaCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(mediaStreamProvider);
    final isRefreshing = ref.watch(isRefreshingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref, isRefreshing),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: mediaAsync.when(
            data: (mediaItems) => _buildMediaContent(context, ref, mediaItems),
            loading: () => _buildSkeletonLoader(),
            error: (error, stackTrace) => _buildErrorState(context, ref, error),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isRefreshing) {
    final mediaAsync = ref.watch(mediaStreamProvider);
    final hasLive = mediaAsync.maybeWhen(
      data:
          (items) =>
              items.any((item) => item.title.toLowerCase().contains('live')),
      orElse: () => false,
    );

    return Row(
      children: [
        Text(
          'Recommended Media',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),

        // Live indicator
        if (hasLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Loading indicator
        if (isRefreshing)
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primarySageGreen.withAlpha(179),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Refreshing...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                ),
              ],
            ),
          ),

        const Spacer(),

        // Refresh button
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: AppColors.primarySageGreen,
            size: 20,
          ),
          onPressed: isRefreshing ? null : () => _refreshMedia(ref),
        ),
      ],
    );
  }

  Widget _buildMediaContent(
    BuildContext context,
    WidgetRef ref,
    List<MediaItem> mediaItems,
  ) {
    if (mediaItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        return Padding(
          padding: EdgeInsets.only(
            right: index < mediaItems.length - 1 ? 12 : 0,
          ),
          child: _buildMediaCard(context, ref, item),
        );
      },
    );
  }

  Widget _buildMediaCard(BuildContext context, WidgetRef ref, MediaItem item) {
    final isLive = item.title.toLowerCase().contains('live');
    final primaryColor = AppColors.primarySageGreen;

    return GestureDetector(
      onTap: () => _handleMediaTap(context, item),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha(25), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail section (keeping your exact design)
            _buildThumbnail(item, isLive, primaryColor),

            // Content section (keeping your exact design)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source row
                    _buildSourceRow(context, item, primaryColor),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
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
                      item.description ?? 'YouTube Racing Content',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        height: 1.2,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Bottom action row
                    _buildActionRow(context, item, primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(MediaItem item, bool isLive, Color primaryColor) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withAlpha(128), primaryColor.withAlpha(77)],
        ),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              item.thumbnailUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(primaryColor);
              },
              errorBuilder:
                  (context, error, stackTrace) =>
                      _buildImagePlaceholder(primaryColor),
            ),
          ),

          // Overlays
          _buildThumbnailOverlays(item, isLive),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withAlpha(128), primaryColor.withAlpha(77)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow,
          size: 44,
          color: Colors.white.withAlpha(179),
        ),
      ),
    );
  }

  Widget _buildThumbnailOverlays(MediaItem item, bool isLive) {
    return Stack(
      children: [
        // Media type badge
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(179),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Live indicator
        if (isLive)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // YouTube badge
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'YT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceRow(
    BuildContext context,
    MediaItem item,
    Color primaryColor,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: primaryColor.withAlpha(51),
          child: Icon(Icons.smart_display, size: 10, color: primaryColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'YouTube',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          item.timeAgo,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    MediaItem item,
    Color primaryColor,
  ) {
    return Row(
      children: [
        const Spacer(),
        // Action button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(77),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Watch',
            style: TextStyle(
              color: primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder:
          (context, index) => Container(
            width: 260,
            margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
            decoration: BoxDecoration(
              color: AppColors.secondaryButton,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Skeleton thumbnail
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(51),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primarySageGreen.withAlpha(179),
                      ),
                    ),
                  ),
                ),

                // Skeleton content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Skeleton source row
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(51),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 80,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(51),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Skeleton title
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(51),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 180,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(51),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),

                        const Spacer(),

                        // Skeleton bottom row
                        Row(
                          children: [
                            const Spacer(),
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    log(error.toString());
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryButton,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withAlpha(77)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.withAlpha(179),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load media $error',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refreshMedia(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySageGreen,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined, color: Colors.grey, size: 48),
              SizedBox(height: 12),
              Text(
                'No media available',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add some YouTube videos to get started',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Media interaction methods
  void _handleMediaTap(BuildContext context, MediaItem item) async {
    try {
      final Uri videoUri = Uri.parse(item.youtubeUrl);
      final Uri youtubeAppUri = Uri.parse(
        item.youtubeUrl.replaceFirst(
          'https://www.youtube.com/watch?v=',
          'youtube://',
        ),
      );

      bool launched = false;

      // Try YouTube app first
      if (await canLaunchUrl(youtubeAppUri)) {
        launched = await launchUrl(
          youtubeAppUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback to web browser
      if (!launched && await canLaunchUrl(videoUri)) {
        launched = await launchUrl(
          videoUri,
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open: ${item.title}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _refreshMedia(WidgetRef ref) async {
    ref.read(isRefreshingProvider.notifier).state = true;

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));

    // Invalidate the stream to force refresh
    ref.invalidate(mediaStreamProvider);

    ref.read(isRefreshingProvider.notifier).state = false;
  }
}
