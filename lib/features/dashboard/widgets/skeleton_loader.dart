// lib/shared/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:khedoo/constants/app_colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircular = false,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
            borderRadius:
                widget.isCircular
                    ? BorderRadius.circular(widget.width / 2)
                    : (widget.borderRadius ?? BorderRadius.circular(8)),
            border: Border.all(
              color: AppColors.primarySageGreen.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                widget.isCircular
                    ? BorderRadius.circular(widget.width / 2)
                    : (widget.borderRadius ?? BorderRadius.circular(8)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Only build shimmer effect after layout is complete
                if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: constraints.maxWidth * _animation.value,
                      top: 0,
                      child: Container(
                        width: constraints.maxWidth * 0.5,
                        height: constraints.maxHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primaryAccent.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MediaCardSkeleton extends StatelessWidget {
  const MediaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
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
          // Thumbnail skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 140,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),

          // Content skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and time skeleton
                  Row(
                    children: [
                      const Expanded(
                        child: SkeletonLoader(width: 80, height: 12),
                      ),
                      const SizedBox(width: 8),
                      const SkeletonLoader(width: 40, height: 12),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title skeleton
                  const SkeletonLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 4),
                  const SkeletonLoader(width: 180, height: 16),

                  const SizedBox(height: 8),

                  // Description skeleton
                  const SkeletonLoader(width: double.infinity, height: 12),
                  const SizedBox(height: 4),
                  const SkeletonLoader(width: 120, height: 12),

                  const Spacer(),

                  // Bottom row skeleton
                  Row(
                    children: [
                      const SkeletonLoader(width: 30, height: 10),
                      const SizedBox(width: 12),
                      const SkeletonLoader(width: 30, height: 10),
                      const Spacer(),
                      SkeletonLoader(
                        width: 60,
                        height: 24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingCarousel extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double spacing;

  const LoadingCarousel({
    super.key,
    this.itemCount = 3,
    this.itemWidth = 260,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < itemCount - 1 ? spacing : 0,
            ),
            child: const MediaCardSkeleton(),
          );
        },
      ),
    );
  }
}
