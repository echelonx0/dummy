// lib/features/profile/widgets/photo_preview_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../core/models/profile_photo.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final ProfilePhoto photo;
  final VoidCallback onDelete;
  final VoidCallback onReplace;

  const PhotoPreviewScreen({
    super.key,
    required this.photo,
    required this.onDelete,
    required this.onReplace,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfilePhoto photo,
    required VoidCallback onDelete,
    required VoidCallback onReplace,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PhotoPreviewScreen(
              photo: photo,
              onDelete: onDelete,
              onReplace: onReplace,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (photo.exists)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                // Show confirmation dialog
                _showDeleteConfirmation(context);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Photo
          Center(
            child: Hero(
              tag:
                  'photo_${photo.id ?? (photo.url ?? DateTime.now().toString())}',
              child: _buildPhotoContent(),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child:
                  photo.exists
                      ? _buildExistingPhotoControls(context)
                      : _buildEmptyPhotoControls(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (photo.isLocal && photo.file != null) {
      // Local file image
      return InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(80),
        minScale: 0.5,
        maxScale: 4,
        child: Image.file(photo.file!, fit: BoxFit.contain),
      );
    } else if (photo.isRemote && photo.url != null) {
      // Remote URL image
      return InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(80),
        minScale: 0.5,
        maxScale: 4,
        child: CachedNetworkImage(
          imageUrl: photo.url!,
          fit: BoxFit.contain,
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          errorWidget:
              (context, url, error) => const Center(
                child: Icon(Icons.error_outline, color: Colors.white, size: 48),
              ),
        ),
      );
    } else {
      // Empty photo placeholder
      return Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(Icons.photo_outlined, color: Colors.white, size: 80),
        ),
      );
    }
  }

  Widget _buildExistingPhotoControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onReplace();
            },
            icon: const Icon(Icons.photo_camera),
            label: const Text('Replace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDarkBlue,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingL,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotoControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onReplace();
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingL,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Photo?'),
            content: const Text('Are you sure you want to remove this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close preview
                  onDelete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
