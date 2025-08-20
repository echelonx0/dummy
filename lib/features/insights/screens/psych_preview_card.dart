// lib/features/dashboard/widgets/psychological_insights_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/user_insights.dart';
import '../../../core/utils/text_personalization_utility.dart';

class PsychologicalInsightsWidget extends StatefulWidget {
  final UserInsights? userInsights;
  final String? userFirstName;

  const PsychologicalInsightsWidget({
    super.key,
    this.userInsights,
    this.userFirstName,
  });

  @override
  State<PsychologicalInsightsWidget> createState() =>
      _PsychologicalInsightsWidgetState();
}

class _PsychologicalInsightsWidgetState
    extends State<PsychologicalInsightsWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _floatingController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;

  int? _expandedSection;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show widget if no insights data
    if (widget.userInsights == null || !widget.userInsights!.hasData) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              _buildBackgroundGradient(),
              _buildFloatingElements(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardBackground,
                AppColors.primaryGold,
                AppColors.backgroundDark,
                AppColors.cardBackground,
              ],
              stops: [
                0.0,
                0.3 + (_breathingAnimation.value * 0.05),
                0.7 + (_breathingAnimation.value * 0.05),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 20 + _floatingAnimation.value,
              right: 25,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: AppColors.primarySageGreen.withValues(alpha: 0.7),
                  size: 16,
                ),
              ),
            ),
            Positioned(
              bottom: 30 - _floatingAnimation.value,
              left: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 80 + (_floatingAnimation.value * 0.3),
              right: 15,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPsychologicalInsights(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySageGreen.withValues(alpha: 0.8),
                AppColors.primaryGold.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.primaryAccent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Psychological Insights',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                'Understanding your personality patterns',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPsychologicalInsights() {
    final insights = _generateInsightsFromData();

    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textMedium.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Psychological insights will appear here once your profile analysis is complete.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children:
          insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            final isExpanded = _expandedSection == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: insight.color.withValues(
                    alpha: isExpanded ? 0.3 : 0.2,
                  ),
                  width: 1,
                ),
              ),
              child: Material(
                color: AppColors.backgroundDark,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _expandedSection = isExpanded ? null : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(insight.icon, color: insight.color, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insight.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: insight.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: insight.color.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          insight.summary,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDark,
                            fontSize: 13,
                          ),
                        ),
                        if (isExpanded &&
                            insight.expandedDetail.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: insight.color.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              insight.expandedDetail,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMedium,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  List<PsychologicalInsight> _generateInsightsFromData() {
    final insights = <PsychologicalInsight>[];
    final userInsights = widget.userInsights!;

    // Communication Style Insight
    if (userInsights.communicationStyle != null) {
      insights.add(
        PsychologicalInsight(
          title:
              userInsights.communicationStyle!['title'] ??
              'Communication Style',
          summary: _personalizeText(
            userInsights.communicationStyle!['description'] ??
                'Your communication patterns',
          ),
          expandedDetail: _personalizeText(
            userInsights.communicationStyle!['details'] ?? '',
          ),
          icon: Icons.chat_outlined,
          color: AppColors.primarySageGreen,
        ),
      );
    }

    // Emotional Intelligence Insight
    if (userInsights.emotionalIntelligence != null) {
      insights.add(
        PsychologicalInsight(
          title:
              userInsights.emotionalIntelligence!['title'] ??
              'Emotional Intelligence',
          summary: _personalizeText(
            userInsights.emotionalIntelligence!['description'] ??
                'Your emotional awareness patterns',
          ),
          expandedDetail: _personalizeText(
            userInsights.emotionalIntelligence!['details'] ?? '',
          ),
          icon: Icons.favorite_border,
          color: AppColors.cream,
        ),
      );
    }

    // Relationship Patterns Insight
    if (userInsights.relationshipPatterns != null) {
      insights.add(
        PsychologicalInsight(
          title:
              userInsights.relationshipPatterns!['title'] ??
              'Relationship Patterns',
          summary: _personalizeText(
            userInsights.relationshipPatterns!['description'] ??
                'Your relationship approach',
          ),
          expandedDetail: _personalizeText(
            userInsights.relationshipPatterns!['details'] ?? '',
          ),
          icon: Icons.psychology_outlined,
          color: AppColors.primaryAccent,
        ),
      );
    }

    // Intellectual Assessment Insight
    if (userInsights.intellectualAssessment != null) {
      final assessment = userInsights.intellectualAssessment!;
      insights.add(
        PsychologicalInsight(
          title: 'Intellectual Profile',
          summary: _personalizeText(
            'Estimated IQ: ${assessment.estimatedIQ} (${assessment.iqRange})',
          ),
          expandedDetail: _personalizeText(
            '${assessment.reasoning}\n\nCognitive strengths: ${assessment.cognitiveStrengths.join(', ')}',
          ),
          icon: Icons.lightbulb_outlined,
          color: AppColors.primarySageGreen,
        ),
      );
    }

    // Gender Traits Analysis Insight
    if (userInsights.genderTraitsAnalysis != null) {
      final analysis = userInsights.genderTraitsAnalysis!;
      insights.add(
        PsychologicalInsight(
          title: 'Trait Expression',
          summary: _personalizeText(analysis.expressionStyle),
          expandedDetail: _personalizeText(analysis.balanceAssessment),
          icon: Icons.balance_outlined,
          color: AppColors.cream,
        ),
      );
    }

    // Astrological Profile Insight
    if (userInsights.astrologicalProfile != null) {
      final astro = userInsights.astrologicalProfile!;
      insights.add(
        PsychologicalInsight(
          title: 'Astrological Pattern',
          summary: _personalizeText(
            '${astro.fullAstroDescription} ${astro.isEstimated ? '(estimated)' : ''}',
          ),
          expandedDetail: _personalizeText(
            astro.relationshipAstrology.loveLanguageConnection,
          ),
          icon: Icons.stars_outlined,
          color: AppColors.primaryAccent,
        ),
      );
    }

    // Use top strengths if no enhanced data
    if (insights.isEmpty && userInsights.strengths.isNotEmpty) {
      final topStrengths = userInsights.strengths.take(3);
      for (final strength in topStrengths) {
        insights.add(
          PsychologicalInsight(
            title: strength['title'] ?? 'Strength',
            summary: _personalizeText(strength['description'] ?? ''),
            expandedDetail: _personalizeText(strength['details'] ?? ''),
            icon: Icons.star_outline,
            color: AppColors.primarySageGreen,
          ),
        );
      }
    }

    return insights;
  }

  String _personalizeText(String text) {
    if (text.isEmpty) return text;
    return TextPersonalizationUtils.personalizeInsightText(
      text,
      userName: widget.userFirstName,
    );
  }
}

class PsychologicalInsight {
  final String title;
  final String summary;
  final String expandedDetail;
  final IconData icon;
  final Color color;

  PsychologicalInsight({
    required this.title,
    required this.summary,
    required this.expandedDetail,
    required this.icon,
    required this.color,
  });
}
