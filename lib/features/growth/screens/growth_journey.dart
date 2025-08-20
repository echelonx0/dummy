// lib/features/growth/screens/enhanced_growth_journey_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../providers/growth_provider.dart';
import '../models/growth_models.dart';

class EnhancedGrowthJourneyScreen extends StatefulWidget {
  const EnhancedGrowthJourneyScreen({super.key});

  @override
  State<EnhancedGrowthJourneyScreen> createState() =>
      _EnhancedGrowthJourneyScreenState();
}

class _EnhancedGrowthJourneyScreenState
    extends State<EnhancedGrowthJourneyScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrowthData();
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  Future<void> _loadGrowthData() async {
    if (!mounted) return;

    try {
      final growthProvider = context.read<GrowthProvider>();
      await growthProvider.initializeGrowthData();
    } catch (e) {
      if (mounted) {
        print('Error loading growth data: $e');
      }
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadGrowthData,
          color: AppColors.primarySageGreen,
          backgroundColor: AppColors.cardBackground,
          child: CustomScrollView(
            slivers: [_buildPremiumHeader(), _buildMainContent()],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPremiumHeader() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerAnimationController,
        builder: (context, child) {
          final opacity = _headerFadeAnimation.value.clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(0, _headerSlideAnimation.value),
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.paddingL),
                padding: const EdgeInsets.all(AppDimensions.paddingXL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primarySageGreen,
                      AppColors.primaryGold,
                      AppColors.primaryDarkBlue,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderContent(),
                    const SizedBox(height: AppDimensions.paddingL),
                    _buildHeaderStats(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: AppColors.primaryAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Growth Journey',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Building your best self',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryAccent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Consumer<GrowthProvider>(
      builder: (context, provider, child) {
        if (provider.growthProfile == null) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: _buildHeaderStatChip(
                '🔥 ${provider.growthProfile!.currentStreak}',
                'Streak',
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: _buildHeaderStatChip(
                '💪 ${provider.growthProfile!.totalTasksCompleted}',
                'Growth',
              ),
            ),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: _buildHeaderStatChip(
                '📝 ${provider.growthProfile!.totalJournalEntries}',
                'Insights',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingM,
        horizontal: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryAccent.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildAnimatedCard(
            delay: 0,
            child: Consumer<GrowthProvider>(
              builder: (context, provider, child) {
                return GrowthDashboardCard(
                  profile: provider.growthProfile,
                  onTap: () => _navigateToDetailedStats(),
                  isLoading: provider.isLoadingProfile,
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          _buildAnimatedCard(
            delay: 100,
            child: Consumer<GrowthProvider>(
              builder: (context, provider, child) {
                return GrowthStatsWidget(
                  analytics: provider.currentAnalytics,
                  isLoading: provider.isLoadingAnalytics,
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          _buildAnimatedCard(delay: 200, child: _buildQuickActionsSection()),

          const SizedBox(height: AppDimensions.paddingL),

          _buildAnimatedCard(delay: 300, child: _buildActiveTasksSection()),

          const SizedBox(height: AppDimensions.paddingL),

          _buildAnimatedCard(delay: 400, child: _buildRecentJournalSection()),

          const SizedBox(height: 120), // Bottom padding for FAB
        ]),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, _) {
        final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Interval(
              delay / 1000,
              (delay + 400) / 1000,
              curve: Curves.easeOutBack,
            ),
          ),
        );

        final opacity = delayedAnimation.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedAnimation.value)),
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GrowthSectionHeader(
            title: 'Quick Actions',
            subtitle: 'Take a moment for yourself',
            icon: Icons.flash_on,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    title: 'Journal',
                    subtitle: 'Reflect on your day',
                    icon: Icons.auto_stories,
                    color: AppColors.primarySageGreen,
                    onTap: () => _showJournalModal(),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: QuickActionButton(
                    title: 'Insights',
                    subtitle: 'View your progress',
                    icon: Icons.insights,
                    color: AppColors.primaryAccent,
                    onTap: () => _navigateToInsights(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTasksSection() {
    return Consumer<GrowthProvider>(
      builder: (context, provider, child) {
        return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GrowthSectionHeader(
                title: 'Growth Tasks',
                subtitle: 'Building your best self',
                icon: Icons.favorite_outline,
                color: AppColors.primaryAccent,
                actionText: provider.isLoadingTasks ? null : 'View All',
                onActionTap:
                    provider.isLoadingTasks
                        ? null
                        : () => _navigateToAllTasks(),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              if (provider.isLoadingTasks)
                _buildTasksLoading()
              else if (provider.tasksError != null)
                _buildTasksError(provider.tasksError!)
              else if (provider.pendingTasks.isEmpty)
                _buildNoTasks()
              else
                _buildTasksList(provider.pendingTasks.take(2).toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksList(List<GrowthTask> tasks) {
    return Column(
      children:
          tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingM,
                  ),
                  child: Consumer<GrowthProvider>(
                    builder: (context, provider, child) {
                      return GrowthTaskCard(
                        task: task,
                        onComplete: () => _completeTask(task.id),
                        onTap: () => _showTaskDetails(task),
                        isCompleting: provider.isCompletingTask,
                      );
                    },
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildTasksLoading() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primarySageGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primarySageGreen,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Finding perfect tasks for you... 🌱',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksError(String error) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.refresh, color: AppColors.error, size: 32),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Unable to load tasks right now',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          ElevatedButton(
            onPressed: () => context.read<GrowthProvider>().refreshTasks(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.primaryAccent,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTasks() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, color: AppColors.success, size: 48),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Amazing! You\'ve completed all your tasks! 🎉',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'New tasks will appear tomorrow. Keep growing! 💫',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJournalSection() {
    return Consumer<GrowthProvider>(
      builder: (context, provider, child) {
        return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GrowthSectionHeader(
                title: 'Recent Reflections',
                subtitle: 'Your emotional journey',
                icon: Icons.auto_stories,
                color: AppColors.primarySageGreen,
                actionText: provider.hasJournalEntries ? 'View All' : null,
                onActionTap:
                    provider.hasJournalEntries
                        ? () => _navigateToJournalHistory()
                        : null,
              ),
              const SizedBox(height: AppDimensions.paddingL),

              if (provider.isLoadingJournal)
                _buildJournalLoading()
              else if (provider.journalEntries.isEmpty)
                _buildNoJournalEntries()
              else
                _buildJournalList(provider.journalEntries.take(3).toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJournalList(List<JournalEntry> entries) {
    return Column(
      children:
          entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingM,
                  ),
                  child: JournalEntryCard(
                    entry: entry,
                    onTap: () => _showJournalEntryDetails(entry),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildJournalLoading() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primarySageGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primarySageGreen,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Loading your reflections... 📝',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoJournalEntries() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primarySageGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_stories, color: AppColors.primarySageGreen, size: 48),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Start journaling to track your emotional journey! 📝',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primarySageGreen,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Writing helps you understand your emotions and grow as a person',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton(
            onPressed: () => _showJournalModal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySageGreen,
              foregroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
            ),
            child: Text(
              'Write your first entry ✨',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<GrowthProvider>(
      builder: (context, provider, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, animation, child) {
            final clampedAnimation = animation.clamp(0.0, 1.0);
            return Transform.scale(
              scale: clampedAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showJournalModal();
                },
                backgroundColor: AppColors.primarySageGreen,
                foregroundColor: AppColors.primaryAccent,
                elevation: 12,
                highlightElevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                icon: const Icon(Icons.favorite, size: 24),
                label: Text(
                  'Journal',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =============================================================================
  // ACTION METHODS
  // =============================================================================

  Future<void> _completeTask(String taskId) async {
    try {
      await context.read<GrowthProvider>().completeTask(taskId);
      _showSuccessMessage('Task completed! You\'re amazing! 🎉');
    } catch (e) {
      _showErrorMessage('Failed to complete task: ${e.toString()}');
    }
  }

  void _showJournalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedJournalEntryModal(),
    );
  }

  void _showTaskDetails(GrowthTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTaskDetailsModal(task),
    );
  }

  void _showJournalEntryDetails(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJournalDetailsModal(entry),
    );
  }

  Widget _buildTaskDetailsModal(GrowthTask task) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Center(
        child: Text(
          'Task Details for: ${task.title}',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildJournalDetailsModal(JournalEntry entry) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Center(
        child: Text(
          'Journal Entry: ${entry.title}',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateToDetailedStats() => print('Navigate to detailed stats');
  void _navigateToInsights() => print('Navigate to insights');
  void _navigateToAllTasks() => print('Navigate to all tasks');
  void _navigateToJournalHistory() => print('Navigate to journal history');

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primaryAccent, size: 20),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingL),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.primaryAccent, size: 20),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingL),
      ),
    );
  }
}

// =============================================================================
// SUPPORTING WIDGETS
// =============================================================================

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const PremiumCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GrowthSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? actionText;
  final VoidCallback? onActionTap;

  const GrowthSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        if (actionText != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primarySageGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// These would be placeholders for the actual widget implementations
class GrowthDashboardCard extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onTap;
  final bool isLoading;

  const GrowthDashboardCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          Text(
            'Growth Dashboard',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
          ),
          if (isLoading)
            CircularProgressIndicator(color: AppColors.primarySageGreen)
          else
            Text(
              'Your growth stats here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class GrowthStatsWidget extends StatelessWidget {
  final dynamic analytics;
  final bool isLoading;

  const GrowthStatsWidget({
    super.key,
    required this.analytics,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          Text(
            'Growth Analytics',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
          ),
          if (isLoading)
            CircularProgressIndicator(color: AppColors.primarySageGreen)
          else
            Text(
              'Your analytics here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class GrowthTaskCard extends StatelessWidget {
  final GrowthTask task;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  final bool isCompleting;

  const GrowthTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onTap,
    required this.isCompleting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primarySageGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  task.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleting)
            CircularProgressIndicator(
              color: AppColors.primarySageGreen,
              strokeWidth: 2,
            )
          else
            IconButton(
              onPressed: onComplete,
              icon: Icon(
                Icons.check_circle_outline,
                color: AppColors.primarySageGreen,
              ),
            ),
        ],
      ),
    );
  }
}

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.primarySageGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              entry.content.length > 100
                  ? '${entry.content.substring(0, 100)}...'
                  : entry.content,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedJournalEntryModal extends StatelessWidget {
  const EnhancedJournalEntryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Center(
        child: Text(
          'Journal Entry Modal',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textDark),
        ),
      ),
    );
  }
}
