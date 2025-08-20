// lib/features/dashboard/services/dashboard_service.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';
import '../models/growth_tasks.dart';
import '../models/user_insights.dart';

class DashboardService {
  final _firebaseService = locator<FirebaseService>();
  final _authService = locator<AuthService>();

  Future<UserInsights> getUserInsights() async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final insightsDoc =
          await _firebaseService.firestore
              .collection('profiles')
              .doc(userId)
              .collection('insights')
              .doc('relationshipReadiness')
              .get();

      if (!insightsDoc.exists) {
        return UserInsights.empty();
      }

      return UserInsights.fromFirestore(insightsDoc.data()!);
    } catch (error) {
      await _logError('getUserInsights', error.toString());
      rethrow;
    }
  }

  Future<List<GrowthTask>> getGrowthTasks() async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final tasksSnapshot =
          await _firebaseService.firestore
              .collection('profiles')
              .doc(userId)
              .collection('growthTasks')
              .orderBy('order')
              .get();

      return tasksSnapshot.docs
          .map((doc) => GrowthTask.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (error) {
      await _logError('getGrowthTasks', error.toString());
      rethrow;
    }
  }

  Future<void> updateTaskProgress(String taskId, int newCount) async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final taskRef = _firebaseService.firestore
          .collection('profiles')
          .doc(userId)
          .collection('growthTasks')
          .doc(taskId);

      // Get current task to check target
      final taskDoc = await taskRef.get();
      if (!taskDoc.exists) throw Exception('Task not found');

      final taskData = taskDoc.data()!;
      final targetCount = taskData['targetCount'] as int;
      final completed = newCount >= targetCount;

      await taskRef.update({
        'currentCount': newCount,
        'completed': completed,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      await _logError('updateTaskProgress', error.toString(), {
        'taskId': taskId,
        'newCount': newCount,
      });
      rethrow;
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firebaseService.firestore
          .collection('profiles')
          .doc(userId)
          .collection('growthTasks')
          .doc(taskId)
          .update({
            'completed': true,
            'completedAt': FieldValue.serverTimestamp(),
          });
    } catch (error) {
      await _logError('completeTask', error.toString(), {'taskId': taskId});
      rethrow;
    }
  }

  Future<void> _logError(
    String operation,
    String error, [
    Map<String, dynamic>? context,
  ]) async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      await _firebaseService.firestore.collection('errorLogs').add({
        'operation': operation,
        'error': error,
        'context': context ?? {},
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'source': 'DashboardService',
      });
    } catch (e) {
      // Silent fail for error logging
      log('Failed to log error: $e');
    }
  }
}
