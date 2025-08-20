// lib/features/profile/widgets/ai_chat_bubble.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';

class AIChatBubble extends StatelessWidget {
  final String text;
  final bool isTyping;

  const AIChatBubble({super.key, required this.text, this.isTyping = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.cardBackgroundElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),

          const SizedBox(width: AppDimensions.paddingM),

          // Message Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child:
                  isTyping
                      ? _buildTypingIndicator()
                      : Text(text, style: AppTextStyles.bodyMedium),
            ),
          ),

          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(children: [_buildDot(0), _buildDot(1), _buildDot(2)]);
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, -3.0 * value * (1 - value) * 4),
            child: child,
          );
        },
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
