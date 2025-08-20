import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../core/shared/widgets/action_modal_widget.dart';
import 'match_card_actions.dart';
import 'match_card_components.dart';

class MatchCard extends StatefulWidget {
  final String name;
  final int age;
  final String imageUrl;
  final int compatibility;
  final List<String> sharedValues;
  final String profession;
  final String bio;
  final VoidCallback onTap;
  final VoidCallback? onInterested;
  final VoidCallback? onNotInterested;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.compatibility,
    required this.sharedValues,
    required this.profession,
    required this.bio,
    required this.onTap,
    this.onInterested,
    this.onNotInterested,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleInterested() {
    HapticFeedback.mediumImpact();
    ActionModalController.show(
      context: context,
      style: ActionModalStyle.center,
      data: ActionModalData(
        headline: 'Starting Courtship with ${widget.name}',
        subheadline:
            'Your interest has been noted. We\'ll guide you through the next steps!',
        ctaText: 'Continue',
        onAction: () {
          widget.onInterested?.call();
        },
        backgroundColor: AppColors.primarySageGreen,
        accentColor: AppColors.primaryAccent,
      ),
    );
  }

  void _handleNotInterested() {
    HapticFeedback.lightImpact();
    widget.onNotInterested?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardBackground,
                    AppColors.primaryGold.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header with photo and basic info
                    MatchCardHeader(
                      name: widget.name,
                      age: widget.age,
                      imageUrl: widget.imageUrl,
                      profession: widget.profession,
                      compatibility: widget.compatibility,
                    ),

                    const SizedBox(height: 16),

                    // Bio section
                    MatchCardBio(bio: widget.bio),

                    const SizedBox(height: 16),

                    // Shared values section
                    MatchCardSharedValues(sharedValues: widget.sharedValues),

                    const SizedBox(height: 20),

                    // Action buttons
                    MatchCardActions(
                      onInterested: _handleInterested,
                      onNotInterested: _handleNotInterested,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
