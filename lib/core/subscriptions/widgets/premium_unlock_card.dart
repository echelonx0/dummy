// lib/features/dashboard/widgets/premium_unlock_card.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_colors.dart';
import '../../models/user_insights.dart';
import '../../../features/insights/screens/premium_insights_dashboard.dart';
import 'premium_unlock_option.dart';
import 'premium_unlock_widgets.dart';

class PremiumUnlockCard extends StatefulWidget {
  final UserInsights? userInsights;
  final String? userFirstName;

  const PremiumUnlockCard({super.key, this.userInsights, this.userFirstName});

  @override
  State<PremiumUnlockCard> createState() => _PremiumUnlockCardState();
}

class _PremiumUnlockCardState extends State<PremiumUnlockCard>
    with TickerProviderStateMixin {
  bool _hasUsedFreeView = false;
  int _referralCount = 0;
  int _communityCredits = 0;

  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _hasUsedFreeView = prefs.getBool('has_used_premium_preview') ?? false;
      _referralCount = prefs.getInt('referral_count') ?? 0;
      _communityCredits = prefs.getInt('community_credits') ?? 0;
    });
  }

  Future<void> _markFreeViewUsed() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_used_premium_preview', true);

    if (!mounted) return;
    setState(() {
      _hasUsedFreeView = true;
    });
  }

  bool get _canAccessPremium {
    return !_hasUsedFreeView || _referralCount >= 3 || _communityCredits >= 50;
  }

  void _handlePremiumAccess() {
    if (!mounted) return;

    if (!_canAccessPremium) {
      _showUpgradeModal();
      return;
    }

    if (!_hasUsedFreeView) {
      _markFreeViewUsed();
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PremiumInsightsDashboard(
                  userInsights: widget.userInsights!,
                  userFirstName: widget.userFirstName,
                ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.elasticOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _showUpgradeModal() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => PremiumUpgradeModal(
            referralCount: _referralCount,
            communityCredits: _communityCredits,
            onSubscribe: () => _handleSubscription(context),
            onInviteFriends: () => _handleInviteFriends(context),
            onEarnCredits: () => _handleEarnCredits(context),
          ),
    );
  }

  // ✅ FIXED: Pass context explicitly and handle safely
  void _handleSubscription(BuildContext modalContext) {
    if (!mounted) return;

    Navigator.pop(modalContext);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Subscription coming soon! 💎'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }

  void _handleInviteFriends(BuildContext modalContext) {
    if (!mounted) return;

    Navigator.pop(modalContext);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Referral system launching soon! 👥\nCurrent referrals: $_referralCount/3',
        ),
        backgroundColor: AppColors.primarySageGreen,
      ),
    );
  }

  void _handleEarnCredits(BuildContext modalContext) {
    if (!mounted) return;

    Navigator.pop(modalContext);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Community Credits: $_communityCredits/50 ⭐\nCommunity Exchange launching soon!',
        ),
        backgroundColor: AppColors.primaryGold,
        action: SnackBarAction(
          label: 'Learn More',
          textColor: AppColors.primarySageGreen,
          onPressed: () => _showCommunityCreditsInfo(),
        ),
      ),
    );
  }

  // ✅ FIXED: Simplified context handling
  void _showCommunityCreditsInfo() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => CommunityCreditsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userInsights == null || !widget.userInsights!.hasEnhancedData) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value.clamp(0.0, 1.0);
        final shimmerValue = _shimmerController.value.clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Main Card
              Container(
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
                    color: AppColors.primaryGold.withValues(
                      alpha: (0.3 + (0.3 * pulseValue)).clamp(0.0, 1.0),
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(
                        alpha: (0.1 + (0.2 * pulseValue)).clamp(0.0, 1.0),
                      ),
                      blurRadius: 20 + (10 * pulseValue),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Shimmer Effect
                      PremiumShimmerEffect(
                        controller: _shimmerController,
                        shimmerValue: shimmerValue,
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            PremiumCardHeader(
                              hasUsedFreeView: _hasUsedFreeView,
                            ),

                            const SizedBox(height: 16),

                            // Preview Content
                            PremiumPreviewContent(
                              userInsights: widget.userInsights!,
                            ),

                            const SizedBox(height: 20),

                            // Action Button
                            PremiumActionButton(
                              canAccessPremium: _canAccessPremium,
                              hasUsedFreeView: _hasUsedFreeView,
                              referralCount: _referralCount,
                              communityCredits: _communityCredits,
                              onPressed: _handlePremiumAccess,
                            ),

                            // Progress Indicators
                            if (!_canAccessPremium) ...[
                              const SizedBox(height: 16),
                              PremiumProgressIndicators(
                                referralCount: _referralCount,
                                communityCredits: _communityCredits,
                              ),
                            ],
                          ],
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
}

// ==========================================================================
// PREMIUM UPGRADE MODAL - SIMPLIFIED
// ==========================================================================

class PremiumUpgradeModal extends StatelessWidget {
  final int referralCount;
  final int communityCredits;
  final VoidCallback onSubscribe;
  final VoidCallback onInviteFriends;
  final VoidCallback onEarnCredits;

  const PremiumUpgradeModal({
    super.key,
    required this.referralCount,
    required this.communityCredits,
    required this.onSubscribe,
    required this.onInviteFriends,
    required this.onEarnCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            PremiumModalHeader(),

            const SizedBox(height: 32),

            // Unlock Options
            Expanded(
              child: Column(
                children: [
                  PremiumUnlockOption(
                    icon: Icons.diamond,
                    title: 'Premium Subscription',
                    subtitle: 'Full access to all features',
                    price: '\$99/month',
                    color: const Color(0xFFFFD8D8),
                    onTap: onSubscribe,
                    isRecommended: true,
                  ),

                  const SizedBox(height: 16),

                  PremiumUnlockOption(
                    icon: Icons.people,
                    title: 'Invite 3 Friends',
                    subtitle: 'Free premium when they complete profiles',
                    progress: '$referralCount/3 invited',
                    color: AppColors.primarySageGreen,
                    onTap: onInviteFriends,
                  ),

                  const SizedBox(height: 16),

                  PremiumUnlockOption(
                    icon: Icons.volunteer_activism,
                    title: 'Community Credits',
                    subtitle: 'Earn through community service',
                    progress: '$communityCredits/50 credits',
                    color: AppColors.primaryAccent,
                    onTap: onEarnCredits,
                    badge: 'Coming Soon',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
