// lib/features/growth/services/growth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../app/locator.dart';
import '../models/growth_models.dart';

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = locator<FirebaseService>();
  final AuthService _authService = locator<AuthService>();

  String? get currentUserId => _authService.getCurrentUser()?.uid;

  // =============================================================================
  // GROWTH PROFILE MANAGEMENT
  // =============================================================================

  /// Get or create user's growth profile
  Future<GrowthProfile> getGrowthProfile() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final doc =
          await _firestore
              .collection('growth_profiles')
              .doc(currentUserId)
              .get();

      if (doc.exists) {
        return GrowthProfile.fromFirestore(doc);
      } else {
        // Create new growth profile
        final newProfile = GrowthProfile(
          userId: currentUserId!,
          overallGrowthScore: 0,
          categoryScores: {
            for (var category in GrowthCategory.values) category: 0,
          },
          currentStreak: 0,
          longestStreak: 0,
          lastActivity: DateTime.now(),
          completedAchievements: [],
          totalTasksCompleted: 0,
          totalJournalEntries: 0,
          preferences: {
            'dailyReminderTime': '20:00',
            'preferredDifficulty': TaskDifficulty.beginner.name,
            'enableEncouragement': true,
            'privacyLevel': 'private',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('growth_profiles')
            .doc(currentUserId)
            .set(newProfile.toFirestore());

        return newProfile;
      }
    } catch (e) {
      throw Exception('Failed to get growth profile: $e');
    }
  }

  /// Update growth profile with new activity
  Future<void> updateGrowthProfile({
    int? scoreIncrease,
    GrowthCategory? category,
    bool? completedTask,
    bool? addedJournalEntry,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final profileRef = _firestore
          .collection('growth_profiles')
          .doc(currentUserId);
      final profile = await getGrowthProfile();

      final now = DateTime.now();
      final wasActiveToday = _isSameDay(profile.lastActivity, now);

      // Calculate new streak
      int newStreak = profile.currentStreak;
      if (!wasActiveToday) {
        final daysSinceLastActivity =
            now.difference(profile.lastActivity).inDays;
        if (daysSinceLastActivity == 1) {
          newStreak += 1; // Continue streak
        } else if (daysSinceLastActivity > 1) {
          newStreak = 1; // Reset streak
        }
      }

      // Prepare updates
      final updates = <String, dynamic>{
        'lastActivity': Timestamp.fromDate(now),
        'currentStreak': newStreak,
        'longestStreak':
            newStreak > profile.longestStreak
                ? newStreak
                : profile.longestStreak,
        'updatedAt': Timestamp.fromDate(now),
      };

      if (scoreIncrease != null) {
        updates['overallGrowthScore'] =
            profile.overallGrowthScore + scoreIncrease;
      }

      if (category != null && scoreIncrease != null) {
        final currentCategoryScore = profile.categoryScores[category] ?? 0;
        updates['categoryScores.${category.name}'] =
            currentCategoryScore + scoreIncrease;
      }

      if (completedTask == true) {
        updates['totalTasksCompleted'] = profile.totalTasksCompleted + 1;
      }

      if (addedJournalEntry == true) {
        updates['totalJournalEntries'] = profile.totalJournalEntries + 1;
      }

      await profileRef.update(updates);

      // Check for new achievements
      await _checkForAchievements();
    } catch (e) {
      throw Exception('Failed to update growth profile: $e');
    }
  }

  // =============================================================================
  // GROWTH TASKS MANAGEMENT
  // =============================================================================

  /// Get personalized growth tasks for user
  Future<List<GrowthTask>> getPersonalizedTasks() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final profile = await getGrowthProfile();

      // Get user's assigned tasks
      final userTasksQuery =
          await _firestore
              .collection('user_growth_tasks')
              .doc(currentUserId)
              .collection('assigned_tasks')
              .where('isActive', isEqualTo: true)
              .orderBy('assignedDate', descending: true)
              .limit(10)
              .get();

      final assignedTasks =
          userTasksQuery.docs
              .map((doc) => GrowthTask.fromFirestore(doc))
              .toList();

      // If user has fewer than 5 active tasks, generate more
      if (assignedTasks.length < 5) {
        await _generatePersonalizedTasks(profile, 5 - assignedTasks.length);

        // Re-fetch updated tasks
        final updatedQuery =
            await _firestore
                .collection('user_growth_tasks')
                .doc(currentUserId)
                .collection('assigned_tasks')
                .where('isActive', isEqualTo: true)
                .orderBy('assignedDate', descending: true)
                .limit(10)
                .get();

        return updatedQuery.docs
            .map((doc) => GrowthTask.fromFirestore(doc))
            .toList();
      }

      return assignedTasks;
    } catch (e) {
      throw Exception('Failed to get personalized tasks: $e');
    }
  }

  /// Complete a growth task
  Future<void> completeTask(String taskId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final taskRef = _firestore
          .collection('user_growth_tasks')
          .doc(currentUserId)
          .collection('assigned_tasks')
          .doc(taskId);

      final taskDoc = await taskRef.get();
      if (!taskDoc.exists) throw Exception('Task not found');

      final task = GrowthTask.fromFirestore(taskDoc);

      // Update task as completed
      await taskRef.update({
        'completedDate': Timestamp.fromDate(DateTime.now()),
        'isActive': false,
        'progressData.completedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update growth profile
      await updateGrowthProfile(
        scoreIncrease: task.pointValue,
        category: task.category,
        completedTask: true,
      );

      // Log completion for analytics
      await _logGrowthActivity('task_completed', {
        'taskId': taskId,
        'category': task.category.name,
        'difficulty': task.difficulty.name,
        'pointValue': task.pointValue,
      });
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  /// Generate personalized tasks based on user profile
  Future<void> _generatePersonalizedTasks(
    GrowthProfile profile,
    int count,
  ) async {
    try {
      // Get task templates based on user's needs
      final templates = await _getTaskTemplates(profile);

      final batch = _firestore.batch();
      final now = DateTime.now();

      for (int i = 0; i < count && i < templates.length; i++) {
        final template = templates[i];
        final taskId = _firestore.collection('dummy').doc().id;

        final personalizedTask = GrowthTask(
          id: taskId,
          title: template['title'],
          description: template['description'],
          detailedInstructions: template['detailedInstructions'],
          category: GrowthCategory.values.firstWhere(
            (e) => e.name == template['category'],
          ),
          difficulty: TaskDifficulty.values.firstWhere(
            (e) => e.name == template['difficulty'],
          ),
          estimatedMinutes: template['estimatedMinutes'],
          pointValue: template['pointValue'],
          tags: List<String>.from(template['tags']),
          encouragementMessage: template['encouragementMessage'],
          completionCelebration: template['completionCelebration'],
          isPersonalized: true,
          assignedDate: now,
          progressData: {},
          isActive: true,
        );

        final taskRef = _firestore
            .collection('user_growth_tasks')
            .doc(currentUserId)
            .collection('assigned_tasks')
            .doc(taskId);

        batch.set(taskRef, personalizedTask.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to generate personalized tasks: $e');
    }
  }

  /// Get task templates based on user profile analysis
  Future<List<Map<String, dynamic>>> _getTaskTemplates(
    GrowthProfile profile,
  ) async {
    // Analyze user's weak areas
    final weakCategories =
        profile.categoryScores.entries
            .where((entry) => entry.value < 50)
            .map((entry) => entry.key)
            .toList();

    // If no weak areas, focus on general growth
    final targetCategories =
        weakCategories.isEmpty
            ? GrowthCategory.values.take(3).toList()
            : weakCategories.take(3).toList();

    // Task templates (in real app, these would come from Firestore)
    final allTemplates = _getTaskTemplateLibrary();

    // Filter templates based on target categories
    return allTemplates.where((template) {
      final category = GrowthCategory.values.firstWhere(
        (e) => e.name == template['category'],
      );
      return targetCategories.contains(category);
    }).toList();
  }

  // =============================================================================
  // JOURNAL MANAGEMENT
  // =============================================================================

  /// Create a new journal entry
  Future<String> createJournalEntry({
    required String title,
    required String content,
    required MoodType mood,
    required int moodIntensity,
    List<String>? tags,
    String? promptId,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final entryId = _firestore.collection('dummy').doc().id;

      final entry = JournalEntry(
        id: entryId,
        userId: currentUserId!,
        title: title,
        content: content,
        mood: mood,
        moodIntensity: moodIntensity,
        tags: tags ?? [],
        createdAt: DateTime.now(),
        isPrivate: true,
        metadata: {
          'wordCount': content.split(' ').length,
          'hasEmotionalContent': _detectEmotionalContent(content),
        },
        attachments: [],
        promptId: promptId,
        aiInsights: {}, // Will be populated by AI service
      );

      await _firestore
          .collection('journal_entries')
          .doc(entryId)
          .set(entry.toFirestore());

      // Update growth profile
      await updateGrowthProfile(
        scoreIncrease: 5, // Points for journal entry
        addedJournalEntry: true,
      );

      // Log for analytics
      await _logGrowthActivity('journal_entry_created', {
        'entryId': entryId,
        'mood': mood.name,
        'moodIntensity': moodIntensity,
        'wordCount': entry.wordCount,
      });

      return entryId;
    } catch (e) {
      throw Exception('Failed to create journal entry: $e');
    }
  }

  /// Get user's journal entries with pagination
  Future<List<JournalEntry>> getJournalEntries({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      Query query = _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get journal entries: $e');
    }
  }

  /// Get mood analytics for a date range
  Future<Map<String, dynamic>> getMoodAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final snapshot =
          await _firestore
              .collection('journal_entries')
              .where('userId', isEqualTo: currentUserId)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .get();

      final entries =
          snapshot.docs.map((doc) => JournalEntry.fromFirestore(doc)).toList();

      if (entries.isEmpty) {
        return {
          'averageMood': 5.0,
          'moodDistribution': <String, int>{},
          'totalEntries': 0,
          'moodTrend': 'stable',
        };
      }

      // Calculate mood analytics
      final moodCounts = <MoodType, int>{};
      double totalMoodScore = 0;

      for (final entry in entries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
        totalMoodScore += entry.moodIntensity;
      }

      final averageMood = totalMoodScore / entries.length;

      return {
        'averageMood': averageMood,
        'moodDistribution': moodCounts.map(
          (mood, count) => MapEntry(mood.name, count),
        ),
        'totalEntries': entries.length,
        'moodTrend': _calculateMoodTrend(entries),
        'topMoods': _getTopMoods(moodCounts),
      };
    } catch (e) {
      throw Exception('Failed to get mood analytics: $e');
    }
  }

  // =============================================================================
  // ACHIEVEMENTS SYSTEM
  // =============================================================================

  /// Check and unlock new achievements
  Future<List<GrowthAchievement>> _checkForAchievements() async {
    if (currentUserId == null) return [];

    try {
      final profile = await getGrowthProfile();
      final allAchievements = await _getAllAchievements();
      final newlyUnlocked = <GrowthAchievement>[];

      for (final achievement in allAchievements) {
        if (!profile.completedAchievements.contains(achievement.id)) {
          if (_checkAchievementRequirements(achievement, profile)) {
            // Unlock achievement
            await _unlockAchievement(achievement.id);
            newlyUnlocked.add(achievement);
          }
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  /// Unlock a specific achievement
  Future<void> _unlockAchievement(String achievementId) async {
    try {
      await _firestore.collection('growth_profiles').doc(currentUserId).update({
        'completedAchievements': FieldValue.arrayUnion([achievementId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Log achievement unlock
      await _logGrowthActivity('achievement_unlocked', {
        'achievementId': achievementId,
      });
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  /// Get all available achievements
  Future<List<GrowthAchievement>> _getAllAchievements() async {
    // In production, this would fetch from Firestore
    // For now, return predefined achievements
    return _getAchievementLibrary();
  }

  // =============================================================================
  // ANALYTICS & INSIGHTS
  // =============================================================================

  /// Generate growth analytics for a period
  Future<GrowthAnalytics> generateAnalytics({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      // Get tasks completed in period
      final tasksQuery =
          await _firestore
              .collection('user_growth_tasks')
              .doc(currentUserId)
              .collection('assigned_tasks')
              .where(
                'completedDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart),
              )
              .where(
                'completedDate',
                isLessThanOrEqualTo: Timestamp.fromDate(periodEnd),
              )
              .get();

      // Get journal entries in period
      final journalQuery =
          await _firestore
              .collection('journal_entries')
              .where('userId', isEqualTo: currentUserId)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(periodEnd),
              )
              .get();

      final tasks =
          tasksQuery.docs.map((doc) => GrowthTask.fromFirestore(doc)).toList();
      final entries =
          journalQuery.docs
              .map((doc) => JournalEntry.fromFirestore(doc))
              .toList();

      // Calculate analytics
      final categoryProgress = <GrowthCategory, int>{};
      for (final task in tasks) {
        categoryProgress[task.category] =
            (categoryProgress[task.category] ?? 0) + 1;
      }

      final averageMoodScore =
          entries.isEmpty
              ? 5.0
              : entries.map((e) => e.moodIntensity).reduce((a, b) => a + b) /
                  entries.length;

      final profile = await getGrowthProfile();

      return GrowthAnalytics(
        userId: currentUserId!,
        periodStart: periodStart,
        periodEnd: periodEnd,
        tasksCompleted: tasks.length,
        journalEntries: entries.length,
        averageMoodScore: averageMoodScore,
        categoryProgress: categoryProgress,
        streakDays: profile.currentStreak,
        topTags: _extractTopTags(entries),
        insights: await _generateInsights(tasks, entries, profile),
        datingReadinessScore: _calculateDatingReadiness(
          profile,
          tasks,
          entries,
        ),
        weeklyActivity: _calculateWeeklyActivity(
          tasks,
          entries,
          periodStart,
          periodEnd,
        ),
      );
    } catch (e) {
      throw Exception('Failed to generate analytics: $e');
    }
  }

  // =============================================================================
  // HELPER METHODS
  // =============================================================================

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _detectEmotionalContent(String content) {
    final emotionalWords = [
      'feel',
      'feeling',
      'felt',
      'love',
      'hate',
      'angry',
      'sad',
      'happy',
      'excited',
      'nervous',
      'anxious',
      'grateful',
      'frustrated',
      'confident',
    ];

    final lowerContent = content.toLowerCase();
    return emotionalWords.any((word) => lowerContent.contains(word));
  }

  String _calculateMoodTrend(List<JournalEntry> entries) {
    if (entries.length < 2) return 'stable';

    final recentEntries = entries.take(5).toList();
    final olderEntries = entries.skip(5).take(5).toList();

    if (olderEntries.isEmpty) return 'stable';

    final recentAvg =
        recentEntries.map((e) => e.moodIntensity).reduce((a, b) => a + b) /
        recentEntries.length;

    final olderAvg =
        olderEntries.map((e) => e.moodIntensity).reduce((a, b) => a + b) /
        olderEntries.length;

    if (recentAvg > olderAvg + 1) return 'improving';
    if (recentAvg < olderAvg - 1) return 'declining';
    return 'stable';
  }

  List<String> _getTopMoods(Map<MoodType, int> moodCounts) {
    final sortedMoods =
        moodCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedMoods.take(3).map((e) => e.key.name).toList();
  }

  bool _checkAchievementRequirements(
    GrowthAchievement achievement,
    GrowthProfile profile,
  ) {
    final requirements = achievement.requirements;

    switch (achievement.id) {
      case 'first_task':
        return profile.totalTasksCompleted >= 1;
      case 'first_journal':
        return profile.totalJournalEntries >= 1;
      case 'week_streak':
        return profile.currentStreak >= 7;
      case 'growth_master':
        return profile.overallGrowthScore >= 100;
      default:
        // Generic requirement checking
        for (final entry in requirements.entries) {
          switch (entry.key) {
            case 'tasksCompleted':
              if (profile.totalTasksCompleted < entry.value) return false;
              break;
            case 'journalEntries':
              if (profile.totalJournalEntries < entry.value) return false;
              break;
            case 'streak':
              if (profile.currentStreak < entry.value) return false;
              break;
            case 'overallScore':
              if (profile.overallGrowthScore < entry.value) return false;
              break;
          }
        }
        return true;
    }
  }

  List<String> _extractTopTags(List<JournalEntry> entries) {
    final tagCounts = <String, int>{};

    for (final entry in entries) {
      for (final tag in entry.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags =
        tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(5).map((e) => e.key).toList();
  }

  Future<Map<String, dynamic>> _generateInsights(
    List<GrowthTask> tasks,
    List<JournalEntry> entries,
    GrowthProfile profile,
  ) async {
    return {
      'topPerformingCategory': _getTopCategory(tasks),
      'improvementAreas': _getImprovementAreas(profile),
      'moodPatterns': _analyzeMoodPatterns(entries),
      'growthVelocity': _calculateGrowthVelocity(profile),
      'recommendations': _generateRecommendations(profile, tasks, entries),
    };
  }

  double _calculateDatingReadiness(
    GrowthProfile profile,
    List<GrowthTask> tasks,
    List<JournalEntry> entries,
  ) {
    double score = 0;

    // Base score from overall growth
    score += (profile.overallGrowthScore / 100) * 40;

    // Recent activity bonus
    if (tasks.isNotEmpty) score += 20;
    if (entries.isNotEmpty) score += 20;

    // Streak bonus
    if (profile.currentStreak >= 7) score += 10;
    if (profile.currentStreak >= 30) score += 10;

    return score.clamp(0, 100);
  }

  Map<String, int> _calculateWeeklyActivity(
    List<GrowthTask> tasks,
    List<JournalEntry> entries,
    DateTime start,
    DateTime end,
  ) {
    final activity = <String, int>{};
    final dayDiff = end.difference(start).inDays;

    for (int i = 0; i <= dayDiff; i++) {
      final day = start.add(Duration(days: i));
      final dayKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      final dayTasks =
          tasks
              .where(
                (t) =>
                    t.completedDate != null &&
                    _isSameDay(t.completedDate!, day),
              )
              .length;
      final dayEntries =
          entries.where((e) => _isSameDay(e.createdAt, day)).length;

      activity[dayKey] = dayTasks + dayEntries;
    }

    return activity;
  }

  Future<void> _logGrowthActivity(
    String eventType,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('growth_activity_logs').add({
        'userId': currentUserId,
        'eventType': eventType,
        'data': data,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // Log silently fails - don't break user flow
      print('Failed to log growth activity: $e');
    }
  }

  String? _getTopCategory(List<GrowthTask> tasks) {
    if (tasks.isEmpty) return null;

    final categoryCounts = <GrowthCategory, int>{};
    for (final task in tasks) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }

    final topCategory = categoryCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return topCategory.key.name;
  }

  List<String> _getImprovementAreas(GrowthProfile profile) {
    return profile.categoryScores.entries
        .where((entry) => entry.value < 30)
        .map((entry) => entry.key.name)
        .take(3)
        .toList();
  }

  Map<String, dynamic> _analyzeMoodPatterns(List<JournalEntry> entries) {
    if (entries.isEmpty) return {};

    final patterns = <String, dynamic>{};
    final dayOfWeekMoods = <int, List<int>>{};

    for (final entry in entries) {
      final dayOfWeek = entry.createdAt.weekday;
      dayOfWeekMoods[dayOfWeek] ??= [];
      dayOfWeekMoods[dayOfWeek]!.add(entry.moodIntensity);
    }

    patterns['bestDayOfWeek'] =
        dayOfWeekMoods.entries
            .map(
              (e) => MapEntry(
                e.key,
                e.value.reduce((a, b) => a + b) / e.value.length,
              ),
            )
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    return patterns;
  }

  double _calculateGrowthVelocity(GrowthProfile profile) {
    final daysSinceCreation =
        DateTime.now().difference(profile.createdAt).inDays;
    return daysSinceCreation > 0
        ? profile.overallGrowthScore / daysSinceCreation
        : 0;
  }

  List<String> _generateRecommendations(
    GrowthProfile profile,
    List<GrowthTask> tasks,
    List<JournalEntry> entries,
  ) {
    final recommendations = <String>[];

    if (profile.currentStreak == 0) {
      recommendations.add('Start building a daily growth habit');
    }

    if (entries.isEmpty) {
      recommendations.add('Try journaling to track your emotional journey');
    }

    if (tasks.isEmpty) {
      recommendations.add('Complete growth tasks to build relationship skills');
    }

    final weakCategories =
        profile.categoryScores.entries
            .where((e) => e.value < 20)
            .map((e) => e.key.name)
            .toList();

    if (weakCategories.isNotEmpty) {
      recommendations.add('Focus on improving ${weakCategories.first} skills');
    }

    return recommendations;
  }

  // =============================================================================
  // STATIC DATA LIBRARIES (In production, these would be in Firestore)
  // =============================================================================

  // Fix the GrowthCategory enum mismatch in your growth_service.dart
  // Replace the task template method with this fixed version:

  List<Map<String, dynamic>> _getTaskTemplateLibrary() {
    return [
      {
        'id': 'gratitude_practice',
        'title': 'Practice Daily Gratitude 🙏',
        'description': 'Write down 3 things you\'re grateful for today',
        'detailedInstructions':
            'Take 5 minutes to reflect on your day and write down three specific things you\'re grateful for. Focus on why each one matters to you.',
        'category':
            GrowthCategory
                .emotional
                .name, // ✅ Fixed - using emotional instead of emotional
        'difficulty': TaskDifficulty.beginner.name,
        'estimatedMinutes': 5,
        'pointValue': 10,
        'tags': ['gratitude', 'mindfulness', 'emotional'],
        'encouragementMessage':
            'Gratitude is the foundation of a loving heart ❤️',
        'completionCelebration':
            'Your grateful heart is attracting more love! ✨',
      },
      {
        'id': 'active_listening',
        'title': 'Practice Active Listening 👂',
        'description':
            'Have one conversation where you focus completely on listening',
        'detailedInstructions':
            'Choose one conversation today where you will listen without planning your response. Ask follow-up questions and summarize what you heard.',
        'category': GrowthCategory.communication.name, // ✅ Correct
        'difficulty':
            TaskDifficulty
                .intermediate
                .name, // ✅ Fixed - using intermediate instead of intermediate
        'estimatedMinutes': 15,
        'pointValue': 15,
        'tags': ['listening', 'communication', 'empathy'],
        'encouragementMessage': 'Great listeners create deeper connections 💫',
        'completionCelebration':
            'You\'re becoming an amazing communicator! 🗣️',
      },
      {
        'id': 'compliment_stranger',
        'title': 'Compliment a Stranger 😊',
        'description': 'Give a genuine compliment to someone you don\'t know',
        'detailedInstructions':
            'Find an opportunity to give a sincere, appropriate compliment to a stranger. Notice how it makes both of you feel.',
        'category': GrowthCategory.social.name, // ✅ Correct
        'difficulty': TaskDifficulty.intermediate.name, // ✅ Fixed
        'estimatedMinutes': 2,
        'pointValue': 20,
        'tags': ['kindness', 'social', 'confidence'],
        'encouragementMessage':
            'Spreading joy creates a ripple effect of love 🌊',
        'completionCelebration':
            'You just made the world a little brighter! ☀️',
      },
      {
        'id': 'values_reflection',
        'title': 'Reflect on Your Core Values 🧭',
        'description': 'Identify and write about your top 3 life values',
        'detailedInstructions':
            'Spend 10 minutes reflecting on what matters most to you. Write about your top 3 values and how they guide your decisions.',
        'category': GrowthCategory.selfAwareness.name, // ✅ Correct
        'difficulty': TaskDifficulty.beginner.name, // ✅ Fixed
        'estimatedMinutes': 10,
        'pointValue': 15,
        'tags': ['values', 'self-awareness', 'reflection'],
        'encouragementMessage':
            'Knowing yourself deeply attracts the right person 🎯',
        'completionCelebration': 'Your self-awareness is your superpower! 💪',
      },
      {
        'id': 'boundary_practice',
        'title': 'Practice Setting Boundaries 🛡️',
        'description':
            'Say no to one request that doesn\'t align with your values',
        'detailedInstructions':
            'Today, when someone asks something of you, pause and check: Does this align with my values and energy? Practice saying no kindly but firmly to at least one request.',
        'category':
            GrowthCategory
                .confidence
                .name, // ✅ Using confidence for boundary work
        'difficulty': TaskDifficulty.advanced.name, // ✅ Fixed
        'estimatedMinutes': 10,
        'pointValue': 25,
        'tags': ['boundaries', 'self-care', 'assertiveness'],
        'encouragementMessage':
            'Healthy boundaries create healthy relationships! 🛡️',
        'completionCelebration':
            'You\'re learning to honor your own needs! Powerful! 💪✨',
      },
    ];
  }

  List<GrowthAchievement> _getAchievementLibrary() {
    return [
      GrowthAchievement(
        id: 'first_task',
        title: 'Growth Beginner',
        description: 'Complete your first growth task',
        emoji: '🌱',
        category: GrowthCategory.selfAwareness,
        pointValue: 50,
        requirements: {'tasksCompleted': 1},
        isSecret: false,
        rarity: 1,
        celebrationMessage: 'Every journey begins with a single step! 🚀',
      ),
      GrowthAchievement(
        id: 'first_journal',
        title: 'Heart Opener',
        description: 'Write your first journal entry',
        emoji: '📝',
        category: GrowthCategory.emotional,
        pointValue: 50,
        requirements: {'journalEntries': 1},
        isSecret: false,
        rarity: 1,
        celebrationMessage: 'You\'ve opened your heart to growth! 💖',
      ),
      GrowthAchievement(
        id: 'week_streak',
        title: 'Dedicated Soul',
        description: 'Maintain a 7-day growth streak',
        emoji: '🔥',
        category: GrowthCategory.selfAwareness,
        pointValue: 100,
        requirements: {'streak': 7},
        isSecret: false,
        rarity: 2,
        celebrationMessage: 'Your dedication is inspiring! Keep going! 🌟',
      ),
      GrowthAchievement(
        id: 'communication_master',
        title: 'Communication Champion',
        description: 'Complete 10 communication tasks',
        emoji: '💬',
        category: GrowthCategory.communication,
        pointValue: 200,
        requirements: {
          'categoryTasks': {'communication': 10},
        },
        isSecret: false,
        rarity: 3,
        celebrationMessage: 'You\'re becoming a master communicator! 🎭',
      ),
      GrowthAchievement(
        id: 'growth_master',
        title: 'Love Magnet',
        description: 'Reach 1000 growth points',
        emoji: '🧲',
        category: GrowthCategory.selfAwareness,
        pointValue: 500,
        requirements: {'overallScore': 1000},
        isSecret: true,
        rarity: 5,
        celebrationMessage: 'You\'ve become a true love magnet! 💫✨',
      ),
    ];
  }
}
