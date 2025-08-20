// lib/features/profile/models/profile_photo.dart
import 'dart:io';

enum PhotoType { primary, additional }

class ProfilePhoto {
  final String? id;
  final String? url;
  final File? file;
  final PhotoType type;
  final bool isUploading;
  final double? uploadProgress;

  const ProfilePhoto({
    this.id,
    this.url,
    this.file,
    required this.type,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  bool get isLocal => file != null;
  bool get isRemote => url != null && url!.isNotEmpty;
  bool get exists => isLocal || isRemote;

  ProfilePhoto copyWith({
    String? id,
    String? url,
    File? file,
    PhotoType? type,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return ProfilePhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      file: file ?? this.file,
      type: type ?? this.type,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
