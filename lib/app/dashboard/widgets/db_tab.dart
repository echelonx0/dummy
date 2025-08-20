// lib/shared/widgets/premium_tab_bar.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class PremiumTabBar extends StatelessWidget {
  final TabController tabController;
  final List<PremiumTab> tabs;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;

  // Accent Colors
  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);

  const PremiumTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.primaryColor,
    this.secondaryColor,
    this.borderRadius = 25.0,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor ?? _coralPink,
              secondaryColor ?? _electricBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (primaryColor ?? _coralPink).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        padding: padding,
        tabs: tabs.map((premiumTab) => _buildTab(premiumTab)).toList(),
      ),
    );
  }

  Widget _buildTab(PremiumTab premiumTab) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (premiumTab.icon != null) ...[
            Icon(premiumTab.icon, size: premiumTab.iconSize),
            if (premiumTab.text.isNotEmpty) const SizedBox(width: 8),
          ],
          if (premiumTab.text.isNotEmpty)
            Text(premiumTab.text, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (premiumTab.badge != null) ...[
            const SizedBox(width: 8),
            premiumTab.badge!,
          ],
        ],
      ),
    );
  }
}

class PremiumTab {
  final String text;
  final IconData? icon;
  final double iconSize;
  final Widget? badge;

  const PremiumTab({
    required this.text,
    this.icon,
    this.iconSize = 20.0,
    this.badge,
  });

  // Convenient constructors for common tab types
  static PremiumTab tabtext(String text) {
    return PremiumTab(text: text);
  }

  static PremiumTab iconText(
    IconData icon,
    String text, {
    double iconSize = 20.0,
  }) {
    return PremiumTab(text: text, icon: icon, iconSize: iconSize);
  }

  static PremiumTab iconOnly(IconData icon, {double iconSize = 24.0}) {
    return PremiumTab(text: '', icon: icon, iconSize: iconSize);
  }

  static PremiumTab withBadge(String text, Widget badge, {IconData? icon}) {
    return PremiumTab(text: text, icon: icon, badge: badge);
  }
}

// Extension for easy badge creation
extension PremiumTabBadge on Widget {
  static Widget notification(int count, {Color? backgroundColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget dot({Color? color}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget premium() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE66D), Color(0xFFFF6B9D)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Example usage widget demonstrating different configurations
class PremiumTabBarExample extends StatefulWidget {
  const PremiumTabBarExample({super.key});

  @override
  State<PremiumTabBarExample> createState() => _PremiumTabBarExampleState();
}

class _PremiumTabBarExampleState extends State<PremiumTabBarExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Basic Tab Bar
            PremiumTabBar(
              tabController: _tabController,
              tabs: [
                PremiumTab.iconText(Icons.insights_outlined, 'Insights'),
                PremiumTab.iconText(Icons.trending_up_outlined, 'Growth'),
              ],
            ),

            // Tab Bar with Badges
            PremiumTabBar(
              tabController: _tabController,
              tabs: [
                PremiumTab.withBadge(
                  'Messages',
                  PremiumTabBadge.notification(3),
                  icon: Icons.message_outlined,
                ),
                PremiumTab.withBadge(
                  'Premium',
                  PremiumTabBadge.premium(),
                  icon: Icons.star_outline,
                ),
              ],
              primaryColor: const Color(0xFF6366F1),
              secondaryColor: const Color(0xFF8B5CF6),
            ),

            // Custom Colors Tab Bar
            PremiumTabBar(
              tabController: _tabController,
              tabs: [
                PremiumTab.iconText(Icons.home_outlined, 'Home'),
                PremiumTab.iconText(Icons.explore_outlined, 'Explore'),
              ],
              primaryColor: const Color(0xFF10B981),
              secondaryColor: const Color(0xFF06B6D4),
              borderRadius: 20,
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const Center(child: Text('Tab 1 Content')),
                  const Center(child: Text('Tab 2 Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
