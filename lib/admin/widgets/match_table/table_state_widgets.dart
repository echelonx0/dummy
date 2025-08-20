// lib/features/admin/widgets/table_state_widgets.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class TableLoadingState extends StatelessWidget {
  const TableLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primarySageGreen,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading match data...',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching real-time analytics',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  
  const TableErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Error Loading Matches',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySageGreen,
                  foregroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyTableState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const EmptyTableState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon ?? Icons.search_off,
                color: AppColors.textMedium.withValues(alpha: 0.7),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title ?? 'No matches found',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'Try adjusting your filters or wait for new matches to be generated',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primarySageGreen,
                  side: BorderSide(color: AppColors.primarySageGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TableSkeletonLoader extends StatelessWidget {
  final int rowCount;
  
  const TableSkeletonLoader({
    super.key,
    this.rowCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rowCount,
        (index) => _SkeletonRow(),
      ),
    );
  }
}

class _SkeletonRow extends StatefulWidget {
  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Match Details Column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: 180,
                      height: 14,
                      opacity: _animation.value,
                    ),
                    const SizedBox(height: 6),
                    _SkeletonBox(
                      width: 120,
                      height: 12,
                      opacity: _animation.value * 0.7,
                    ),
                  ],
                ),
              ),
              
              // Score Column
              Expanded(
                flex: 2,
                child: _SkeletonBox(
                  width: 60,
                  height: 24,
                  opacity: _animation.value,
                ),
              ),
              
              // Factors Column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: 140,
                      height: 12,
                      opacity: _animation.value,
                    ),
                    const SizedBox(height: 4),
                    _SkeletonBox(
                      width: 120,
                      height: 12,
                      opacity: _animation.value * 0.8,
                    ),
                  ],
                ),
              ),
              
              // Processing Time Column
              Expanded(
                flex: 2,
                child: _SkeletonBox(
                  width: 50,
                  height: 14,
                  opacity: _animation.value,
                ),
              ),
              
              // Run ID Column
              Expanded(
                flex: 2,
                child: _SkeletonBox(
                  width: 80,
                  height: 12,
                  opacity: _animation.value,
                ),
              ),
              
              // Actions Column
              SizedBox(
                width: 80,
                child: Row(
                  children: [
                    _SkeletonBox(
                      width: 24,
                      height: 24,
                      opacity: _animation.value,
                    ),
                    const SizedBox(width: 8),
                    _SkeletonBox(
                      width: 24,
                      height: 24,
                      opacity: _animation.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: opacity * 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}