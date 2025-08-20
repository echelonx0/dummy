// lib/features/profile/services/photo_upload_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class PhotoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Pick image from gallery with reduced quality
  Future<File?> pickImageFromGallery() async {
    try {
      // Set imageQuality lower to reduce file size
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60, // Reduced quality to make uploads smaller
      );

      if (image != null) {
        return await _cropImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  // Take photo with camera with reduced quality
  Future<File?> takePhotoWithCamera() async {
    try {
      // Set imageQuality lower to reduce file size
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60, // Reduced quality to make uploads smaller
      );

      if (image != null) {
        return await _cropImage(File(image.path));
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
    return null;
  }

  // Crop image
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Photo',
            toolbarColor: AppColors.primaryDarkBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Your Photo',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      print('Error cropping image: $e');
      // Return original file if cropping fails
      return imageFile;
    }
    return null;
  }

  // Upload photo to Firebase Storage with byte-based upload
  Future<String?> uploadPhoto(File file, String userId) async {
    try {
      // Check if file exists and is readable
      if (!await file.exists()) {
        print('File does not exist: ${file.path}');
        return null;
      }

      // Generate a path with timestamp to avoid collisions
      final String photoId = _uuid.v4();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = 'users/$userId/photos/${photoId}_$timestamp.jpg';
      final Reference ref = _storage.ref().child(path);

      // Read file as bytes
      final Uint8List bytes = await file.readAsBytes();

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'photoId': photoId},
      );

      // Try uploading bytes directly
      try {
        print('Attempting to upload photo (${bytes.length} bytes)');
        final UploadTask uploadTask = ref.putData(bytes, metadata);

        // Wait for upload to complete
        final TaskSnapshot snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          // Get download URL
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          print('Upload successful: $downloadUrl');
          return downloadUrl;
        } else {
          print('Upload completed with state: ${snapshot.state}');
        }
      } catch (e) {
        print('Error during primary upload: $e');
        // Try fallback method if primary fails
        return await _uploadPhotoFallback(file, userId);
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
    return null;
  }

  // Fallback upload method with chunked approach
  Future<String?> _uploadPhotoFallback(File file, String userId) async {
    try {
      print('Using fallback upload method');

      // Generate a unique path
      final String photoId = _uuid.v4();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = 'users/$userId/photos/${photoId}_$timestamp.jpg';
      final Reference ref = _storage.ref().child(path);

      // Try chunk-based upload with smaller file
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        print('Fallback upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('Error in fallback upload: $e');
    }
    return null;
  }

  // Public version of the fallback method
  Future<String?> uploadPhotoFallback(File file, String userId) async {
    return await _uploadPhotoFallback(file, userId);
  }

  // Delete photo from Firebase Storage
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }
}
