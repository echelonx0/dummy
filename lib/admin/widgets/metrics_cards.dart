// lib/features/admin/widgets/analytics_metrics_cards.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class AnalyticsMetricsCards extends StatelessWidget {
  final String timeRange;

  const AnalyticsMetricsCards({super.key, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AggregatedMetrics>(
      stream: MatchAnalyticsService().getAggregatedMetrics(timeRange),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCards();
        }

        if (snapshot.hasError) {
          return _ErrorCard(error: snapshot.error.toString());
        }

        final metrics = snapshot.data ?? AggregatedMetrics.empty();

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _MetricCard(
              title: 'Total Matches',
              value: metrics.totalMatches.toString(),
              subtitle: '+12% from last period',
              icon: Icons.favorite,
              color: AppColors.primarySageGreen,
              trend: TrendDirection.up,
            ),
            _MetricCard(
              title: 'Avg Compatibility',
              value: metrics.formattedScore,
              subtitle: '+3% quality improvement',
              icon: Icons.trending_up,
              color: AppColors.success,
              trend: TrendDirection.up,
            ),
            _MetricCard(
              title: 'Success Rate',
              value: metrics.formattedSuccessRate,
              subtitle: 'Successful API calls',
              icon: Icons.check_circle,
              color: AppColors.electricBlue,
              trend: TrendDirection.stable,
            ),
            _MetricCard(
              title: 'Total Cost',
              value: metrics.formattedCost,
              subtitle: 'AI processing costs',
              icon: Icons.account_balance_wallet,
              color: AppColors.warning,
              trend: TrendDirection.up,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrendDirection trend;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),

          // Trend indicator
          Row(
            children: [
              Icon(
                _getTrendIcon(trend),
                size: 16,
                color: _getTrendColor(trend),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTrendColor(trend),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Icons.arrow_upward;
      case TrendDirection.down:
        return Icons.arrow_downward;
      case TrendDirection.stable:
        return Icons.remove;
    }
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return AppColors.success;
      case TrendDirection.down:
        return AppColors.error;
      case TrendDirection.stable:
        return AppColors.textMedium;
    }
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(
        4,
        (index) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderPrimary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Spacer(),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'Error loading metrics',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              color: AppColors.textMedium.withValues(alpha: 0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

enum TrendDirection { up, down, stable }

// Mock service class and models for demonstration - replace with actual implementation
class MatchAnalyticsService {
  Stream<AggregatedMetrics> getAggregatedMetrics(String timeRange) {
    // Mock implementation - replace with actual Firestore stream
    return Stream.value(AggregatedMetrics.empty());
  }
}

class AggregatedMetrics {
  final int totalMatches;
  final double averageScore;
  final double successRate;
  final double totalCost;

  AggregatedMetrics({
    required this.totalMatches,
    required this.averageScore,
    required this.successRate,
    required this.totalCost,
  });

  static AggregatedMetrics empty() {
    return AggregatedMetrics(
      totalMatches: 0,
      averageScore: 0.0,
      successRate: 0.0,
      totalCost: 0.0,
    );
  }

  String get formattedScore => '${(averageScore * 100).toInt()}%';
  String get formattedSuccessRate => '${(successRate * 100).toInt()}%';
  String get formattedCost => '\$${totalCost.toStringAsFixed(2)}';
}
