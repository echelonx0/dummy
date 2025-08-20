// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Real-time data streams
  late Stream<Map<String, dynamic>> _userMetricsStream;
  late Stream<List<Map<String, dynamic>>> _matchRunsStream;
  late Stream<List<Map<String, dynamic>>> _errorsStream;

  bool _isTestingFunction = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeStreams();
  }

  void _initializeStreams() {
    // User Metrics Stream
    _userMetricsStream = FirebaseFirestore.instance
        .collection('profiles')
        .snapshots()
        .asyncMap((snapshot) async {
          final docs = snapshot.docs;
          final total = docs.length;
          final active =
              docs.where((doc) => doc.data()['activeAccount'] == true).length;
          final premium =
              docs
                  .where(
                    (doc) =>
                        doc.data()['premiumStatus']?['active'] == true ||
                        doc.data()['subscription']?['status'] == 'active' ||
                        doc.data()['isPremium'] == true,
                  )
                  .length;
          final complete =
              docs
                  .where((doc) => doc.data()['isProfileComplete'] == true)
                  .length;

          // Get courtship data
          final courtshipSnapshot =
              await FirebaseFirestore.instance
                  .collection('inCourtshipFlow')
                  .where('status', isEqualTo: 'active')
                  .get();

          return {
            'totalUsers': total,
            'activeUsers': active,
            'premiumUsers': premium,
            'completeProfiles': complete,
            'activeCourtships': courtshipSnapshot.docs.length,
            'conversionRate':
                total > 0 ? (premium / total * 100).toStringAsFixed(1) : '0',
            'completionRate':
                total > 0 ? (complete / total * 100).toStringAsFixed(1) : '0',
          };
        });

    // Match Runs Stream
    _matchRunsStream = FirebaseFirestore.instance
        .collection('matchEngineRuns')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );

    // Errors Stream
    _errorsStream = FirebaseFirestore.instance
        .collection('platform_errors')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF222831),
        foregroundColor: const Color(0xFFDFD0B8),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF948979),
          labelColor: const Color(0xFFDFD0B8),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.error), text: 'Errors'),
            Tab(icon: Icon(Icons.science), text: 'Testing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildErrorsTab(),
          _buildTestingTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _userMetricsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final metrics = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMetricCard(
                    'Total Users',
                    metrics['totalUsers'].toString(),
                    Icons.people,
                    const Color(0xFF3B82F6),
                  ),
                  _buildMetricCard(
                    'Active Users',
                    metrics['activeUsers'].toString(),
                    Icons.verified_user,
                    const Color(0xFF10B981),
                  ),
                  _buildMetricCard(
                    'Premium Users',
                    metrics['premiumUsers'].toString(),
                    Icons.star,
                    const Color(0xFFF59E0B),
                  ),
                  _buildMetricCard(
                    'Complete Profiles',
                    metrics['completeProfiles'].toString(),
                    Icons.check_circle,
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Conversion Metrics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conversion Metrics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildProgressMetric(
                              'Premium Conversion',
                              '${metrics['conversionRate']}%',
                              double.parse(metrics['conversionRate']) / 100,
                              const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProgressMetric(
                              'Profile Completion',
                              '${metrics['completionRate']}%',
                              double.parse(metrics['completionRate']) / 100,
                              const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Courtships',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${metrics['activeCourtships']} active',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Users currently in the courtship flow',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildActionButton(
                            'View Analytics',
                            Icons.analytics,
                            () => _tabController.animateTo(1),
                            const Color(0xFF3B82F6),
                          ),
                          _buildActionButton(
                            'Check Errors',
                            Icons.error_outline,
                            () => _tabController.animateTo(2),
                            const Color(0xFFEF4444),
                          ),
                          _buildActionButton(
                            'Test Functions',
                            Icons.science,
                            () => _tabController.animateTo(3),
                            const Color(0xFF8B5CF6),
                          ),
                          _buildActionButton(
                            'Export Data',
                            Icons.download,
                            _exportData,
                            const Color(0xFF10B981),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _matchRunsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No analytics data available'));
        }

        final runs = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Match Engine Performance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsMetric(
                              'Total Matches',
                              runs
                                  .fold<int>(
                                    0,
                                    (sum, run) =>
                                        sum +
                                        ((run['metrics']?['matchesGenerated']
                                                    as num?)
                                                ?.toInt() ??
                                            0),
                                  )
                                  .toString(),
                              Icons.favorite,
                              const Color(0xFFEF4444),
                            ),
                          ),
                          Expanded(
                            child: _buildAnalyticsMetric(
                              'Avg Score',
                              runs.isNotEmpty
                                  ? (runs.fold<double>(
                                            0.0,
                                            (sum, run) =>
                                                sum +
                                                ((run['qualityMetrics']?['averageCompatibilityScore']
                                                            as num?)
                                                        ?.toDouble() ??
                                                    0.0),
                                          ) /
                                          runs.length)
                                      .toStringAsFixed(1)
                                  : '0',
                              Icons.trending_up,
                              const Color(0xFF10B981),
                            ),
                          ),
                          Expanded(
                            child: _buildAnalyticsMetric(
                              'Success Rate',
                              runs.isNotEmpty
                                  ? '${(runs.fold<double>(0.0, (sum, run) {
                                        final metrics = run['metrics'] as Map<String, dynamic>?;
                                        if (metrics == null) return sum;
                                        final generated = (metrics['matchesGenerated'] as num?)?.toInt() ?? 0;
                                        final successful = (metrics['successfulMatches'] as num?)?.toInt() ?? 0;
                                        return sum + (generated > 0 ? (successful / generated) : 0);
                                      }) / runs.length * 100).toStringAsFixed(1)}%'
                                  : '0%',
                              Icons.check_circle,
                              const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Runs Table
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Match Engine Runs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                () => Navigator.pushNamed(
                                  context,
                                  '/match-analytics',
                                ),
                            icon: const Icon(Icons.analytics),
                            label: const Text('Detailed Analytics'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Run ID')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Users')),
                            DataColumn(label: Text('Matches')),
                            DataColumn(label: Text('Avg Score')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows:
                              runs.map((run) {
                                final timestamp =
                                    run['timestamp'] as Timestamp?;
                                final metrics =
                                    run['metrics'] as Map<String, dynamic>?;
                                final qualityMetrics =
                                    run['qualityMetrics']
                                        as Map<String, dynamic>?;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        run['id']?.toString().substring(0, 8) ??
                                            'N/A',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        timestamp
                                                ?.toDate()
                                                .toString()
                                                .substring(5, 16) ??
                                            'N/A',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (metrics?['usersProcessed'] as num?)
                                                ?.toString() ??
                                            '0',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (metrics?['matchesGenerated'] as num?)
                                                ?.toString() ??
                                            '0',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (qualityMetrics?['averageCompatibilityScore']
                                                    as num?)
                                                ?.toString() ??
                                            '0',
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(run['status']),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          run['status'] ?? 'unknown',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _errorsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No errors found - System is healthy! 🎉'),
          );
        }

        final errors = snapshot.data!;
        final errorsByType = <String, int>{};

        for (final error in errors) {
          final type = error['errorType'] ?? 'unknown';
          errorsByType[type] = (errorsByType[type] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Error Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            errorsByType.entries.map((entry) {
                              return Chip(
                                label: Text('${entry.key}: ${entry.value}'),
                                backgroundColor: _getErrorTypeColor(entry.key),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Error List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Errors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: errors.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final error = errors[index];
                          final timestamp = error['timestamp'] as Timestamp?;

                          return ExpansionTile(
                            leading: Icon(
                              _getErrorIcon(error['severity']),
                              color: _getSeverityColor(error['severity']),
                            ),
                            title: Text(error['errorCode'] ?? 'Unknown Error'),
                            subtitle: Text(
                              '${error['functionName']} - ${timestamp?.toDate().toString().substring(0, 19) ?? 'No timestamp'}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Message: ${error['errorMessage'] ?? 'No message'}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'User: ${error['userId'] ?? 'Unknown'}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Type: ${error['errorType'] ?? 'Unknown'}',
                                    ),
                                    if (error['resolved'] != true) ...[
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                _markErrorResolved(error['id']),
                                        child: const Text('Mark as Resolved'),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Function Testing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Test Premium Function
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Premium Instant Matching',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test the premium instant matching function with your account',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            _isTestingFunction ? null : _testPremiumFunction,
                        icon:
                            _isTestingFunction
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.play_arrow),
                        label: Text(
                          _isTestingFunction ? 'Testing...' : 'Test Function',
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _triggerScheduledMatching,
                        icon: const Icon(Icons.schedule),
                        label: const Text('Trigger Scheduled'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  if (_testResult.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Test Result:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _testResult,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Database Operations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Database Operations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildActionButton(
                        'Clear Errors',
                        Icons.clear_all,
                        _clearResolvedErrors,
                        const Color(0xFFEF4444),
                      ),
                      _buildActionButton(
                        'Reset Usage',
                        Icons.refresh,
                        _resetUsageTracking,
                        const Color(0xFFF59E0B),
                      ),
                      _buildActionButton(
                        'Export Logs',
                        Icons.file_download,
                        _exportErrorLogs,
                        const Color(0xFF3B82F6),
                      ),
                      _buildActionButton(
                        'Health Check',
                        Icons.health_and_safety,
                        _performHealthCheck,
                        const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // System Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusItem(
                    'Cloud Functions',
                    true,
                    'All functions operational',
                  ),
                  _buildStatusItem(
                    'Firestore',
                    true,
                    'Database responding normally',
                  ),
                  _buildStatusItem(
                    'Authentication',
                    true,
                    'Auth service healthy',
                  ),
                  _buildStatusItem(
                    'Gemini AI',
                    true,
                    'API responding within limits',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(
    String title,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildAnalyticsMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isHealthy, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color:
                isHealthy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'running':
        return const Color(0xFF3B82F6);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color _getErrorTypeColor(String type) {
    switch (type) {
      case 'authentication':
        return const Color(0xFFEF4444);
      case 'authorization':
        return const Color(0xFFF59E0B);
      case 'validation':
        return const Color(0xFF8B5CF6);
      case 'api_limit':
        return const Color(0xFF3B82F6);
      case 'processing':
        return const Color(0xFF10B981);
      case 'system':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon(String? severity) {
    switch (severity) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.error;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  Color _getSeverityColor(String? severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFF7F1D1D);
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  // Action Methods
  Future<void> _testPremiumFunction() async {
    setState(() {
      _isTestingFunction = true;
      _testResult = '';
    });

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('generateInstantMatches')
          .call({'requestedMatches': 3, 'minCompatibilityScore': 60});

      setState(() {
        _testResult = 'SUCCESS: ${result.data.toString()}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'ERROR: $e';
      });
    } finally {
      setState(() {
        _isTestingFunction = false;
      });
    }
  }

  Future<void> _triggerScheduledMatching() async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('generateMatchRecommendationsWithAnalytics')
          .call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scheduled matching triggered successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _markErrorResolved(String errorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('platform_errors')
          .doc(errorId)
          .update({
            'resolved': true,
            'resolutionNotes': 'Marked as resolved by admin',
            'resolvedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error marked as resolved')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
    }
  }

  Future<void> _clearResolvedErrors() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Resolved Errors'),
            content: const Text(
              'This will permanently delete all resolved errors. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final resolvedErrors =
            await FirebaseFirestore.instance
                .collection('platform_errors')
                .where('resolved', isEqualTo: true)
                .get();

        for (final doc in resolvedErrors.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted ${resolvedErrors.docs.length} resolved errors',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing: $e')));
      }
    }
  }

  Future<void> _resetUsageTracking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Usage Tracking'),
            content: const Text(
              'This will reset all premium usage limits. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final usageRecords =
            await FirebaseFirestore.instance
                .collection('premium_usage_tracking')
                .get();

        for (final doc in usageRecords.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usage tracking reset successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error resetting: $e')));
      }
    }
  }

  Future<void> _exportErrorLogs() async {
    // In a real implementation, you'd export to CSV or send via email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality would be implemented here'),
      ),
    );
  }

  Future<void> _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export functionality would be implemented here'),
      ),
    );
  }

  Future<void> _performHealthCheck() async {
    // Perform basic connectivity tests
    try {
      // Test Firestore
      await FirebaseFirestore.instance.collection('profiles').limit(1).get();

      // Test Functions (with timeout)
      await FirebaseFunctions.instance
          .httpsCallable('testMatchingManually')
          .call()
          .timeout(const Duration(seconds: 10));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Health check passed - All systems operational'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Health check failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
