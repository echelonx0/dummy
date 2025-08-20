// lib/features/premium_insights/screens/premium_insights_dashboard.dart

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/user_insights.dart';

class PremiumInsightsDashboard extends StatelessWidget {
  final UserInsights userInsights;
  final String? userFirstName;

  const PremiumInsightsDashboard({
    super.key,
    required this.userInsights,
    this.userFirstName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primarySageGreen,
                      AppColors.primaryGold,
                      AppColors.primarySageGreen.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.psychology,
                                color: AppColors.backgroundDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PREMIUM',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deep Psychological Insights',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userInsights.personaDisplayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryAccent.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Premium Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Intellectual Assessment
                if (userInsights.intellectualAssessment != null)
                  PremiumCard(
                    delay: 0,
                    child: IntellectualAssessmentCard(
                      assessment: userInsights.intellectualAssessment!,
                    ),
                  ),

                const SizedBox(height: 16),

                // Astrological Profile
                if (userInsights.astrologicalProfile != null)
                  PremiumCard(
                    delay: 200,
                    child: AstrologicalProfileCard(
                      profile: userInsights.astrologicalProfile!,
                    ),
                  ),

                const SizedBox(height: 16),

                // Gender Traits Analysis
                if (userInsights.genderTraitsAnalysis != null)
                  PremiumCard(
                    delay: 400,
                    child: GenderTraitsCard(
                      analysis: userInsights.genderTraitsAnalysis!,
                    ),
                  ),

                const SizedBox(height: 16),

                // Communication & Emotional Intelligence
                Row(
                  children: [
                    if (userInsights.communicationStyle != null)
                      Expanded(
                        child: PremiumCard(
                          delay: 600,
                          child: CommunicationStyleCard(
                            style: userInsights.communicationStyle!,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    if (userInsights.emotionalIntelligence != null)
                      Expanded(
                        child: PremiumCard(
                          delay: 700,
                          child: EmotionalIntelligenceCard(
                            intelligence: userInsights.emotionalIntelligence!,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Relationship Patterns
                if (userInsights.relationshipPatterns != null)
                  PremiumCard(
                    delay: 800,
                    child: RelationshipPatternsCard(
                      patterns: userInsights.relationshipPatterns!,
                    ),
                  ),

                const SizedBox(height: 16),

                // Compatibility Indicators
                if (userInsights.compatibilityIndicators != null)
                  PremiumCard(
                    delay: 900,
                    child: CompatibilityIndicatorsCard(
                      indicators: userInsights.compatibilityIndicators!,
                    ),
                  ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// PREMIUM CARD WRAPPER
// ==========================================================================

class PremiumCard extends StatelessWidget {
  final int delay;
  final Widget child;

  const PremiumCard({
    super.key,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardBackground,
                    AppColors.cardBackground.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.primaryGold.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================================
// INTELLECTUAL ASSESSMENT CARD
// ==========================================================================

class IntellectualAssessmentCard extends StatelessWidget {
  final IntellectualProfile assessment;

  const IntellectualAssessmentCard({
    super.key,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          icon: Icons.psychology_outlined,
          title: 'Intellectual Assessment 🧠',
          subtitle: 'Cognitive Profile Analysis',
        ),

        const SizedBox(height: 20),

        // IQ Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen.withValues(alpha: 0.1),
                AppColors.primaryGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 6,
                percent: (assessment.estimatedIQ - 70) / 70, // Scale 70-140
                center: Text(
                  '${assessment.estimatedIQ}',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primarySageGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: AppColors.primarySageGreen,
                backgroundColor: AppColors.primarySageGreen.withValues(alpha: 0.2),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.iqRange,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primarySageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      assessment.confidenceDescription,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cognitive Strengths
        Text(
          'Cognitive Strengths',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: assessment.cognitiveStrengths.map((strength) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                strength,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Analysis Quality
        Text(
          'Thinking Patterns',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          assessment.analysisQuality,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

// ==========================================================================
// ASTROLOGICAL PROFILE CARD
// ==========================================================================

class AstrologicalProfileCard extends StatelessWidget {
  final AstrologicalProfile profile;

  const AstrologicalProfileCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          icon: Icons.auto_awesome,
          title: 'Astrological Profile ✨',
          subtitle: profile.fullAstroDescription,
        ),

        const SizedBox(height: 20),

        // Big Three
        Row(
          children: [
            _buildSignCard(
              '☀️',
              'Sun',
              profile.birthDetails.sunSign,
              'Core Self',
              AppColors.primaryGold,
            ),
            const SizedBox(width: 12),
            _buildSignCard(
              '🌙',
              'Moon',
              profile.birthDetails.moonSign,
              'Emotions',
              AppColors.primarySageGreen,
            ),
            const SizedBox(width: 12),
            _buildSignCard(
              '⬆️',
              'Rising',
              profile.birthDetails.risingSign,
              'Presentation',
              AppColors.primaryAccent,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Relationship Astrology
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGold.withValues(alpha: 0.1),
                AppColors.primarySageGreen.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Love & Relationships 💕',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile.relationshipAstrology.loveLanguageConnection,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignCard(String emoji, String type, String sign, String meaning, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sign,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              meaning,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// GENDER TRAITS CARD
// ==========================================================================

class GenderTraitsCard extends StatelessWidget {
  final GenderTraitsAnalysis analysis;

  const GenderTraitsCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          icon: Icons.balance_outlined,
          title: 'Trait Expression ⚖️',
          subtitle: 'Masculine & Feminine Energies',
        ),

        const SizedBox(height: 20),

        // Balance Assessment
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen.withValues(alpha: 0.1),
                AppColors.primaryGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Balance',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primarySageGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.balanceAssessment,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Trait Lists
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (analysis.masculineTraits.isNotEmpty)
              Expanded(
                child: _buildTraitsList(
                  'Masculine Traits',
                  analysis.masculineTraits,
                  AppColors.primarySageGreen,
                ),
              ),
            const SizedBox(width: 16),
            if (analysis.feminineTraits.isNotEmpty)
              Expanded(
                child: _buildTraitsList(
                  'Feminine Traits',
                  analysis.feminineTraits,
                  AppColors.primaryGold,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTraitsList(String title, List<TraitExpression> traits, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...traits.take(3).map((trait) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trait.trait,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trait.manifestation,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// COMMUNICATION STYLE CARD
// ==========================================================================

class CommunicationStyleCard extends StatelessWidget {
  final Map<String, String> style;

  const CommunicationStyleCard({
    super.key,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySageGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_outlined,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                style['title'] ?? 'Communication',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primarySageGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          style['description'] ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

// ==========================================================================
// EMOTIONAL INTELLIGENCE CARD
// ==========================================================================

class EmotionalIntelligenceCard extends StatelessWidget {
  final Map<String, String> intelligence;

  const EmotionalIntelligenceCard({
    super.key,
    required this.intelligence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite_outline,
                color: AppColors.backgroundDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                intelligence['title'] ?? 'Emotional IQ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          intelligence['description'] ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

// ==========================================================================
// RELATIONSHIP PATTERNS CARD
// ==========================================================================

class RelationshipPatternsCard extends StatelessWidget {
  final Map<String, String> patterns;

  const RelationshipPatternsCard({
    super.key,
    required this.patterns,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          icon: Icons.timeline_outlined,
          title: patterns['title'] ?? 'Relationship Patterns 💕',
          subtitle: 'Your Connection Style',
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryAccent.withValues(alpha: 0.1),
                AppColors.primaryGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            patterns['description'] ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// COMPATIBILITY INDICATORS CARD
// ==========================================================================

class CompatibilityIndicatorsCard extends StatelessWidget {
  final List<Map<String, String>> indicators;

  const CompatibilityIndicatorsCard({
    super.key,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumSectionHeader(
          icon: Icons.favorite_border,
          title: 'Compatibility Factors 💖',
          subtitle: 'What Makes You Compatible',
        ),

        const SizedBox(height: 16),

        ...indicators.take(3).map((indicator) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.1),
                  AppColors.primarySageGreen.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator['title'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  indicator['description'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// PREMIUM SECTION HEADER
// ==========================================================================

class PremiumSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const PremiumSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold,
                    AppColors.primarySageGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.backgroundDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
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
}