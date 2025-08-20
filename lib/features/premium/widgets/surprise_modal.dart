// lib/features/subscriptions/widgets/surprise_me_modal.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class SurpriseMeModal extends StatefulWidget {
  const SurpriseMeModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SurpriseMeModal(),
    );
  }

  @override
  State<SurpriseMeModal> createState() => _SurpriseMeModalState();
}

class _SurpriseMeModalState extends State<SurpriseMeModal>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  bool _isGenerating = false;
  String? _surpriseResult;
  String? _surpriseTitle;
  IconData? _surpriseIcon;

  final List<Map<String, dynamic>> _surpriseOptions = [
    {
      'title': 'Mystery Date Idea',
      'description': 'Get a unique date suggestion based on your personality',
      'icon': Icons.lightbulb_outline,
      'action': 'date_idea',
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
    },
    {
      'title': 'Compatibility Insight',
      'description': 'Discover something new about your dating patterns',
      'icon': Icons.psychology,
      'action': 'insight',
      'gradient': [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    },
    {
      'title': 'Random Match Intro',
      'description': 'Get introduced to an unexpected but compatible match',
      'icon': Icons.shuffle,
      'action': 'match',
      'gradient': [const Color(0xFF6B73FF), const Color(0xFF9C27B0)],
    },
    {
      'title': 'Personal Growth Challenge',
      'description': 'A fun challenge to improve your dating confidence',
      'icon': Icons.emoji_events,
      'action': 'challenge',
      'gradient': [const Color(0xFFF093FB), const Color(0xFFAD5389)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6B46C1).withValues(alpha: 0.9),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with animated sparkles
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating sparkles
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * pi,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: CustomPaint(
                              painter: SparklePainter(_sparkleController.value),
                            ),
                          ),
                        );
                      },
                    ),
                    // Center icon with pulse
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  const Color(0xFF6B46C1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isGenerating
                                  ? Icons.autorenew
                                  : Icons.auto_awesome,
                              color: AppColors.cream,
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'I\'m Bored!',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Let me surprise you with something fun ✨',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child:
                  _isGenerating
                      ? _buildGeneratingState()
                      : _surpriseResult != null
                      ? _buildResultState()
                      : _buildOptionsState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsState() {
    return Column(
      children: [
        Text(
          'What kind of surprise?',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: _surpriseOptions.length,
            itemBuilder: (context, index) {
              final option = _surpriseOptions[index];
              return _buildOptionCard(option, index);
            },
          ),
        ),

        const SizedBox(height: 20),

        // Random surprise button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6B46C1),
                  const Color(0xFF9C27B0),
                  AppColors.primaryGold,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _generateSurprise('random'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, color: AppColors.cream, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Totally Random Surprise!',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option, int index) {
    return GestureDetector(
      onTap: () => _generateSurprise(option['action']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: option['gradient'][0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(option['icon'], color: AppColors.cream, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                option['title'],
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                option['description'],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_sparkleController.value * 0.3),
                child: Transform.rotate(
                  angle: _sparkleController.value * 2 * pi,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold,
                          const Color(0xFF6B46C1),
                          AppColors.primaryAccent,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.cream,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Text(
            'Generating your surprise...',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'This might take a moment ✨',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
            ),
          ),

          const SizedBox(height: 24),

          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  final delay = index * 0.3;
                  final progress = (_sparkleController.value + delay) % 1.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(
                        alpha: (0.3 + progress * 0.7).clamp(0.0, 1.0),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Result container with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold.withValues(alpha: 0.1),
                        const Color(0xFF6B46C1).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Surprise icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGold,
                              const Color(0xFF6B46C1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _surpriseIcon ?? Icons.celebration,
                          color: AppColors.cream,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        _surpriseTitle ?? 'Your Surprise!',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _surpriseResult!,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Fun stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('🎯', 'Personalized', 'For You'),
                      _buildStat('⚡', 'Instant', 'Delivery'),
                      _buildStat('🎉', 'Fun', 'Guaranteed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _surpriseResult = null;
                    _surpriseTitle = null;
                    _surpriseIcon = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryAccent,
                  side: BorderSide(color: AppColors.primaryAccent, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.primarySageGreen],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: AppColors.cream, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Love It!',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String emoji, String title, String subtitle) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMedium),
        ),
      ],
    );
  }

  Future<void> _generateSurprise(String type) async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay with realistic timing
    await Future.delayed(const Duration(milliseconds: 2500));

    Map<String, dynamic> result = _getSurpriseContent(type);

    // Log surprise generation
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('user_activities').add({
          'userId': user.uid,
          'type': 'surprise_generation',
          'surpriseType': type,
          'title': result['title'],
          'content': result['content'],
          'timestamp': FieldValue.serverTimestamp(),
          'platform': 'mobile_app',
        });
      }
    } catch (e) {
      // Log error but don't break user experience
      print('Failed to log surprise generation: $e');
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _surpriseResult = result['content'];
        _surpriseTitle = result['title'];
        _surpriseIcon = result['icon'];
      });
    }
  }

  Map<String, dynamic> _getSurpriseContent(String type) {
    final random = Random();

    switch (type) {
      case 'date_idea':
        final ideas = [
          {
            'title': 'Creative Date Adventure!',
            'content':
                '🎨 Create art together at a pottery studio, then grab coffee to discuss your masterpieces! The imperfection makes it perfect.',
            'icon': Icons.palette,
          },
          {
            'title': 'Stargazing Connection',
            'content':
                '🌟 Find a quiet spot for stargazing and share your biggest dreams. The universe has a way of bringing hearts together.',
            'icon': Icons.nightlight,
          },
          {
            'title': 'Culinary Adventure',
            'content':
                '🍳 Cook a meal from a cuisine neither of you has tried before. Laughter over kitchen disasters = instant bonding!',
            'icon': Icons.restaurant,
          },
          {
            'title': 'Literary Connection',
            'content':
                '📚 Visit a bookstore, pick out books for each other, then discuss them over lunch. Mind meet heart!',
            'icon': Icons.book,
          },
        ];
        return ideas[random.nextInt(ideas.length)];

      case 'insight':
        final insights = [
          {
            'title': 'Your Attraction Superpower',
            'content':
                '💡 You\'re most magnetic when genuinely passionate about something. Your enthusiasm literally lights up rooms and hearts!',
            'icon': Icons.psychology,
          },
          {
            'title': 'Deep Connection Discovery',
            'content':
                '🔍 Your dating pattern shows you value substance over surface. This rare quality attracts equally authentic souls.',
            'icon': Icons.insights,
          },
          {
            'title': 'Growth-Oriented Love',
            'content':
                '✨ You\'re drawn to intellectual stimulation, meaning you\'re ready for a relationship that evolves and grows.',
            'icon': Icons.trending_up,
          },
        ];
        return insights[random.nextInt(insights.length)];

      case 'match':
        final matches = [
          {
            'title': 'Perfect Match Alert!',
            'content':
                '🎉 Someone special shares your love for deep conversations and sustainable living. Your introduction is being prepared...',
            'icon': Icons.favorite,
          },
          {
            'title': 'Energy Match Found!',
            'content':
                '✨ Exciting news! We found someone who matches your vibe perfectly - creative, ambitious, and authentically themselves.',
            'icon': Icons.bolt,
          },
        ];
        return matches[random.nextInt(matches.length)];

      case 'challenge':
        final challenges = [
          {
            'title': '7-Day Confidence Challenge',
            'content':
                '🎯 Start one genuine conversation with a stranger each day. Watch your dating confidence soar to new heights!',
            'icon': Icons.emoji_events,
          },
          {
            'title': 'Active Listening Mission',
            'content':
                '💪 Practice deep listening in every conversation this week. Notice how people light up when truly heard.',
            'icon': Icons.hearing,
          },
        ];
        return challenges[random.nextInt(challenges.length)];

      default: // random
        final surprises = [
          {
            'title': 'Surprise Profile Boost!',
            'content':
                '🎊 You\'re getting a complimentary profile review from our expert team this week! Time to shine even brighter.',
            'icon': Icons.star,
          },
          {
            'title': 'Global Connections Unlocked!',
            'content':
                '🎁 We\'re upgrading your match preferences to include international connections for the next month. Love knows no borders!',
            'icon': Icons.public,
          },
          {
            'title': 'Exclusive Event Invitation',
            'content':
                '✨ Your personality analysis suggests you\'d thrive at our upcoming singles mixer. VIP invitation incoming!',
            'icon': Icons.event,
          },
          {
            'title': 'Early Access Granted!',
            'content':
                '🌟 You now have early access to our new compatibility deep-dive feature. Prepare for mind-blowing insights!',
            'icon': Icons.psychology_alt,
          },
          {
            'title': 'Premium Icebreakers Unlocked!',
            'content':
                '🎉 Surprise! You now have access to our premium conversation starters for all your matches. Say goodbye to "hey"!',
            'icon': Icons.chat_bubble,
          },
        ];
        return surprises[random.nextInt(surprises.length)];
    }
  }
}

