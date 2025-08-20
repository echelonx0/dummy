// lib/core/utils/navigation_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../core/models/growth_tasks.dart';
import 'ui_helpers.dart';

class NavigationUtils {
  NavigationUtils._();

  /// Shows a draggable modal bottom sheet with standard configuration
  static void showCustomModal({
    required BuildContext context,
    required String title,
    required Widget content,
    double initialChildSize = 0.95,
    double maxChildSize = 0.97,
    double minChildSize = 0.94,
    bool isFullWidth = true, // ✅ ADD THIS PARAMETER
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: initialChildSize,
            maxChildSize: maxChildSize,
            minChildSize: minChildSize,
            builder:
                (context, scrollController) => Container(
                  decoration: UIHelpers.getModalDecoration(),
                  width: double.infinity, // ✅ FORCE FULL WIDTH
                  margin:
                      isFullWidth
                          ? EdgeInsets
                              .zero // ✅ NO MARGIN FOR FULL WIDTH
                          : const EdgeInsets.symmetric(
                            horizontal: 16,
                          ), // Default margin
                  child: Column(
                    children: [
                      UIHelpers.buildModalHandle(),
                      UIHelpers.buildModalHeader(
                        title: title,
                        onClose: () => Navigator.pop(context),
                        titleStyle: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryDarkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        closeIconColor: AppColors.textMedium,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          // ✅ ADD SCROLL FOR CONTENT
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  /// Shows a task progress update dialog
  static void showTaskProgressDialog({
    required BuildContext context,
    required GrowthTask task,
    required Function(String taskId, int newCount) onUpdateTaskProgress,
  }) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    UIHelpers.getCategoryIcon(task.category),
                    color: AppColors.primaryDarkBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Update Progress',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current progress: ${task.currentCount}/${task.targetCount}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onUpdateTaskProgress(task.id, task.currentCount + 1);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryDarkBlue.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: AppColors.primaryDarkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('+1 Step'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onUpdateTaskProgress(task.id, task.targetCount);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDarkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Complete ✅'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  // Add this to NavigationUtils:
  static void showInsightsModal({
    required BuildContext context,
    required Widget content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.6,
            builder:
                (context, scrollController) => Container(
                  width: double.infinity, // Full width
                  decoration: UIHelpers.getModalDecoration(),
                  child: Column(
                    children: [
                      UIHelpers.buildModalHandle(),
                      // Custom header for insights
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primarySageGreen,
                                    AppColors.primaryAccent,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personality Analysis',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: AppColors.primaryDarkBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Your complete psychological profile',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: AppColors.textMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
