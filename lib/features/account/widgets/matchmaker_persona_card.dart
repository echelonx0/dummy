// lib/features/profile/widgets/matchmaker_persona_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/dashboard/persona/matchmaker_persona_selection.dart';
import '../../../constants/app_text_styles.dart';

class MatchmakerPersonaCard extends StatefulWidget {
  final String? currentPersona;
  final VoidCallback? onPersonaChanged;

  const MatchmakerPersonaCard({
    super.key,
    this.currentPersona,
    this.onPersonaChanged,
  });

  @override
  State<MatchmakerPersonaCard> createState() => _MatchmakerPersonaCardState();
}

class _MatchmakerPersonaCardState extends State<MatchmakerPersonaCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

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

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Start floating animation
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  MatchmakerPersona _getCurrentPersonaData() {
    final personas = _getPersonaOptions();
    return personas.firstWhere(
      (p) => p.id == widget.currentPersona,
      orElse: () => personas.first,
    );
  }

  List<MatchmakerPersona> _getPersonaOptions() {
    return [
      MatchmakerPersona(
        id: 'sage',
        name: 'Sophia the Sage',
        description: 'Wise, thoughtful, and philosophical approach to love',
        sampleText: 'Guiding you with wisdom and deep insights',
        icon: Icons.auto_awesome,
        gradientColors: [
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF8B5CF6), // Purple
        ],
      ),
      MatchmakerPersona(
        id: 'cheerleader',
        name: 'Maya the Cheerleader',
        description: 'Encouraging, optimistic, and motivational guidance',
        sampleText: 'Cheering you on every step of the way!',
        icon: Icons.celebration,
        gradientColors: [
          const Color(0xFFEC4899), // Pink
          const Color(0xFFF97316), // Orange
        ],
      ),
      MatchmakerPersona(
        id: 'strategist',
        name: 'Alex the Strategist',
        description: 'Direct, analytical, and results-focused approach',
        sampleText: 'Strategic guidance for dating success',
        icon: Icons.psychology,
        gradientColors: [
          const Color(0xFF059669), // Emerald
          const Color(0xFF0891B2), // Cyan
        ],
      ),
      MatchmakerPersona(
        id: 'empath',
        name: 'Luna the Empath',
        description: 'Gentle, understanding, and emotionally supportive',
        sampleText: 'Supporting you with empathy and care',
        icon: Icons.favorite_border,
        gradientColors: [
          const Color(0xFFA855F7), // Purple
          const Color(0xFFEC4899), // Pink
        ],
      ),
    ];
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _openPersonaSelection() {
    HapticFeedback.mediumImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const MatchmakerPersonaSelectionScreen(),
          ),
        )
        .then((_) {
          // Refresh the card if persona was changed
          widget.onPersonaChanged?.call();
        });
  }

  @override
  Widget build(BuildContext context) {
    final currentPersona = _getCurrentPersonaData();

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _floatingAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _openPersonaSelection,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              // 🎯 FIX: Increase height to prevent overflow
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentPersona.gradientColors.first,
                    currentPersona.gradientColors.last,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: currentPersona.gradientColors.first.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: currentPersona.gradientColors.last.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  // 🎯 FIX: Clip overflow to prevent layout issues
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Floating background elements
                    _buildFloatingElements(currentPersona),

                    // Main content - FIXED: Reduced padding
                    Padding(
                      padding: const EdgeInsets.all(20), // Reduced from 24
                      child: Row(
                        children: [
                          // Persona avatar - FIXED: Smaller size
                          Transform.translate(
                            offset: Offset(
                              0,
                              _floatingAnimation.value * 4,
                            ), // Less movement
                            child: Container(
                              width: 60, // Reduced from 70
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                currentPersona.icon,
                                color: Colors.white,
                                size: 28, // Reduced from 32
                              ),
                            ),
                          ),

                          const SizedBox(width: 16), // Reduced spacing
                          // Persona info - FIXED: Compact layout
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Your Matchmaker',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10, // Smaller font
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Change',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 2), // Reduced spacing

                                Flexible(
                                  child: Text(
                                    currentPersona.name,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      // Smaller heading
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // Explicit smaller size
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(height: 4), // Reduced spacing

                                Flexible(
                                  child: Text(
                                    currentPersona.sampleText,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      // Smaller text
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      height: 1.2,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow with subtle animation
                          Transform.translate(
                            offset: Offset(_floatingAnimation.value * 3, 0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFloatingElements(MatchmakerPersona persona) {
    return Stack(
      children: [
        // Large floating circle - FIXED: Better positioning
        Positioned(
          top: -15,
          right: 15,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value * 8),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // Medium floating circle - FIXED: Better positioning
        Positioned(
          bottom: -10,
          right: 45,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value * -5),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),

        // Floating sparkles - FIXED: Smaller, better positioned
        Positioned(
          top: 25,
          right: 80,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value * 4),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.4),
              size: 14,
            ),
          ),
        ),

        Positioned(
          bottom: 35,
          right: 25,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value * -3),
            child: Icon(
              Icons.favorite,
              color: Colors.white.withValues(alpha: 0.3),
              size: 12,
            ),
          ),
        ),

        // Small sparkle - FIXED: Smaller movement
        Positioned(
          top: 45,
          right: 25,
          child: Transform.translate(
            offset: Offset(0, _floatingAnimation.value * 6),
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Data class for matchmaker persona
class MatchmakerPersona {
  final String id;
  final String name;
  final String description;
  final String sampleText;
  final IconData icon;
  final List<Color> gradientColors;

  const MatchmakerPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.sampleText,
    required this.icon,
    required this.gradientColors,
  });
}
