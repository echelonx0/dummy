// lib/shared/widgets/dashboard_empty_states.dart
import 'package:flutter/material.dart';
import '../../constants/app_text_styles.dart';

class DashboardEmptyStates {
  // Accent Colors
  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);
  static const Color _sunsetOrange = Color(0xFFFFE66D);
  static const Color _mintGreen = Color(0xFF95E1A3);

  /// Empty insights card with animated icon and "Check Again" button
  static Widget emptyInsights({
    required VoidCallback onRetry,
    String? title,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    IconData? icon,
  }) {
    return _EmptyStateCard(
      icon: icon ?? Icons.psychology_outlined,
      title: title ?? 'Insights Being Generated ✨',
      description:
          description ??
          'Our AI is analyzing your profile to generate personalized relationship insights. This usually takes a few minutes. ⏰',
      primaryColor: primaryColor ?? _coralPink,
      secondaryColor: secondaryColor ?? _electricBlue,
      buttonText: 'Check Again 🔍',
      onButtonPressed: onRetry,
    );
  }

  /// Empty growth tasks card with animated icon
  static Widget emptyTasks({
    String? title,
    String? description,
    Color? primaryColor,
    Color? secondaryColor,
    IconData? icon,
    VoidCallback? onRetry,
  }) {
    return _EmptyStateCard(
      icon: icon ?? Icons.task_alt_outlined,
      title: title ?? 'Growth Tasks Coming Soon 🚀',
      description:
          description ??
          'Your personalized growth tasks will appear here once your insights are generated. Get ready to level up! 💪',
      primaryColor: primaryColor ?? _electricBlue,
      secondaryColor: secondaryColor ?? _mintGreen,
      buttonText: onRetry != null ? 'Check Again 🔍' : null,
      onButtonPressed: onRetry,
    );
  }

  /// Loading skeleton with staggered animations
  static Widget loadingSkeleton({
    int itemCount = 3,
    Duration? baseDuration,
    int? delayIncrement,
    Widget? skeletonChild,
  }) {
    return _LoadingSkeleton(
      itemCount: itemCount,
      baseDuration: baseDuration ?? const Duration(milliseconds: 400),
      delayIncrement: delayIncrement ?? 200,
      skeletonChild: skeletonChild ?? const InsightsSkeleton(),
    );
  }

  /// Generic empty state for any content
  static Widget emptyContent({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
    Color? secondaryColor,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return _EmptyStateCard(
      icon: icon,
      title: title,
      description: description,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor ?? primaryColor.withValues(alpha: 0.7),
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  /// No matches empty state
  static Widget noMatches({VoidCallback? onRetry}) {
    return emptyContent(
      icon: Icons.favorite_border,
      title: 'No Matches Yet 💔',
      description:
          'Don\'t worry! Our AI is working hard to find your perfect match. Great connections take time.',
      primaryColor: _coralPink,
      secondaryColor: _sunsetOrange,
      buttonText: onRetry != null ? 'Refresh Matches 💕' : null,
      onButtonPressed: onRetry,
    );
  }

  /// No conversations empty state
  static Widget noConversations({VoidCallback? onStartConversation}) {
    return emptyContent(
      icon: Icons.chat_bubble_outline,
      title: 'Start Connecting! 💬',
      description:
          'Ready to begin meaningful conversations? Our AI will help guide your first interactions.',
      primaryColor: _electricBlue,
      secondaryColor: _mintGreen,
      buttonText: onStartConversation != null ? 'Start Chatting 🚀' : null,
      onButtonPressed: onStartConversation,
    );
  }
}

/// Private widget for consistent empty state styling
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.2),
                        secondaryColor.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 48),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Title
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Description
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    description,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          // Button (if provided)
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
              builder: (context, value, child) {
                // ✅ FIX: Clamp opacity value to valid range
                final clampedOpacity = (0.8 + (0.2 * value)).clamp(0.0, 1.0);

                return Transform.scale(
                  scale: clampedOpacity, // Using clamped value for scale too
                  child: Opacity(
                    opacity: clampedOpacity, // ✅ FIXED: Use clamped value
                    child: _AnimatedButton(
                      text: buttonText!,
                      onPressed: onButtonPressed!,
                      color: primaryColor,
                      isSecondary: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Private widget for loading skeleton with staggered animations
class _LoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final Duration baseDuration;
  final int delayIncrement;
  final Widget skeletonChild;

  const _LoadingSkeleton({
    required this.itemCount,
    required this.baseDuration,
    required this.delayIncrement,
    required this.skeletonChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(
            milliseconds:
                baseDuration.inMilliseconds + (index * delayIncrement),
          ),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: skeletonChild,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Private animated button widget
class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isSecondary;

  const _AnimatedButton({
    required this.text,
    required this.onPressed,
    required this.color,
    this.isSecondary = false,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    widget.isSecondary
                        ? null
                        : LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withValues(alpha: 0.8),
                          ],
                        ),
                color:
                    widget.isSecondary
                        ? widget.color.withValues(alpha: 0.1)
                        : null,
                borderRadius: BorderRadius.circular(16),
                border:
                    widget.isSecondary
                        ? Border.all(color: widget.color, width: 1.5)
                        : null,
                boxShadow:
                    widget.isSecondary
                        ? null
                        : [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
              ),
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    widget.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.isSecondary ? widget.color : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom skeleton widget for insights (if you need a specific one)
class InsightsSkeleton extends StatefulWidget {
  const InsightsSkeleton({super.key});

  @override
  State<InsightsSkeleton> createState() => _InsightsSkeletonState();
}

class _InsightsSkeletonState extends State<InsightsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops:
                  [
                    _shimmerController.value - 0.3,
                    _shimmerController.value,
                    _shimmerController.value + 0.3,
                  ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
