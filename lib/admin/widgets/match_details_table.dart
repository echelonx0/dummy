// lib/features/admin/widgets/match_details_table.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../models/match_analytics_models.dart';
import '../services/analytics_service.dart';
import 'match_table/match_details_dialog.dart';
import 'match_table/match_row_widget.dart';
import 'match_table/match_table_column_header.dart';
import 'match_table/match_table_column_headers.dart';
import 'match_table/table_state_widgets.dart';

class MatchDetailsTable extends StatefulWidget {
  final AnalyticsFilters filters;
  final VoidCallback? onExport;

  const MatchDetailsTable({super.key, required this.filters, this.onExport});

  @override
  State<MatchDetailsTable> createState() => _MatchDetailsTableState();
}

class _MatchDetailsTableState extends State<MatchDetailsTable> {
  final MatchAnalyticsService _analyticsService = MatchAnalyticsService();
  String _sortBy = 'timestamp';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderPrimary.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header with controls
          MatchTableHeader(
            sortBy: _sortBy,
            onSortChanged: (newSort) {
              setState(() {
                _sortBy = newSort;
              });
            },
            onExport: _handleExport,
          ),

          // Column Headers
          const MatchTableColumnHeaders(),

          // Table Content
          _buildTableContent(),
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    return StreamBuilder<List<MatchAnalytic>>(
      stream: _analyticsService.getMatchAnalytics(
        filters: widget.filters,
        limit: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TableSkeletonLoader(rowCount: 8);
        }

        if (snapshot.hasError) {
          return TableErrorState(
            error: snapshot.error.toString(),
            onRetry: () {
              setState(() {}); // Trigger rebuild to retry
            },
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyTableState(
            title: 'No matches found',
            subtitle:
                'Try adjusting your filters or wait for new matches to be generated',
            icon: Icons.analytics_outlined,
            onAction: () {
              setState(() {}); // Refresh
            },
            actionLabel: 'Refresh Data',
          );
        }

        List<MatchAnalytic> matches = snapshot.data!;
        matches = _sortMatches(matches);

        return Column(
          children: [
            // Table Rows
            ...matches.map(
              (match) => MatchRowWidget(
                match: match,
                onTap: () => _showMatchDetails(match),
              ),
            ),

            // Table Footer with summary
            _buildTableFooter(matches.length),
          ],
        );
      },
    );
  }

  Widget _buildTableFooter(int totalMatches) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.2),
        border: Border(
          top: BorderSide(
            color: AppColors.borderPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $totalMatches matches',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (_isExporting)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primarySageGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exporting...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildQuickStatsChips(totalMatches),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsChips(int totalMatches) {
    return Wrap(
      spacing: 8,
      children: [
        _StatChip(
          label: 'Total',
          value: totalMatches.toString(),
          color: AppColors.primarySageGreen,
        ),
        _StatChip(
          label: 'High Score',
          value: '${_getHighScoreCount()}',
          color: AppColors.success,
        ),
        _StatChip(
          label: 'Avg Score',
          value: '${_getAverageScore()}%',
          color: AppColors.info,
        ),
      ],
    );
  }

  List<MatchAnalytic> _sortMatches(List<MatchAnalytic> matches) {
    switch (_sortBy) {
      case 'score_desc':
        return matches..sort(
          (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
        );
      case 'score_asc':
        return matches..sort(
          (a, b) => a.compatibilityScore.compareTo(b.compatibilityScore),
        );
      case 'processing_time':
        return matches
          ..sort((a, b) => b.processingTimeMs.compareTo(a.processingTimeMs));
      case 'timestamp':
      default:
        return matches..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  void _handleExport() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final csvData = await _analyticsService.exportMatchAnalytics(
        filters: widget.filters,
        limit: 1000,
      );

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: csvData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Match data copied to clipboard'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      widget.onExport?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.primaryAccent, size: 20),
                const SizedBox(width: 8),
                Text('Export failed: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showMatchDetails(MatchAnalytic match) {
    showDialog(
      context: context,
      barrierColor: AppColors.primaryDarkBlue.withValues(alpha: 0.7),
      builder: (context) => MatchDetailsDialog(match: match),
    );
  }

  int _getHighScoreCount() {
    // This would need to be calculated from the current stream data
    // For now, returning a placeholder
    return 0;
  }

  int _getAverageScore() {
    // This would need to be calculated from the current stream data
    // For now, returning a placeholder
    return 0;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textMedium),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
