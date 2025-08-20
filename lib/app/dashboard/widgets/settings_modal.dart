// lib/features/dashboard/widgets/settings_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  // Accent Colors
  static const Color _coralPink = Color(0xFFFF6B9D);
  static const Color _electricBlue = Color(0xFF4ECDC4);
  static const Color _sunsetOrange = Color(0xFFFFE66D);
  static const Color _mintGreen = Color(0xFF95E1A3);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_sunsetOrange, AppColors.primaryGold],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Settings & Preferences',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSettingsSection(
                      title: 'Profile & Privacy',
                      icon: Icons.person_outline,
                      color: _coralPink,
                      items: [
                        _buildSettingsItem('Edit Profile', Icons.edit_outlined),
                        _buildSettingsItem(
                          'Privacy Settings',
                          Icons.privacy_tip_outlined,
                        ),
                        _buildSettingsItem(
                          'Block & Report',
                          Icons.block_outlined,
                        ),
                        _buildSettingsItem(
                          'Profile Visibility',
                          Icons.visibility_outlined,
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'Matching Preferences',
                      icon: Icons.favorite_outline,
                      color: _electricBlue,
                      items: [
                        _buildSettingsItem('Age Range', Icons.cake_outlined),
                        _buildSettingsItem(
                          'Distance',
                          Icons.location_on_outlined,
                        ),
                        _buildSettingsItem(
                          'Relationship Goals',
                          Icons.flag_outlined,
                        ),
                        _buildSettingsItem(
                          'Deal Breakers',
                          Icons.warning_outlined,
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'Notifications',
                      icon: Icons.notifications_active,
                      color: _sunsetOrange,
                      items: [
                        _buildSettingsItem(
                          'Push Notifications',
                          Icons.notifications_active_outlined,
                        ),
                        _buildSettingsItem(
                          'Email Updates',
                          Icons.email_outlined,
                        ),
                        _buildSettingsItem(
                          'Match Alerts',
                          Icons.favorite_border,
                        ),
                        _buildSettingsItem(
                          'Message Notifications',
                          Icons.chat_bubble_outline,
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'Safety & Support',
                      icon: Icons.security_outlined,
                      color: _mintGreen,
                      items: [
                        _buildSettingsItem(
                          'Safety Center',
                          Icons.shield_outlined,
                        ),
                        _buildSettingsItem(
                          'Help & Support',
                          Icons.help_outline,
                        ),
                        _buildSettingsItem(
                          'Report Issues',
                          Icons.bug_report_outlined,
                        ),
                        _buildSettingsItem(
                          'Community Guidelines',
                          Icons.rule_outlined,
                        ),
                      ],
                    ),

                    _buildSettingsSection(
                      title: 'Account',
                      icon: Icons.account_circle_outlined,
                      color: AppColors.textMedium,
                      items: [
                        _buildSettingsItem('Subscription', Icons.star_outline),
                        _buildSettingsItem(
                          'Payment Methods',
                          Icons.payment_outlined,
                        ),
                        _buildSettingsItem(
                          'Data Export',
                          Icons.download_outlined,
                        ),
                        _buildSettingsItem(
                          'Delete Account',
                          Icons.delete_outline,
                          isDestructive: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign Out Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: _buildAnimatedButton(
                        text: 'Sign Out 👋',
                        onPressed: () {
                          final authService = locator<AuthService>();
                          authService.signOut();
                        },
                        color: _coralPink,
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? _coralPink : AppColors.textMedium,
          size: 20,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDestructive ? _coralPink : AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textMedium,
          size: 16,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          // Handle settings navigation
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required bool isSecondary,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: GestureDetector(
            onTapDown: (_) => HapticFeedback.lightImpact(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isSecondary
                        ? null
                        : LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        ),
                color: isSecondary ? color.withValues(alpha: 0.1) : null,
                borderRadius: BorderRadius.circular(16),
                border:
                    isSecondary ? Border.all(color: color, width: 1.5) : null,
                boxShadow:
                    isSecondary
                        ? null
                        : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
              ),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSecondary ? color : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
