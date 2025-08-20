// lib/features/growth/providers/growth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/growth_service.dart';
import '../models/growth_models.dart';
import '../../../app/locator.dart';

class GrowthProvider extends ChangeNotifier {
  final GrowthService _growthService = locator<GrowthService>();

  // =============================================================================
  // STATE VARIABLES
  // =============================================================================

  // Growth Profile
  GrowthProfile? _growthProfile;
  bool _isLoadingProfile = false;
  String? _profileError;

  // Growth Tasks
  List<GrowthTask> _activeTasks = [];
  bool _isLoadingTasks = false;
  String? _tasksError;

  // Journal Entries
  List<JournalEntry> _journalEntries = [];
  bool _isLoadingJournal = false;
  String? _journalError;
  bool _hasMoreEntries = true;

  // Analytics
  GrowthAnalytics? _currentAnalytics;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  // Achievements
  List<GrowthAchievement> _unlockedAchievements = [];
  List<GrowthAchievement> _recentAchievements = [];
  bool _isLoadingAchievements = false;

  // UI State
  bool _showCelebration = false;
  String _celebrationMessage = '';
  bool _isSubmittingEntry = false;
  bool _isCompletingTask = false;

  // =============================================================================
  // GETTERS
  // =============================================================================

  // Growth Profile
  GrowthProfile? get growthProfile => _growthProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get profileError => _profileError;
  bool get hasProfile => _growthProfile != null;

  // Growth Tasks
  List<GrowthTask> get activeTasks => _activeTasks;
  bool get isLoadingTasks => _isLoadingTasks;
  String? get tasksError => _tasksError;
  bool get hasTasks => _activeTasks.isNotEmpty;

  // Completed vs Active tasks
  List<GrowthTask> get completedTasks =>
      _activeTasks.where((task) => task.isCompleted).toList();
  List<GrowthTask> get pendingTasks =>
      _activeTasks.where((task) => !task.isCompleted).toList();

  // Journal
  List<JournalEntry> get journalEntries => _journalEntries;
  bool get isLoadingJournal => _isLoadingJournal;
  String? get journalError => _journalError;
  bool get hasMoreEntries => _hasMoreEntries;
  bool get hasJournalEntries => _journalEntries.isNotEmpty;

  // Analytics
  GrowthAnalytics? get currentAnalytics => _currentAnalytics;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get analyticsError => _analyticsError;

  // Achievements
  List<GrowthAchievement> get unlockedAchievements => _unlockedAchievements;
  List<GrowthAchievement> get recentAchievements => _recentAchievements;
  bool get isLoadingAchievements => _isLoadingAchievements;

  // UI State
  bool get showCelebration => _showCelebration;
  String get celebrationMessage => _celebrationMessage;
  bool get isSubmittingEntry => _isSubmittingEntry;
  bool get isCompletingTask => _isCompletingTask;

  // Computed Properties
  double get overallProgress {
    if (_growthProfile == null) return 0.0;
    return (_growthProfile!.overallGrowthScore / 1000).clamp(0.0, 1.0);
  }

  bool get isGrowthReady => _growthProfile?.isGrowthReady ?? false;

  int get currentStreak => _growthProfile?.currentStreak ?? 0;

  String get growthLevel {
    final score = _growthProfile?.overallGrowthScore ?? 0;
    if (score >= 500) return 'Love Magnet 🧲';
    if (score >= 300) return 'Heart Healer 💚';
    if (score >= 150) return 'Soul Seeker 🔍';
    if (score >= 50) return 'Growth Explorer 🌱';
    return 'Love Beginner 💫';
  }

  Color get growthLevelColor {
    final score = _growthProfile?.overallGrowthScore ?? 0;
    if (score >= 500) return const Color(0xFF8B5FBF); // Soulful Purple
    if (score >= 300) return const Color(0xFF7FB069); // Growth Green
    if (score >= 150) return const Color(0xFF4A90E2); // Hope Blue
    if (score >= 50) return const Color(0xFFE8B4CB); // Nurturing Pink
    return const Color(0xFFF4D03F); // Warm Gold
  }

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  /// Initialize growth data
  Future<void> initializeGrowthData() async {
    await Future.wait([
      loadGrowthProfile(),
      loadActiveTasks(),
      loadRecentJournalEntries(),
      generateCurrentAnalytics(),
    ]);
  }

  // =============================================================================
  // GROWTH PROFILE METHODS
  // =============================================================================

