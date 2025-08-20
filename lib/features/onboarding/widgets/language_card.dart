// lib/features/language/widgets/language_card.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';

class LanguageCard extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.languageCode,
    required this.languageName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<LanguageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LanguageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle:
                  _rotationAnimation.value *
                  (widget.languageCode == 'en' ? -1 : 1),
              child: _buildCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color:
            widget.isSelected
                ? AppColors.primaryGold.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusL),
        border: Border.all(
          color:
              widget.isSelected
                  ? AppColors.primaryGold
                  : Colors.white.withOpacity(0.2),
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow:
            widget.isSelected
                ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
                : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flag or language icon
          _buildLanguageIcon(),

          const SizedBox(height: 12),

          // Language name
          Text(
            widget.languageName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight:
                  widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Selected checkmark
          AnimatedOpacity(
            opacity: widget.isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: AppDimensions.paddingXS / 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusS,
                ),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageIcon() {
    IconData iconData;
    String label;

    // Set icon and label based on language code
    switch (widget.languageCode) {
      case 'fr':
        iconData = Icons.flag;
        label = 'FR';
        break;
      case 'sw':
        iconData = Icons.flag;
        label = 'SW';
        break;
      case 'en':
      default:
        iconData = Icons.flag;
        label = 'EN';
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          iconData,
          color:
              widget.isSelected
                  ? AppColors.primaryGold
                  : Colors.white.withOpacity(0.7),
          size: 32,
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: widget.isSelected ? AppColors.primaryDarkBlue : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
