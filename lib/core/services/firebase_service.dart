// lib/core/services/firebase_service.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart'; // ✅ ADDED

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get profilesCollection =>
      _firestore.collection('profiles');
  CollectionReference get assessmentsCollection =>
      _firestore.collection('assessments');
  CollectionReference get feedbackCollection =>
      _firestore.collection('feedback');
  CollectionReference get conversationsCollection =>
      _firestore.collection('conversations');

  // Storage references
  Reference get profileImagesRef => _storage.ref().child('profile_images');

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ✅ FIXED: Upload image with localized error handling
  Future<String> uploadImage(
    String path,
    String fileName,
    Uint8List bytes, [
    BuildContext? context,
  ]) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(l10n?.uploadImageFailed ?? 'Failed to upload image: $e');
    }
  }

  // ✅ FIXED: Get document with localized error handling
  Future<DocumentSnapshot> getDocumentById(
    String collection,
    String documentId, [
    BuildContext? context,
  ]) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(l10n?.getDocumentFailed ?? 'Failed to get document: $e');
    }
  }

  // ✅ FIXED: Add document with localized error handling
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data, [
    BuildContext? context,
  ]) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(l10n?.addDocumentFailed ?? 'Failed to add document: $e');
    }
  }

  // ✅ FIXED: Set document with localized error handling
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, [
    BuildContext? context,
  ]) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(l10n?.setDocumentFailed ?? 'Failed to set document: $e');
    }
  }

  // ✅ FIXED: Update document with localized error handling
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, [
    BuildContext? context,
  ]) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(
        l10n?.updateDocumentFailed ?? 'Failed to update document: $e',
      );
    }
  }

  // ✅ FIXED: Delete document with localized error handling
  Future<void> deleteDocument(
    String collection,
    String documentId, [
    BuildContext? context,
  ]) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(
        l10n?.deleteDocumentFailed ?? 'Failed to delete document: $e',
      );
    }
  }

  // ✅ FIXED: Query collection with localized error handling
  Future<QuerySnapshot> queryCollection(
    String collection, {
    List<List<dynamic>>? whereConditions,
    String? orderBy,
    bool? descending,
    int? limit,
    BuildContext? context,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      if (whereConditions != null) {
        for (final condition in whereConditions) {
          query = query.where(condition[0], isEqualTo: condition[1]);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending ?? false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } catch (e) {
      final l10n = context != null ? AppLocalizations.of(context) : null;
      throw Exception(
        l10n?.queryCollectionFailed ?? 'Failed to query collection: $e',
      );
    }
  }

  // // ✅ ADDED: Helper method to handle storage errors
  // String _handleStorageError(FirebaseException e, BuildContext? context) {
  //   final l10n = context != null ? AppLocalizations.of(context) : null;

  //   switch (e.code) {
  //     case 'storage/object-not-found':
  //       return l10n?.storageObjectNotFound ?? 'File not found';
  //     case 'storage/unauthorized':
  //       return l10n?.storageUnauthorized ??
  //           'Not authorized to access this file';
  //     case 'storage/canceled':
  //       return l10n?.storageCanceled ?? 'Upload was canceled';
  //     case 'storage/unknown':
  //       return l10n?.storageUnknownError ?? 'Unknown storage error occurred';
  //     case 'storage/invalid-format':
  //       return l10n?.storageInvalidFormat ?? 'Invalid file format';
  //     case 'storage/quota-exceeded':
  //       return l10n?.storageQuotaExceeded ?? 'Storage quota exceeded';
  //     default:
  //       return l10n?.storageGenericError ?? 'Storage error: ${e.message}';
  //   }
  // }

  // // ✅ ADDED: Helper method to handle Firestore errors
  // String _handleFirestoreError(FirebaseException e, BuildContext? context) {
  //   final l10n = context != null ? AppLocalizations.of(context) : null;

  //   switch (e.code) {
  //     case 'permission-denied':
  //       return l10n?.firestorePermissionDenied ?? 'Permission denied';
  //     case 'not-found':
  //       return l10n?.firestoreNotFound ?? 'Document not found';
  //     case 'already-exists':
  //       return l10n?.firestoreAlreadyExists ?? 'Document already exists';
  //     case 'resource-exhausted':
  //       return l10n?.firestoreResourceExhausted ?? 'Resource exhausted';
  //     case 'failed-precondition':
  //       return l10n?.firestoreFailedPrecondition ?? 'Failed precondition';
  //     case 'aborted':
  //       return l10n?.firestoreAborted ?? 'Operation was aborted';
  //     case 'out-of-range':
  //       return l10n?.firestoreOutOfRange ?? 'Operation out of range';
  //     case 'unimplemented':
  //       return l10n?.firestoreUnimplemented ?? 'Operation not implemented';
  //     case 'internal':
  //       return l10n?.firestoreInternal ?? 'Internal error';
  //     case 'unavailable':
  //       return l10n?.firestoreUnavailable ?? 'Service unavailable';
  //     case 'data-loss':
  //       return l10n?.firestoreDataLoss ?? 'Data loss detected';
  //     case 'unauthenticated':
  //       return l10n?.firestoreUnauthenticated ?? 'User not authenticated';
  //     default:
  //       return l10n?.firestoreGenericError ?? 'Database error: ${e.message}';
  //   }
  // }
}
