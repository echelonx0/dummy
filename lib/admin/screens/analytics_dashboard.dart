// lib/features/admin/screens/match_analytics_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../models/match_analytics_models.dart';
import '../widgets/analytics_charts.dart';
import '../widgets/analytics_filters_widget.dart';
import '../widgets/match_details_table.dart';
import '../widgets/metrics_cards.dart';

class MatchAnalyticsDashboardScreen extends StatefulWidget {
  const MatchAnalyticsDashboardScreen({super.key});

  @override
  State<MatchAnalyticsDashboardScreen> createState() =>
      _MatchAnalyticsDashboardScreenState();
}

class _MatchAnalyticsDashboardScreenState
    extends State<MatchAnalyticsDashboardScreen> {
  AnalyticsFilters _filters = AnalyticsFilters();
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.1),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primarySageGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Filters
                AnalyticsFiltersWidget(
                  initialFilters: _filters,
                  onFiltersChanged: (newFilters) {
                    setState(() {
                      _filters = newFilters;
                    });
                  },
                ),

                // Key Metrics Cards
                AnalyticsMetricsCards(timeRange: _filters.timeRange),
                const SizedBox(height: 24),

                // Charts Section
                AnalyticsCharts(timeRange: _filters.timeRange),
                const SizedBox(height: 24),

                // Match Details Table
                MatchDetailsTable(filters: _filters, onExport: _handleExport),
                const SizedBox(height: 24),

                // System Status
                _buildSystemStatus(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Analytics Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time insights into AI matching performance',
                  style: TextStyle(fontSize: 16, color: AppColors.textMedium),
                ),
              ],
            ),
            Row(
              children: [
                // Quick Actions
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Refresh',
                  onPressed: _handleRefresh,
                  isLoading: _isRefreshing,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onPressed: _showSettings,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Status Indicator
        _buildLiveStatusIndicator(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Material(
      color: AppColors.primarySageGreen,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryAccent,
                  ),
                )
              else
                Icon(icon, size: 18, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Live Updates Active',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.health_and_safety, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'System Health',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 12,
            children: [
              _SystemStatusCard(
                label: 'Last Run',
                value: '2 hours ago',
                status: SystemStatus.normal,
              ),
              _SystemStatusCard(
                label: 'Next Run',
                value: 'In 10h 23m',
                status: SystemStatus.normal,
              ),
              _SystemStatusCard(
                label: 'API Status',
                value: 'Healthy',
                status: SystemStatus.good,
              ),
              _SystemStatusCard(
                label: 'Match Quality',
                value: '68% avg',
                status: SystemStatus.good,
              ),
              _SystemStatusCard(
                label: 'Error Rate',
                value: '0.2%',
                status: SystemStatus.good,
              ),
              _SystemStatusCard(
                label: 'Daily Cost',
                value: '\$0.45',
                status: SystemStatus.normal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard refreshed successfully'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Match data exported successfully'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: AppColors.textDark,
          onPressed: () {
            // Handle view exported data
          },
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(context: context, builder: (context) => _SettingsDialog());
  }
}

class _SystemStatusCard extends StatelessWidget {
  final String label;
  final String value;
  final SystemStatus status;

  const _SystemStatusCard({
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
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

  Color _getStatusColor(SystemStatus status) {
    switch (status) {
      case SystemStatus.good:
        return AppColors.success;
      case SystemStatus.normal:
        return AppColors.primarySageGreen;
      case SystemStatus.warning:
        return AppColors.warning;
      case SystemStatus.error:
        return AppColors.error;
    }
  }
}

class _SettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.cardBackground,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppColors.textMedium),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SettingTile(
              icon: Icons.notifications,
              title: 'Real-time Notifications',
              subtitle: 'Get notified when new matches are generated',
              value: true,
              onChanged: (value) {},
            ),

            _SettingTile(
              icon: Icons.auto_graph,
              title: 'Auto-refresh Charts',
              subtitle: 'Automatically update charts every 30 seconds',
              value: true,
              onChanged: (value) {},
            ),

            _SettingTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Use dark theme for better visibility',
              value: false,
              onChanged: (value) {},
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textMedium),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySageGreen,
                      foregroundColor: AppColors.primaryAccent,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primarySageGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primarySageGreen,
            activeTrackColor: AppColors.primarySageGreen.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMedium,
            inactiveTrackColor: AppColors.surfaceContainer,
          ),
        ],
      ),
    );
  }
}

enum SystemStatus { good, normal, warning, error }