  /// Load user's growth profile
  Future<void> loadGrowthProfile() async {
    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      _growthProfile = await _growthService.getGrowthProfile();
      _profileError = null;
    } catch (e) {
      _profileError = e.toString();
      _growthProfile = null;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Refresh growth profile from server
  Future<void> refreshGrowthProfile() async {
    await loadGrowthProfile();
    HapticFeedback.lightImpact();
  }

  // =============================================================================
  // GROWTH TASKS METHODS
  // =============================================================================

  /// Load user's active growth tasks
  Future<void> loadActiveTasks() async {
    _isLoadingTasks = true;
    _tasksError = null;
    notifyListeners();

    try {
      _activeTasks = await _growthService.getPersonalizedTasks();
      _tasksError = null;
    } catch (e) {
      _tasksError = e.toString();
      _activeTasks = [];
    } finally {
      _isLoadingTasks = false;
      notifyListeners();
    }
  }

  /// Complete a growth task
  Future<void> completeTask(String taskId) async {
    _isCompletingTask = true;
    notifyListeners();

    try {
      await _growthService.completeTask(taskId);

      // Find and update the task locally
      final taskIndex = _activeTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _activeTasks[taskIndex];
        _activeTasks[taskIndex] = GrowthTask(
          id: task.id,
          title: task.title,
          description: task.description,
          detailedInstructions: task.detailedInstructions,
          category: task.category,
          difficulty: task.difficulty,
          estimatedMinutes: task.estimatedMinutes,
          pointValue: task.pointValue,
          tags: task.tags,
          encouragementMessage: task.encouragementMessage,
          completionCelebration: task.completionCelebration,
          isPersonalized: task.isPersonalized,
          assignedDate: task.assignedDate,
          completedDate: DateTime.now(),
          progressData: task.progressData,
          isActive: false,
        );

        // Show celebration
        _showTaskCompletionCelebration(task);
      }

      // Refresh profile to get updated scores
      await loadGrowthProfile();

      HapticFeedback.heavyImpact();
    } catch (e) {
      _showErrorMessage('Failed to complete task: ${e.toString()}');
    } finally {
      _isCompletingTask = false;
      notifyListeners();
    }
  }

  /// Refresh tasks from server
  Future<void> refreshTasks() async {
    await loadActiveTasks();
    HapticFeedback.lightImpact();
  }

  // =============================================================================
  // JOURNAL METHODS
  // =============================================================================

  /// Load recent journal entries
  Future<void> loadRecentJournalEntries() async {
    _isLoadingJournal = true;
    _journalError = null;
    notifyListeners();

    try {
      _journalEntries = await _growthService.getJournalEntries(limit: 20);
      _hasMoreEntries = _journalEntries.length == 20;
      _journalError = null;
    } catch (e) {
      _journalError = e.toString();
      _journalEntries = [];
    } finally {
      _isLoadingJournal = false;
      notifyListeners();
    }
  }

  /// Load more journal entries (pagination)
  Future<void> loadMoreJournalEntries() async {
    if (!_hasMoreEntries || _isLoadingJournal) return;

    try {
      final moreEntries = await _growthService.getJournalEntries(
        limit: 20,
        // lastDocument: lastDoc, // Would need to pass actual DocumentSnapshot
      );

      if (moreEntries.length < 20) {
        _hasMoreEntries = false;
      }

      _journalEntries.addAll(moreEntries);
      notifyListeners();
    } catch (e) {
      _showErrorMessage('Failed to load more entries: ${e.toString()}');
    }
  }

  /// Create a new journal entry
  Future<bool> createJournalEntry({
    required String title,
    required String content,
    required MoodType mood,
    required int moodIntensity,
    List<String>? tags,
    String? promptId,
  }) async {
    _isSubmittingEntry = true;
    notifyListeners();

    try {
      final entryId = await _growthService.createJournalEntry(
        title: title,
        content: content,
        mood: mood,
        moodIntensity: moodIntensity,
        tags: tags,
        promptId: promptId,
      );

      // Add the new entry to the top of the list
      final newEntry = JournalEntry(
        id: entryId,
        userId: _growthService.currentUserId!,
        title: title,
        content: content,
        mood: mood,
        moodIntensity: moodIntensity,
        tags: tags ?? [],
        createdAt: DateTime.now(),
        isPrivate: true,
        metadata: {},
        attachments: [],
        promptId: promptId,
        aiInsights: {},
      );

      _journalEntries.insert(0, newEntry);

      // Refresh profile for updated stats
      await loadGrowthProfile();

      _showJournalCompletionCelebration();
      HapticFeedback.mediumImpact();

      return true;
    } catch (e) {
      _showErrorMessage('Failed to create journal entry: ${e.toString()}');
      return false;
    } finally {
      _isSubmittingEntry = false;
      notifyListeners();
    }
  }

