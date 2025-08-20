// lib/features/main/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../generated/l10n.dart';
import '../features/account/screens/user_profile_screen.dart';
import '../features/courtship/screens/courtship_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Subtle pulse for courtship tab when it's active
    if (_currentIndex == 1) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.mediumImpact();
      setState(() {
        _currentIndex = index;
      });

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );

      // Trigger scale animation
      _animationController.reset();
      _animationController.forward();

      // Control pulse animation for courtship tab
      if (index == 1) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      extendBody: true, // Let body extend behind bottom nav for better design
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Control pulse animation
          if (index == 1) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }
        },
        children: const [
          DashboardScreen(),
          CourtshipHubScreen(),
          ProfileManagementScreen(),
        ],
      ),
      bottomNavigationBar: _buildRomanticBottomNav(l10n),
    );
  }

  Widget _buildRomanticBottomNav(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // Fix: Use proper dark theme colors instead of actionCardGradient
        color: AppColors.backgroundDark, // Dark charcoal background
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Unfold',
                color: AppColors.primaryAccent, // Cream color
              ),
              _buildCourtshipNavItem(),
              _buildNavItem(
                index: 2,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                color: AppColors.primaryAccent, // Cream color
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourtshipNavItem() {
    final isActive = _currentIndex == 1;

    return GestureDetector(
      onTap: () => _onTabTapped(1),
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _pulseController]),
        builder: (context, child) {
          final scale = isActive ? _scaleAnimation.value : 1.0;
          final pulse = isActive ? _pulseAnimation.value : 1.0;

          return Transform.scale(
            scale: scale * pulse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                // Fix: Better gradient for active courtship tab
                gradient:
                    isActive
                        ? LinearGradient(
                          colors: [
                            AppColors.primarySageGreen, // Bronze
                            AppColors.primaryGold, // Medium charcoal
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: AppColors.primarySageGreen.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heart icon with special treatment
                  Stack(
                    children: [
                      Icon(
                        isActive
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color:
                            isActive
                                ? AppColors
                                    .primaryAccent // Cream on bronze
                                : AppColors.textMedium,
                        size: 30,
                      ),
                      // Subtle glow effect when active
                      if (isActive)
                        Positioned.fill(
                          child: Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primaryAccent.withValues(
                              alpha: 0.3,
                            ),
                            size: 34,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isActive
                              ? AppColors
                                  .primaryAccent // Cream on bronze
                              : AppColors.textMedium,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                      shadows:
                          isActive
                              ? [
                                Shadow(
                                  color: AppColors.primarySageGreen.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color color,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = isActive ? _scaleAnimation.value : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                // Fix: Use consistent bronze accent for active state
                color:
                    isActive
                        ? AppColors.primarySageGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border:
                    isActive
                        ? Border.all(
                          color: AppColors.primarySageGreen.withValues(
                            alpha: 0.3,
                          ),
                          width: 1.5,
                        )
                        : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color:
                        isActive
                            ? AppColors
                                .primarySageGreen // Bronze when active
                            : AppColors.textMedium,
                    size: 26,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          isActive
                              ? AppColors
                                  .primarySageGreen // Bronze when active
                              : AppColors.textMedium,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
