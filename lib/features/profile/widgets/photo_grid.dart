// lib/features/profile/widgets/photo_grid.dart
import 'package:flutter/material.dart';
import '../../../core/models/profile_photo.dart';

import 'photo_item.dart';
import '../../../constants/app_dimensions.dart';

class PhotoGrid extends StatelessWidget {
  final List<ProfilePhoto> photos;
  final Function(int) onPhotoTap;
  final Function(int) onPhotoDelete;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    required this.onPhotoDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Photo (larger)
        if (photos.isNotEmpty) _buildPrimaryPhoto(),

        const SizedBox(height: AppDimensions.paddingL),

        // Additional Photos (grid)
        _buildAdditionalPhotos(),
      ],
    );
  }

  Widget _buildPrimaryPhoto() {
    final primaryPhoto = photos.first; // First photo is primary

    return SizedBox(
      height: 250,
      child: PhotoItem(
        photo: primaryPhoto,
        isPrimary: true,
        onTap: () => onPhotoTap(0),
        onDelete: () => onPhotoDelete(0),
      ),
    );
  }

  Widget _buildAdditionalPhotos() {
    // Skip the primary photo
    final additionalPhotos = photos.sublist(1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppDimensions.paddingM,
        mainAxisSpacing: AppDimensions.paddingM,
        childAspectRatio: 1,
      ),
      itemCount: additionalPhotos.length,
      itemBuilder: (context, index) {
        final photo = additionalPhotos[index];
        final actualIndex = index + 1; // Adjust index for full photos list

        return PhotoItem(
          photo: photo,
          isPrimary: false,
          onTap: () => onPhotoTap(actualIndex),
          onDelete: () => onPhotoDelete(actualIndex),
        );
      },
    );
  }
}