  /// Get mood analytics for the current month
  Future<Map<String, dynamic>?> getCurrentMoodAnalytics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      return await _growthService.getMoodAnalytics(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      _showErrorMessage('Failed to load mood analytics: ${e.toString()}');
      return null;
    }
  }

  // =============================================================================
  // ANALYTICS METHODS
  // =============================================================================

  /// Generate analytics for the current month
  Future<void> generateCurrentAnalytics() async {
    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      _currentAnalytics = await _growthService.generateAnalytics(
        periodStart: startOfMonth,
        periodEnd: now,
      );
      _analyticsError = null;
    } catch (e) {
      _analyticsError = e.toString();
      _currentAnalytics = null;
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  /// Generate analytics for a custom period
  Future<GrowthAnalytics?> generateCustomAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _growthService.generateAnalytics(
        periodStart: startDate,
        periodEnd: endDate,
      );
    } catch (e) {
      _showErrorMessage('Failed to generate analytics: ${e.toString()}');
      return null;
    }
  }

  // =============================================================================
  // CELEBRATION & UI METHODS
  // =============================================================================

  /// Show task completion celebration
  void _showTaskCompletionCelebration(GrowthTask task) {
    _celebrationMessage = task.completionCelebration;
    _showCelebration = true;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _showCelebration = false;
      notifyListeners();
    });
  }

  /// Show journal completion celebration
  void _showJournalCompletionCelebration() {
    _celebrationMessage =
        'Beautiful reflection! Your heart is growing stronger! 💖✨';
    _showCelebration = true;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _showCelebration = false;
      notifyListeners();
    });
  }

  /// Manually hide celebration
  void hideCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  /// Show error message (would integrate with your error handling system)
  void _showErrorMessage(String message) {
    // This would typically show a snackbar or dialog
    debugPrint('Growth Error: $message');
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    // This would typically show a success snackbar
    debugPrint('Growth Success: $message');
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Get progress for a specific category
  double getCategoryProgress(GrowthCategory category) {
    if (_growthProfile == null) return 0.0;
    final score = _growthProfile!.categoryScores[category] ?? 0;
    return (score / 100).clamp(0.0, 1.0);
  }

  /// Get tasks for a specific category
  List<GrowthTask> getTasksForCategory(GrowthCategory category) {
    return _activeTasks.where((task) => task.category == category).toList();
  }

  /// Get journal entries for a specific mood
  List<JournalEntry> getEntriesForMood(MoodType mood) {
    return _journalEntries.where((entry) => entry.mood == mood).toList();
  }

  /// Get recent activity summary
  Map<String, int> getRecentActivitySummary() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final recentTasks =
        _activeTasks
            .where(
              (task) =>
                  task.completedDate != null &&
                  task.completedDate!.isAfter(weekAgo),
            )
            .length;

    final recentEntries =
        _journalEntries
            .where((entry) => entry.createdAt.isAfter(weekAgo))
            .length;

    return {
      'tasks': recentTasks,
      'journalEntries': recentEntries,
      'totalActivities': recentTasks + recentEntries,
    };
  }

  /// Check if user has been active today
  bool get wasActiveToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final hasTaskToday = _activeTasks.any(
      (task) =>
          task.completedDate != null && task.completedDate!.isAfter(today),
    );

    final hasEntryToday = _journalEntries.any(
      (entry) => entry.createdAt.isAfter(today),
    );

    return hasTaskToday || hasEntryToday;
  }

  /// Get encouraging message based on current state
  String get encouragingMessage {
    if (_growthProfile == null) {
      return 'Welcome to your growth journey! Let\'s build something beautiful together 🌟';
    }

    if (currentStreak >= 30) {
      return 'You\'re absolutely incredible! 30 days of growth! 🔥✨';
    } else if (currentStreak >= 7) {
      return 'Amazing! You\'re building a beautiful habit! Keep going! 💪';
    } else if (wasActiveToday) {
      return 'You\'re growing today! Your future self will thank you! 🌱';
    } else if (_growthProfile!.overallGrowthScore >= 100) {
      return 'Look how far you\'ve come! You\'re becoming amazing! 🦋';
    } else {
      return 'Every small step matters. You\'re worth the effort! 💖';
    }
  }

  /// Get next milestone message
  String get nextMilestone {
    final score = _growthProfile?.overallGrowthScore ?? 0;

    if (score < 50) {
      return 'Reach 50 points to become a Growth Explorer! 🌱';
    } else if (score < 150) {
      return 'Reach 150 points to become a Soul Seeker! 🔍';
    } else if (score < 300) {
      return 'Reach 300 points to become a Heart Healer! 💚';
    } else if (score < 500) {
      return 'Reach 500 points to become a Love Magnet! 🧲';
    } else {
      return 'You\'ve mastered the art of growth! Keep inspiring others! ✨';
    }
  }

  // =============================================================================
  // REFRESH ALL DATA
  // =============================================================================

  /// Refresh all growth data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadGrowthProfile(),
      loadActiveTasks(),
      loadRecentJournalEntries(),
      generateCurrentAnalytics(),
    ]);

    HapticFeedback.mediumImpact();
    _showSuccessMessage('Growth data refreshed! 🔄');
  }

  // =============================================================================
  // DISPOSE
  // =============================================================================

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
