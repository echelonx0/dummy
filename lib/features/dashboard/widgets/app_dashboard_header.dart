// lib/features/dashboard/widgets/enhanced_dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_text_styles.dart';

class EnhancedDashboardHeader extends StatefulWidget {
  final String? userName;
  final String? userProfileImage;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool hasNotifications;

  const EnhancedDashboardHeader({
    super.key,
    this.userName,
    this.userProfileImage,
    this.onProfileTap,
    this.onNotificationTap,
    this.hasNotifications = false,
  });

  @override
  State<EnhancedDashboardHeader> createState() =>
      _EnhancedDashboardHeaderState();
}

class _EnhancedDashboardHeaderState extends State<EnhancedDashboardHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Romantic color palette
  static const Color _roseGold = Color(0xFFE8B4B8);
  static const Color _warmRed = Color(0xFFFF6B8A);
  static const Color _deepBlue = Color(0xFF1A365D);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(28),
              height: 160, // Reduced height since we removed buttons
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _deepBlue,
                    _deepBlue.withValues(alpha: 0.95),
                    _warmRed.withValues(alpha: 0.8),
                    _roseGold.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _deepBlue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: _warmRed.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Floating romantic background elements
                  _buildFloatingElements(),

                  // Main content
                  _buildMainContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Large floating circle
        Positioned(
          top: -20,
          right: 40,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // Medium floating circle
        Positioned(
          bottom: -10,
          right: 20,
          child: Transform.scale(
            scale: _scaleAnimation.value * 0.8,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _roseGold.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),

        // Small floating hearts
        Positioned(
          top: 20,
          right: 100,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              Icons.favorite,
              color: _roseGold.withValues(alpha: 0.3),
              size: 16,
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          right: 80,
          child: Transform.scale(
            scale: _scaleAnimation.value * 0.7,
            child: Icon(
              Icons.favorite,
              color: Colors.white.withValues(alpha: 0.2),
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Row(
      children: [
        // Profile image (if provided)
        if (widget.userProfileImage != null) ...[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                widget.userProfileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: _roseGold.withValues(alpha: 0.3),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],

        // Enhanced text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message with enhanced styling
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.9),
                      ],
                    ).createShader(bounds),
                child: Text(
                  'Welcome back${widget.userName != null ? ", ${widget.userName}" : ""}',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    fontSize: 26,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Inspirational tagline
              Text(
                'Your journey to meaningful connection continues',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Notification bell (optional)
        if (widget.onNotificationTap != null)
          Container(
            margin: const EdgeInsets.only(left: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onNotificationTap?.call();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 24,
                      ),
                      if (widget.hasNotifications)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _warmRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
