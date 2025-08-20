// lib/features/profile/widgets/photo_item.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/models/profile_photo.dart';

class PhotoItem extends StatelessWidget {
  final ProfilePhoto photo;
  final bool isPrimary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PhotoItem({
    super.key,
    required this.photo,
    required this.isPrimary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: photo.isUploading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isPrimary ? AppColors.primaryDarkBlue : Colors.grey.shade300,
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo Content
              _buildPhotoContent(),

              // Upload Progress Indicator
              if (photo.isUploading) _buildProgressIndicator(),

              // Delete Button (only if photo exists)
              if (photo.exists && !photo.isUploading) _buildDeleteButton(),

              // Primary Label
              if (isPrimary && photo.exists) _buildPrimaryLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (photo.isLocal && photo.file != null) {
      // Local file image
      return Image.file(photo.file!, fit: BoxFit.cover);
    } else if (photo.isRemote && photo.url != null) {
      // Remote URL image
      return CachedNetworkImage(
        imageUrl: photo.url!,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryDarkBlue,
              ),
            ),
        errorWidget: (context, url, error) => _buildEmptyPhoto(),
      );
    } else {
      // Empty photo placeholder
      return _buildEmptyPhoto();
    }
  }

  Widget _buildEmptyPhoto() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            isPrimary ? 'Add Primary Photo' : 'Add Photo',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularPercentIndicator(
          radius: 30.0,
          lineWidth: 5.0,
          percent: photo.uploadProgress ?? 0.0,
          center: Text(
            '${((photo.uploadProgress ?? 0.0) * 100).toInt()}%',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          progressColor: AppColors.primaryDarkBlue,
          backgroundColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.close, size: 18, color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildPrimaryLabel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
        color: AppColors.primaryDarkBlue.withOpacity(0.8),
        child: const Text(
          'Primary Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
