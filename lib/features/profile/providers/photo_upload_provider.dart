// lib/features/profile/providers/photo_upload_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/profile_photo.dart';
import '../services/photo_profile_service.dart';
import 'package:uuid/uuid.dart';

class PhotoUploadProvider extends ChangeNotifier {
  final PhotoUploadService _service = PhotoUploadService();
  final Uuid _uuid = const Uuid();
  final String userId;

  // Maximum number of photos allowed
  final int maxPhotos = 6;

  // List of user's photos
  List<ProfilePhoto> _photos = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false; // Flag to track disposal

  PhotoUploadProvider({required this.userId}) {
    _initializePhotos();
  }

  void _initializePhotos() {
    // Initialize with empty primary photo
    _photos.add(const ProfilePhoto(type: PhotoType.primary));

    // Initialize with 5 empty additional photos
    for (int i = 0; i < 5; i++) {
      _photos.add(const ProfilePhoto(type: PhotoType.additional));
    }
  }

  // Getters
  List<ProfilePhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProfilePhoto get primaryPhoto => _photos.firstWhere(
    (photo) => photo.type == PhotoType.primary,
    orElse: () => const ProfilePhoto(type: PhotoType.primary),
  );
  List<ProfilePhoto> get additionalPhotos =>
      _photos.where((photo) => photo.type == PhotoType.additional).toList();
  int get totalPhotosCount => _photos.where((photo) => photo.exists).length;
  bool get hasPrimaryPhoto => primaryPhoto.exists;
  bool get canAddMorePhotos => totalPhotosCount < maxPhotos;

  // Add photo from gallery
  Future<void> addPhotoFromGallery(int index) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final File? pickedFile = await _service.pickImageFromGallery();
      if (_disposed) return;

      if (pickedFile != null) {
        await _addPhoto(pickedFile, index);
      }
    } catch (e) {
      if (_disposed) return;
      _error = 'Failed to pick image: $e';
    } finally {
      if (_disposed) return;
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Add photo from camera
  Future<void> addPhotoFromCamera(int index) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();

      final File? pickedFile = await _service.takePhotoWithCamera();
      if (_disposed) return;

      if (pickedFile != null) {
        await _addPhoto(pickedFile, index);
      }
    } catch (e) {
      if (_disposed) return;
      _error = 'Failed to take photo: $e';
    } finally {
      if (_disposed) return;
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Helper method to add a photo
  Future<void> _addPhoto(File file, int index) async {
    if (_disposed) return;

    // Generate a temporary ID
    final String tempId = _uuid.v4();

    // Determine photo type
    final PhotoType type =
        index == 0 ? PhotoType.primary : PhotoType.additional;

    // Update photo in the list
    final updatedPhoto = ProfilePhoto(
      id: tempId,
      file: file,
      type: type,
      isUploading: false,
    );

    // Update the photos list
    final List<ProfilePhoto> updatedPhotos = List.from(_photos);
    updatedPhotos[index] = updatedPhoto;
    _photos = updatedPhotos;
    _safeNotifyListeners();
  }

  // Remove a photo
  Future<void> removePhoto(int index) async {
    if (_disposed) return;
    if (index < 0 || index >= _photos.length) return;

    final photo = _photos[index];

    // If photo exists remotely, delete from storage
    if (photo.isRemote && photo.url != null) {
      await _service.deletePhoto(photo.url!);
      if (_disposed) return;
    }

    // Create empty photo with the same type
    final emptyPhoto = ProfilePhoto(type: photo.type);

    // Update the photos list
    final List<ProfilePhoto> updatedPhotos = List.from(_photos);
    updatedPhotos[index] = emptyPhoto;
    _photos = updatedPhotos;
    _safeNotifyListeners();
  }

  // Upload all pending photos
  Future<List<String>> uploadPendingPhotos() async {
    if (_disposed) return [];
    final List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < _photos.length; i++) {
        if (_disposed) return uploadedUrls;
        final photo = _photos[i];

        // Skip photos that don't have a local file
        if (photo.file == null) continue;

        // Mark photo as uploading
        final updatedPhoto = photo.copyWith(isUploading: true);
        _photos[i] = updatedPhoto;
        _safeNotifyListeners();

        // Try the regular upload method first
        String? downloadUrl;
        try {
          downloadUrl = await _service.uploadPhoto(photo.file!, userId);
        } catch (e) {
          print('Primary upload method failed: $e');
        }

        // If the regular method fails, try the fallback method
        if (downloadUrl == null) {
          try {
            print('Trying fallback upload method...');
            downloadUrl = await _service.uploadPhotoFallback(
              photo.file!,
              userId,
            );
          } catch (e) {
            print('Fallback upload method also failed: $e');
          }
        }

        if (_disposed) return uploadedUrls;

        if (downloadUrl != null) {
          // Update photo with remote URL
          final completedPhoto = photo.copyWith(
            url: downloadUrl,
            isUploading: false,
            uploadProgress: 1.0,
          );

          _photos[i] = completedPhoto;
          uploadedUrls.add(downloadUrl);
        } else {
          // Handle upload failure
          final failedPhoto = photo.copyWith(isUploading: false);
          _photos[i] = failedPhoto;
          _error = 'Failed to upload one or more photos';
        }
        _safeNotifyListeners();
      }
    } catch (e) {
      if (_disposed) return uploadedUrls;
      _error = 'Error during photo upload: $e';
      _safeNotifyListeners();
    }

    return uploadedUrls;
  }

  // Load existing photos from URLs
  void loadExistingPhotos(List<String> photoUrls) {
    if (_disposed || photoUrls.isEmpty) return;

    // Reset the photos list
    _photos = [];

    // Add the primary photo
    if (photoUrls.isNotEmpty) {
      _photos.add(
        ProfilePhoto(
          id: _uuid.v4(),
          url: photoUrls[0],
          type: PhotoType.primary,
        ),
      );

      // Remove the primary photo from the list
      photoUrls = photoUrls.sublist(1);
    } else {
      _photos.add(const ProfilePhoto(type: PhotoType.primary));
    }

    // Add additional photos
    for (int i = 0; i < 5; i++) {
      if (i < photoUrls.length) {
        _photos.add(
          ProfilePhoto(
            id: _uuid.v4(),
            url: photoUrls[i],
            type: PhotoType.additional,
          ),
        );
      } else {
        _photos.add(const ProfilePhoto(type: PhotoType.additional));
      }
    }

    _safeNotifyListeners();
  }

  // Reset to initial state
  void reset() {
    if (_disposed) return;
    _photos = [];
    _initializePhotos();
    _error = null;
    _isLoading = false;
    _safeNotifyListeners();
  }

  // Clear error
  void clearError() {
    if (_disposed) return;
    _error = null;
    _safeNotifyListeners();
  }

  // Safe version of notifyListeners that checks if disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
