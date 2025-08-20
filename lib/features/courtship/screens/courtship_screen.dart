// lib/features/courtship/screens/courtship_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

import '../../match_engine/widgets/match_card.dart';
import '../widgets/courtship_journey_tour.dart';

class CourtshipHubScreen extends StatefulWidget {
  const CourtshipHubScreen({super.key});

  @override
  State<CourtshipHubScreen> createState() => _CourtshipHubScreenState();
}

class _CourtshipHubScreenState extends State<CourtshipHubScreen> {
  final PageController _stagesController = PageController();
  bool _showCourtshipTour = false;
  // Dummy match data
  final List<Map<String, dynamic>> _dummyMatches = [
    {
      'name': 'Emma',
      'age': 28,
      'image':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      'compatibility': 94,
      'sharedValues': ['Adventure', 'Growth', 'Family'],
      'profession': 'Product Designer',
      'bio': 'Loves hiking, cooking, and meaningful conversations over coffee.',
    },
    {
      'name': 'Sofia',
      'age': 26,
      'image':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      'compatibility': 89,
      'sharedValues': ['Creativity', 'Travel', 'Wellness'],
      'profession': 'Marketing Manager',
      'bio': 'Passionate about art, travel, and building genuine connections.',
    },
    {
      'name': 'Lily',
      'age': 30,
      'image':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      'compatibility': 87,
      'sharedValues': ['Learning', 'Health', 'Kindness'],
      'profession': 'Teacher',
      'bio': 'Believes in lifelong learning and making a positive impact.',
    },
  ];

  @override
  void dispose() {
    _stagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 32),

              // Match Status Section
              DelayedDisplay(
                delay: const Duration(milliseconds: 600),
                child: _buildMatchStatusSection(),
              ),

              const SizedBox(height: 16),

              // Sample Matches Section
              DelayedDisplay(
                delay: const Duration(milliseconds: 400),
                child: _buildSampleMatchesSection(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Matches',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primaryButton,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full matches screen
                HapticFeedback.lightImpact();
              },
              child: Text(
                'View All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFFF6B8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Based on your compatibility analysis',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dummyMatches.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final match = _dummyMatches[index];
            return MatchCard(
              name: match['name'],
              age: match['age'],
              imageUrl: match['image'],
              compatibility: match['compatibility'],
              sharedValues: List<String>.from(match['sharedValues']),
              profession: match['profession'],
              bio: match['bio'],
              onTap: () => _handleMatchTap(match),
              onInterested: () => _handleStartCourtship(match),
              onNotInterested: () => _handleRemoveMatch(match),
            );
          },
        ),
      ],
    );
  }

  void _handleMatchTap(Map<String, dynamic> match) {
    HapticFeedback.mediumImpact();
    // TODO: Navigate to match details
    print('Match tapped: ${match['name']}');
  }

  void _handleStartCourtship(Map<String, dynamic> match) {
    HapticFeedback.heavyImpact();
    // TODO: Start courtship flow
    print('Starting courtship with: ${match['name']}');

    // Show confirmation dialog or navigate to courtship
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Start Courtship'),
            content: Text(
              'Begin a 14-day guided courtship journey with ${match['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to courtship flow
                },
                child: Text('Begin Journey'),
              ),
            ],
          ),
    );
  }

  void _handleRemoveMatch(Map<String, dynamic> match) {
    HapticFeedback.mediumImpact();
    // TODO: Remove match from list
    print('Removing match: ${match['name']}');

    setState(() {
      _dummyMatches.removeWhere((m) => m['name'] == match['name']);
    });

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match['name']} removed from matches'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _dummyMatches.add(match);
            });
          },
        ),
      ),
    );
  }

  // Replace the _buildMatchStatusSection method:
  Widget _buildMatchStatusSection() {
    if (_showCourtshipTour) {
      return Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showCourtshipTour = false;
                });
              },
              icon: Icon(Icons.close, color: AppColors.textMedium),
            ),
          ),
          // Tour widget with fixed height
          SizedBox(
            height: 600,
            child: CourtshipJourneyTour(
              onStartJourney: () {
                // Handle start journey
                setState(() {
                  _showCourtshipTour = false;
                });
              },
              onLearnMore: () {
                // Handle learn more
              },
            ),
          ),
        ],
      );
    }

    // Default: Show a simple CTA button
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primarySageGreen.withValues(alpha: 0.1),
            AppColors.primaryAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, size: 48, color: AppColors.primarySageGreen),
          const SizedBox(height: 16),
          Text(
            'Ready for Meaningful Connections?',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Experience AI-guided courtship designed for lasting relationships',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showCourtshipTour = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySageGreen,
              foregroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Learn How It Works',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