// ==========================================================================
// SPARKLE PAINTER FOR MAGICAL ANIMATIONS
// ==========================================================================

class SparklePainter extends CustomPainter {
  final double progress;

  SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primaryGold.withValues(alpha: 0.8)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw multiple sparkle rings
    for (int ring = 0; ring < 2; ring++) {
      final ringRadius = radius * (1.0 + ring * 0.3);
      final sparkleCount = 6 + ring * 2;

      for (int i = 0; i < sparkleCount; i++) {
        final angle =
            (i * (360 / sparkleCount) + progress * 360.0 * (ring + 1)) *
            (pi / 180.0);
        final sparkleCenter = Offset(
          center.dx + ringRadius * cos(angle),
          center.dy + ringRadius * sin(angle),
        );

        // Dynamic sparkle size with wave motion
        final sparkleSize = 3.0 + sin(progress * 4 * pi + i + ring) * 2.0;
        final alpha = (0.3 + cos(progress * 2 * pi + i) * 0.4).clamp(0.0, 1.0);

        paint.color = AppColors.primaryGold.withValues(alpha: alpha);

        // Draw sparkle cross
        canvas.drawLine(
          Offset(sparkleCenter.dx - sparkleSize, sparkleCenter.dy),
          Offset(sparkleCenter.dx + sparkleSize, sparkleCenter.dy),
          paint,
        );
        canvas.drawLine(
          Offset(sparkleCenter.dx, sparkleCenter.dy - sparkleSize),
          Offset(sparkleCenter.dx, sparkleCenter.dy + sparkleSize),
          paint,
        );

        // Add diagonal lines for more sparkle
        if (sparkleSize > 4) {
          final diagSize = sparkleSize * 0.7;
          canvas.drawLine(
            Offset(sparkleCenter.dx - diagSize, sparkleCenter.dy - diagSize),
            Offset(sparkleCenter.dx + diagSize, sparkleCenter.dy + diagSize),
            paint,
          );
          canvas.drawLine(
            Offset(sparkleCenter.dx - diagSize, sparkleCenter.dy + diagSize),
            Offset(sparkleCenter.dx + diagSize, sparkleCenter.dy - diagSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
