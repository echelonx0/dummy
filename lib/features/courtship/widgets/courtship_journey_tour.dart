// ===============================================================
// COURTSHIP JOURNEY TOUR WIDGET
// lib/features/courtship/widgets/courtship_journey_tour.dart
// ===============================================================

import 'package:flutter/material.dart';

import 'package:delayed_display/delayed_display.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class CourtshipJourneyTour extends StatefulWidget {
  final VoidCallback? onStartJourney;
  final VoidCallback? onLearnMore;

  const CourtshipJourneyTour({
    super.key,
    this.onStartJourney,
    this.onLearnMore,
  });

  @override
  State<CourtshipJourneyTour> createState() => _CourtshipJourneyTourState();
}

class _CourtshipJourneyTourState extends State<CourtshipJourneyTour>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundLight, AppColors.backgroundDark],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'How our process works',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primarySageGreen.withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primarySageGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: AppColors.primaryAccent,
              unselectedLabelColor: AppColors.textMedium,
              labelStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              unselectedLabelStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Process'),
                Tab(text: 'AI Guide'),
                Tab(text: 'Rules'),
              ],
            ),
          ),

          // Tab Content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProcessTab(),
                _buildAIGuideTab(),
                _buildRulesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'We are Different by Design',
              Icons.auto_awesome,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              'No More Swiping',
              'AI analyzes deep psychological compatibility instead of photos',
              Icons.psychology,
              AppColors.primarySageGreen,
            ),
            _buildFeatureCard(
              'Meaningful Connections',
              'Guided conversations focus on values, goals, and authentic connection',
              Icons.connect_without_contact,
              AppColors.primaryAccent,
            ),
            _buildFeatureCard(
              'Quality Over Quantity',
              'One carefully matched person at a time for 14 focused days',
              Icons.diamond,
              AppColors.primaryGold,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Your Journey Timeline', Icons.timeline),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Days 1-3',
              'Introduction & Values',
              'Share core values and build initial connection through AI-guided conversations',
            ),
            _buildTimelineItem(
              'Days 4-7',
              'Deeper Discovery',
              'Explore lifestyle, communication styles, and emotional connection',
            ),
            _buildTimelineItem(
              'Days 8-11',
              'First Meeting',
              'AI plans your perfect first date based on shared interests',
            ),
            _buildTimelineItem(
              'Days 12-14',
              'Connection Decision',
              'Decide together if you want to continue the relationship',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessTab() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('How AI Mediation Works', Icons.smart_toy),
            const SizedBox(height: 16),
            _buildProcessStep(
              '1',
              'AI Analyzes Compatibility',
              'Our AI reviews both profiles and identifies shared values, complementary traits, and potential connection points.',
            ),
            _buildProcessStep(
              '2',
              'Personalized Introduction',
              'AI crafts a unique introduction highlighting why you two might be compatible, without revealing everything at once.',
            ),
            _buildProcessStep(
              '3',
              'Guided Conversations',
              'AI suggests meaningful topics and relays messages with context, helping both people share authentically.',
            ),
            _buildProcessStep(
              '4',
              'Progressive Disclosure',
              'Information is shared gradually as trust builds, mimicking how real relationships develop naturally.',
            ),
            _buildProcessStep(
              '5',
              'Date Planning',
              'AI plans your first meeting based on shared interests, location, and personality compatibility.',
            ),
            _buildProcessStep(
              '6',
              'Direct Connection',
              'Once ready, you can communicate directly while AI provides relationship guidance.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppColors.primarySageGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Human matchmakers review all conversations to ensure quality and safety',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIGuideTab() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Meet Your AI Matchmaker', Icons.psychology),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withValues(alpha: 0.1),
                    AppColors.primaryGold.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primarySageGreen,
                    child: Icon(
                      Icons.psychology,
                      color: AppColors.primaryAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your AI understands human psychology and relationship science',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildAICapability(
              'Psychological Analysis',
              'Analyzes compatibility based on attachment styles, personality types, and communication patterns',
              Icons.psychology,
            ),
            _buildAICapability(
              'Conversation Health',
              'Monitors emotional tone, engagement levels, and connection quality in real-time',
              Icons.monitor_heart,
            ),
            _buildAICapability(
              'Cultural Intelligence',
              'Understands cultural backgrounds, values, and family dynamics for better matching',
              Icons.public,
            ),
            _buildAICapability(
              'Relationship Coaching',
              'Provides personalized advice for difficult conversations and relationship growth',
              Icons.school,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transparency Promise',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll always know when AI is involved. We believe in transparent technology that enhances human connection, never replaces it.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab() {
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Courtship Guidelines', Icons.rule),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Commitment Required',
              'Both people must commit to the full 14-day journey. This ensures serious intent and protects everyone\'s time.',
              Icons.handshake,
              true,
            ),
            _buildRuleCard(
              'One Match at a Time',
              'Focus on building a genuine connection with one person rather than juggling multiple conversations.',
              Icons.power_input,
              true,
            ),
            _buildRuleCard(
              'Respectful Communication',
              'All conversations are reviewed for safety. Inappropriate behavior results in immediate removal.',
              Icons.shield,
              false,
            ),
            _buildRuleCard(
              'No Direct Contact Initially',
              'All communication goes through AI until both people are ready for direct connection (usually day 8-10).',
              Icons.security,
              true,
            ),
            _buildRuleCard(
              'Honest Participation',
              'Share authentically about yourself. The process only works when both people are genuine.',
              Icons.verified,
              true,
            ),
            _buildRuleCard(
              'Graceful Exits',
              'If it\'s not working, you can exit respectfully at any time. We\'ll help you communicate this kindly.',
              Icons.exit_to_app,
              false,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Important Boundaries',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ghosting or abandoning conversations without explanation results in a temporary suspension. We protect our community\'s emotional wellbeing.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primarySageGreen, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String timeframe,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              timeframe,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySageGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICapability(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primarySageGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
    String title,
    String description,
    IconData icon,
    bool isRequired,
  ) {
    final color =
        isRequired ? AppColors.primarySageGreen : AppColors.primaryGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Required',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
