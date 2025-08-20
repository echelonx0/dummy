// lib/features/subscriptions/widgets/matchmaker_contact_modal.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/subscriptions/subscription_manager.dart';
import 'coaching_booking_modal.dart';

class MatchmakerContactModal extends StatefulWidget {
  const MatchmakerContactModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MatchmakerContactModal(),
    );
  }

  @override
  State<MatchmakerContactModal> createState() => _MatchmakerContactModalState();
}

class _MatchmakerContactModalState extends State<MatchmakerContactModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;

  bool _isContacting = false;
  String _selectedContactMethod = 'message';
  final _messageController = TextEditingController();
  final _topicsController = TextEditingController();

  final List<String> _urgencyLevels = [
    'No rush - within a week',
    'Soon - within 2-3 days',
    'Urgent - within 24 hours',
  ];
  String _selectedUrgency = 'Soon - within 2-3 days';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _messageController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
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
                color: AppColors.textMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with animated icon
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryAccent,
                                AppColors.primaryGold,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.psychology_alt,
                            color: AppColors.cream,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Personal Matchmaker',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect with your dedicated dating expert',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // What you get section with premium feel
                    _buildBenefitsSection(),

                    const SizedBox(height: 32),

                    // Contact method selection
                    _buildContactMethodSection(),

                    const SizedBox(height: 24),

                    // Message input if selected
                    if (_selectedContactMethod == 'message') ...[
                      _buildMessageSection(),
                      const SizedBox(height: 24),
                    ],

                    // Urgency selection
                    _buildUrgencySection(),

                    const SizedBox(height: 32),

                    // CTA Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': Icons.person_search,
        'title': 'Personalized Match Curation',
        'description':
            'Hand-picked matches based on your unique preferences and deep compatibility analysis',
        'color': AppColors.primarySageGreen,
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Bi-Weekly Strategy Sessions',
        'description':
            'Regular calls to discuss your dating journey, optimize your approach, and overcome challenges',
        'color': AppColors.primaryAccent,
      },
      {
        'icon': Icons.psychology,
        'title': 'Relationship Coaching',
        'description':
            'Expert guidance on communication, emotional intelligence, and building lasting connections',
        'color': AppColors.primaryGold,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Continuous Profile Optimization',
        'description':
            'Ongoing refinement of your profile, photos, and presentation to attract your ideal match',
        'color': const Color(0xFF6B46C1),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryAccent.withValues(alpha: 0.1),
                AppColors.primaryGold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.diamond, color: AppColors.primaryGold, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Matchmaking Service',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Exclusive to Concierge & Executive members',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'What You Get',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        ...benefits.map((benefit) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (benefit['color'] as Color).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (benefit['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    benefit['icon'] as IconData,
                    color: benefit['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        benefit['description'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildContactMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you like to connect?',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildContactOption(
                'message',
                'Send Message',
                Icons.message,
                'Quick and convenient',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactOption(
                'call',
                'Schedule Call',
                Icons.phone,
                'Personal consultation',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedContactMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContactMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                  : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primarySageGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.primarySageGreen
                      : AppColors.textMedium,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color:
                    isSelected
                        ? AppColors.primarySageGreen
                        : AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Message',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: _messageController,
          maxLines: 4,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryAccent,
          ),
          decoration: InputDecoration(
            hintText: 'Tell your matchmaker what you\'d like help with...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primarySageGreen,
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick topic suggestions
        Text(
          'Common Topics',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'Match preferences',
                'Profile optimization',
                'Dating strategy',
                'Communication tips',
                'Relationship goals',
              ].map((topic) {
                return GestureDetector(
                  onTap: () {
                    final currentText = _messageController.text;
                    final newText =
                        currentText.isEmpty ? topic : '$currentText, $topic';
                    _messageController.text = newText;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primarySageGreen.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      topic,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primarySageGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildUrgencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Time Preference',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUrgency,
              isExpanded: true,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent,
              ),
              dropdownColor: AppColors.cardBackground,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.primarySageGreen,
              ),
              items:
                  _urgencyLevels.map((String urgency) {
                    return DropdownMenuItem<String>(
                      value: urgency,
                      child: Row(
                        children: [
                          Icon(
                            urgency.contains('Urgent')
                                ? Icons.priority_high
                                : urgency.contains('Soon')
                                ? Icons.schedule
                                : Icons.event_available,
                            color: AppColors.primarySageGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(urgency),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedUrgency = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isContacting ? null : _contactMatchmaker,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  _isContacting
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.cream,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedContactMethod == 'call'
                                ? Icons.phone
                                : Icons.send,
                            color: AppColors.cream,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedContactMethod == 'call'
                                ? 'Schedule Call with Matchmaker'
                                : 'Contact My Matchmaker',
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

        const SizedBox(height: 12),

        // Secondary action
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMedium,
              side: BorderSide(color: AppColors.textLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Maybe Later',
              style: AppTextStyles.button.copyWith(color: AppColors.textMedium),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _contactMatchmaker() async {
    setState(() {
      _isContacting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (_selectedContactMethod == 'call') {
        // Navigate to booking modal for calls
        Navigator.pop(context);
        await CoachingBookingModal.show(context);
        return;
      }

      // For messages, save to Firestore
      await FirebaseFirestore.instance.collection('matchmaker_requests').add({
        'userId': user.uid,
        'type': 'contact_request',
        'contactMethod': _selectedContactMethod,
        'message': _messageController.text.trim(),
        'urgency': _selectedUrgency,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'tier': SubscriptionManager().currentTierName,
        'metadata': {
          'userAgent': 'mobile_app',
          'platform': 'flutter',
          'source': 'premium_features_carousel',
        },
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.cream),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Message Sent to Your Matchmaker!',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                      Text(
                        'They\'ll respond within ${_selectedUrgency.toLowerCase()}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primarySageGreen,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to contact matchmaker: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isContacting = false;
        });
      }
    }
  }
}
