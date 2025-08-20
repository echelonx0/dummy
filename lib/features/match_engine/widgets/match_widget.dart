// ===============================================================
// MATCH ENGINE SCREEN - IMPLEMENTATION EXAMPLE
// lib/features/match_engine/screens/match_engine_screen.dart
// ===============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/shared/widgets/action_modal_widget.dart';
import '../controllers/match_controller.dart';
import '../widgets/match_card.dart';

class MatchEngineScreen extends StatefulWidget {
  const MatchEngineScreen({super.key});

  @override
  State<MatchEngineScreen> createState() => _MatchEngineScreenState();
}

class _MatchEngineScreenState extends State<MatchEngineScreen> {
  late MatchEngineController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MatchEngineController();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    await _controller.loadMatches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleMatchTap() {
    final match = _controller.currentMatch;
    if (match != null) {
      // Navigate to detailed profile view
      Navigator.pushNamed(context, '/match-profile', arguments: match);
    }
  }

  void _handleInterested() async {
    final success = await _controller.expressInterest();

    if (success && mounted) {
      // Check if it was a mutual match
      // This could be handled through the controller's state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Interest expressed! 💖',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
            ),
          ),
          backgroundColor: AppColors.primarySageGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _handleNotInterested() async {
    final success = await _controller.expressNoInterest();

    if (success && mounted) {
      // Subtle feedback for "not interested"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Response recorded',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          ),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showNoMoreMatches() {
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.center,
      data: ActionModalData(
        headline: 'You\'re All Caught Up! ✨',
        subheadline:
            'We\'re finding more compatible matches for you. Check back soon or adjust your preferences.',
        ctaText: 'Update Preferences',
        onAction: () {
          Navigator.pushNamed(context, '/preferences');
        },
        backgroundColor: AppColors.primarySageGreen,
        accentColor: AppColors.primaryAccent,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primarySageGreen),
          const SizedBox(height: 16),
          Text(
            'Finding your matches...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMatches,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySageGreen,
              foregroundColor: AppColors.primaryAccent,
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.primarySageGreen.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No more matches right now',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re working on finding more compatible people for you!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showNoMoreMatches,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySageGreen,
              foregroundColor: AppColors.primaryAccent,
            ),
            child: Text('Update Preferences'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Discover Matches',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _loadMatches,
              icon: Icon(Icons.refresh, color: AppColors.primarySageGreen),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<MatchEngineController>(
          builder: (context, controller, child) {
            // Loading state
            if (controller.isLoading && controller.matches.isEmpty) {
              return _buildLoadingState();
            }

            // Error state
            if (controller.error != null) {
              return _buildErrorState(controller.error!);
            }

            // Empty state
            if (controller.matches.isEmpty) {
              return _buildEmptyState();
            }

            // No current match (all viewed)
            if (controller.currentMatch == null) {
              return _buildEmptyState();
            }

            final match = controller.currentMatch!;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Match counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      '${controller.currentMatchIndex + 1} of ${controller.matches.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primarySageGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Match card
                  Expanded(
                    child: MatchCard(
                      name: match.name,
                      age: match.age,
                      imageUrl: match.profileImageUrl ?? '',
                      compatibility: match.compatibilityScore,
                      sharedValues: match.sharedValues,
                      profession: match.profession,
                      bio: match.bio,
                      onTap: _handleMatchTap,
                      onInterested: _handleInterested,
                      onNotInterested: _handleNotInterested,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress indicator
                  if (controller.matches.length > 1)
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (controller.currentMatchIndex + 1) /
                            controller.matches.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primarySageGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===============================================================
// USAGE EXAMPLE WITH PROVIDER SETUP
// lib/main.dart (relevant section)
// ===============================================================

/*
void main() {
  runApp(
    MultiProvider(
      providers: [
        // ... other providers
        ChangeNotifierProvider(
          create: (_) => MatchEngineController(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
*/

// ===============================================================
// STANDALONE USAGE EXAMPLE
// For when you want to use MatchCard outside of the full screen
// ===============================================================

class MatchCardUsageExample extends StatelessWidget {
  const MatchCardUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MatchCard(
      name: "Sarah Johnson",
      age: 28,
      imageUrl: "https://example.com/profile.jpg",
      compatibility: 87,
      sharedValues: ["Family values", "Adventure", "Personal growth"],
      profession: "Marketing Manager",
      bio:
          "I'm passionate about building meaningful connections and exploring the world. Love hiking, reading, and cooking with friends.",
      onTap: () {
        // Handle card tap - show full profile
        print("Match card tapped");
      },
      onInterested: () {
        // Handle interested action
        print("User is interested");
      },
      onNotInterested: () {
        // Handle not interested action
        print("User is not interested");
      },
    );
  }
}
