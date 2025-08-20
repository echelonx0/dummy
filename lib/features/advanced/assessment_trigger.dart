// lib/widgets/modals/assessment_gateway_modal.dart

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'psych_engine/screens/psych_assessment_screen.dart';
import 'worldview_engine/screens/worldview_assessment_screen.dart';

enum AssessmentType { psychology, worldview }

class AssessmentGatewayModal extends StatefulWidget {
  final AssessmentType? initialType;
  final VoidCallback? onClose;

  const AssessmentGatewayModal({super.key, this.initialType, this.onClose});

  @override
  State<AssessmentGatewayModal> createState() => _AssessmentGatewayModalState();
}

class _AssessmentGatewayModalState extends State<AssessmentGatewayModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  AssessmentType _selectedType = AssessmentType.psychology;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    // Start pulsing animation
    _pulseController.repeat(reverse: true);
  }

  void _closeModal() async {
    if (_isAnimatingOut) return;

    setState(() {
      _isAnimatingOut = true;
    });

    _pulseController.stop();

    // Reverse animations
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.reverse();

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      Navigator.of(context).pop();
      widget.onClose?.call();
    }
  }

  void _startAssessment() async {
    if (_isAnimatingOut) return;

    setState(() {
      _isAnimatingOut = true;
    });

    _pulseController.stop();

    // Quick fade out animation
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pop();

      // Navigate to appropriate assessment
      if (_selectedType == AssessmentType.psychology) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PsychologyAssessmentScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => WorldviewAssessmentScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: AppColors.overlayDark,
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDarkBlue.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          _buildAssessmentSelector(),
                          _buildSelectedAssessmentInfo(),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.accentGradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: _closeModal,
                icon: Icon(Icons.close, color: AppColors.primaryDarkBlue),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent.withValues(
                    alpha: 0.9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Animated main icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_alt,
                    size: 40,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          Text(
            'Improve Your Match Profile',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDarkBlue,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            'Choose your path to deeper connections',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDarkBlue.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildAssessmentOption(
              type: AssessmentType.psychology,
              icon: Icons.psychology_outlined,
              title: 'Psychology',
              subtitle: 'Personality & Behavior',
              isSelected: _selectedType == AssessmentType.psychology,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAssessmentOption(
              type: AssessmentType.worldview,
              icon: Icons.balance,
              title: 'Worldview',
              subtitle: 'Values & Beliefs',
              isSelected: _selectedType == AssessmentType.worldview,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentOption({
    required AssessmentType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.warmRedAlpha10
                  : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.warmRed : AppColors.borderPrimary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.warmRed : AppColors.borderSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppColors.primaryAccent : AppColors.textMedium,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? AppColors.warmRed : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAssessmentInfo() {
    final info = _getAssessmentInfo(_selectedType);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_selectedType),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (info['color'] as Color).withValues(alpha: 0.1),
              (info['color'] as Color).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (info['color'] as Color).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info['icon'] as IconData,
                  color: info['color'] as Color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info['title'] as String,
                    style: AppTextStyles.label.copyWith(
                      color: info['color'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              info['description'] as String,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                height: 1.3,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  (info['features'] as List<String>).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (info['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (info['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        feature,
                        style: AppTextStyles.caption.copyWith(
                          color: info['color'] as Color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main CTA button with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isAnimatingOut ? 1.0 : _pulseAnimation.value,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      foregroundColor: AppColors.primaryButtonText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedType == AssessmentType.psychology
                              ? Icons.psychology_alt
                              : Icons.explore,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Start ${_getAssessmentInfo(_selectedType)['shortTitle']} Assessment',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primaryButtonText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Secondary info
          Text(
            '10 questions • ~15 minutes • Free for all users',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMedium,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAssessmentInfo(AssessmentType type) {
    switch (type) {
      case AssessmentType.psychology:
        return {
          'title': 'Psychology Profile',
          'shortTitle': 'Psychology',
          'icon': Icons.psychology_alt,
          'color': AppColors.warmRed,
          'description':
              'Discover how you approach relationships, handle stress, make decisions, and connect with others. Find your complementary opposite.',
          'features': [
            'Relationship Style',
            'Communication Patterns',
            'Opposite Matching',
            'Personality Insights',
          ],
        };
      case AssessmentType.worldview:
        return {
          'title': 'Worldview Explorer',
          'shortTitle': 'Worldview',
          'icon': Icons.balance,
          'color': AppColors.electricBlue,
          'description':
              'Explore your core values, beliefs, and life philosophy. Connect with fascinating people who see the world differently.',
          'features': [
            'Values Exploration',
            'Unlikely Matches',
            'Bridge Building',
            'Growth Potential',
          ],
        };
    }
  }
}
