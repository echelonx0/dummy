// lib/features/admin/widgets/analytics_charts.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/app_colors.dart';

class AnalyticsCharts extends StatelessWidget {
  final String timeRange;

  const AnalyticsCharts({super.key, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ScoreTrendChart(timeRange: timeRange)),
            const SizedBox(width: 16),
            Expanded(child: _ScoreDistributionChart(timeRange: timeRange)),
          ],
        ),
        const SizedBox(height: 16),
        _CompatibilityFactorsChart(timeRange: timeRange),
      ],
    );
  }
}

class _ScoreTrendChart extends StatelessWidget {
  final String timeRange;

  const _ScoreTrendChart({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          Text(
            'Compatibility Score Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<MatchEngineRun>>(
              stream: MatchAnalyticsService().getMatchEngineRuns(
                timeRange: timeRange,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ChartLoadingState();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const _ChartErrorState();
                }

                final runs = snapshot.data!.reversed.toList();

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: AppColors.borderPrimary.withValues(
                              alpha: 0.1,
                            ),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget:
                              (value, meta) => Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 12,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < runs.length) {
                              final date = runs[index].timestamp;
                              return Text(
                                '${date.month}/${date.day}',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (runs.length - 1).toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            runs
                                .asMap()
                                .entries
                                .map(
                                  (entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry
                                        .value
                                        .qualityMetrics
                                        .averageCompatibilityScore,
                                  ),
                                )
                                .toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primarySageGreen,
                            AppColors.primarySageGreen.withValues(alpha: 0.7),
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: AppColors.primarySageGreen,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.surface,
                                  ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primarySageGreen.withValues(alpha: 0.1),
                              AppColors.primarySageGreen.withValues(
                                alpha: 0.05,
                              ),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDistributionChart extends StatelessWidget {
  final String timeRange;

  const _ScoreDistributionChart({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          Text(
            'Score Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<Map<String, int>>(
              stream: MatchAnalyticsService().getScoreDistribution(timeRange),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ChartLoadingState();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const _ChartErrorState();
                }

                final distribution = snapshot.data!;
                final total = distribution.values.fold<int>(
                  0,
                  (sum, count) => sum + count,
                );

                if (total == 0) {
                  return const _ChartErrorState();
                }

                final colors = [
                  AppColors.error,
                  AppColors.warning,
                  AppColors.success,
                  AppColors.primarySageGreen,
                ];

                return PieChart(
                  PieChartData(
                    sections:
                        distribution.entries.map((entry) {
                          final index = _getScoreRangeIndex(entry.key);
                          final percentage = (entry.value / total * 100);

                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: entry.value.toDouble(),
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.surface,
                            ),
                          );
                        }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                );
              },
            ),
          ),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendItem(color: AppColors.error, label: '0-25'),
              _LegendItem(color: AppColors.warning, label: '26-50'),
              _LegendItem(color: AppColors.success, label: '51-75'),
              _LegendItem(color: AppColors.primarySageGreen, label: '76-100'),
            ],
          ),
        ],
      ),
    );
  }

  int _getScoreRangeIndex(String range) {
    switch (range) {
      case '0-25':
        return 0;
      case '26-50':
        return 1;
      case '51-75':
        return 2;
      case '76-100':
        return 3;
      default:
        return 0;
    }
  }
}

class _CompatibilityFactorsChart extends StatelessWidget {
  final String timeRange;

  const _CompatibilityFactorsChart({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          Text(
            'Top Compatibility Factors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<CompatibilityFactor>>(
              stream: MatchAnalyticsService().getTopCompatibilityFactors(
                timeRange,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ChartLoadingState();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const _ChartErrorState();
                }

                final factors = snapshot.data!.take(5).toList();

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: AppColors.borderPrimary.withValues(
                              alpha: 0.1,
                            ),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget:
                              (value, meta) => Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 12,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < factors.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  factors[index].factor,
                                  style: TextStyle(
                                    color: AppColors.textMedium,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups:
                        factors.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.avgScore,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primarySageGreen,
                                    AppColors.primarySageGreen.withValues(
                                      alpha: 0.7,
                                    ),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 30,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }
}

class _ChartLoadingState extends StatelessWidget {
  const _ChartLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primarySageGreen,
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Loading chart data...',
            style: TextStyle(color: AppColors.textMedium, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ChartErrorState extends StatelessWidget {
  const _ChartErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            color: AppColors.textMedium.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No data available',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Data will appear after matches are generated',
            style: TextStyle(
              color: AppColors.textMedium.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Mock service class for demonstration - replace with actual implementation
class MatchAnalyticsService {
  Stream<List<MatchEngineRun>> getMatchEngineRuns({required String timeRange}) {
    // Mock implementation - replace with actual Firestore stream
    return Stream.value([]);
  }

  Stream<Map<String, int>> getScoreDistribution(String timeRange) {
    // Mock implementation - replace with actual Firestore stream
    return Stream.value({});
  }

  Stream<List<CompatibilityFactor>> getTopCompatibilityFactors(
    String timeRange,
  ) {
    // Mock implementation - replace with actual Firestore stream
    return Stream.value([]);
  }
}

// Mock model classes - add these to your match_analytics_models.dart file
class MatchEngineRun {
  final DateTime timestamp;
  final QualityMetrics qualityMetrics;

  MatchEngineRun({required this.timestamp, required this.qualityMetrics});
}

class QualityMetrics {
  final double averageCompatibilityScore;

  QualityMetrics({required this.averageCompatibilityScore});
}

class CompatibilityFactor {
  final String factor;
  final double avgScore;

  CompatibilityFactor({required this.factor, required this.avgScore});
}
