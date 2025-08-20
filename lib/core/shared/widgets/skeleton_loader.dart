// lib/shared/widgets/skeleton_loading.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonContainer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.backgroundLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
}

class InsightsSkeleton extends StatelessWidget {
  const InsightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Readiness card skeleton
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SkeletonContainer(height: 24, width: 200),
              const SizedBox(height: AppDimensions.paddingL),
              const SkeletonContainer(
                height: 120,
                width: 120,
                borderRadius: BorderRadius.all(Radius.circular(60)),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              const SkeletonContainer(height: 16, width: 150),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Growth areas skeleton
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SkeletonContainer(height: 20, width: 120),
              const SizedBox(height: AppDimensions.paddingL),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonContainer(height: 16, width: 180),
                      const SizedBox(height: AppDimensions.paddingS),
                      const SkeletonContainer(
                        height: 14,
                        width: double.infinity,
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      const SkeletonContainer(height: 14, width: 250),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GrowthTasksSkeleton extends StatelessWidget {
  const GrowthTasksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress overview skeleton
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SkeletonContainer(height: 20, width: 150),
              const SizedBox(height: AppDimensions.paddingL),
              const SkeletonContainer(height: 20, width: double.infinity),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingL),

        // Tasks skeleton
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: SkeletonContainer(
                          height: 16,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      const SkeletonContainer(height: 24, width: 50),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const SkeletonContainer(height: 14, width: double.infinity),
                  const SizedBox(height: AppDimensions.paddingM),
                  const SkeletonContainer(height: 8, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
