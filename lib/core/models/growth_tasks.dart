// lib/features/dashboard/models/growth_task.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khedoo/constants/app_colors.dart';

class GrowthTask {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int targetCount;
  final int currentCount;
  final String reason;
  final bool completed;
  final List<TaskResource> resources;
  final DateTime createdAt;
  final int order;

  GrowthTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.targetCount,
    required this.currentCount,
    required this.reason,
    required this.completed,
    required this.resources,
    required this.createdAt,
    required this.order,
  });

  factory GrowthTask.fromFirestore(String id, Map<String, dynamic> data) {
    return GrowthTask(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'general',
      difficulty: data['difficulty'] ?? 'medium',
      targetCount: data['targetCount'] ?? 1,
      currentCount: data['currentCount'] ?? 0,
      reason: data['reason'] ?? '',
      completed: data['completed'] ?? false,
      resources:
          (data['resources'] as List<dynamic>? ?? [])
              .map((item) => TaskResource.fromMap(item))
              .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: data['order'] ?? 0,
    );
  }

  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'communication':
        return AppColors.primaryDarkBlue;
      case 'emotional':
        return AppColors.primarySageGreen;
      case 'social':
        return AppColors.primaryGold;
      case 'self-awareness':
        return AppColors.primaryDarkBlue;
      default:
        return AppColors.textMedium;
    }
  }

  String get difficultyEmoji {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'hard':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

class TaskResource {
  final String title;
  final String type;
  final String description;

  TaskResource({
    required this.title,
    required this.type,
    required this.description,
  });

  factory TaskResource.fromMap(Map<String, dynamic> data) {
    return TaskResource(
      title: data['title'] ?? '',
      type: data['type'] ?? 'article',
      description: data['description'] ?? '',
    );
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline;
      case 'article':
        return Icons.article_outlined;
      case 'exercise':
        return Icons.fitness_center_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
