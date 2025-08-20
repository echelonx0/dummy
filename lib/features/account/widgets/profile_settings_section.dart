// lib/features/profile/widgets/profile_settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import 'profile_cards.dart';

class ProfileSettingsSection extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onEditPreferences;
  final VoidCallback onManagePrivacy;
  final VoidCallback onManageVisibility;

  const ProfileSettingsSection({
    super.key,
    required this.onEditProfile,
    required this.onEditPreferences,
    required this.onManagePrivacy,
    required this.onManageVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Profile Settings',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.cream,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.edit_outlined,
            title: 'Edit Profile Information',
            subtitle: 'Update your basic information and photos',
            onTap: onEditProfile,
          ),
          SettingsTile(
            icon: Icons.psychology_outlined,
            title: 'Relationship Preferences',
            subtitle: 'Update your dating preferences and goals',
            onTap: onEditPreferences,
          ),
          SettingsTile(
            icon: Icons.security_outlined,
            title: 'Privacy & Safety',
            subtitle: 'Manage your privacy settings',
            onTap: onManagePrivacy,
          ),
          SettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Profile Visibility',
            subtitle: 'Control who can see your profile',
            onTap: onManageVisibility,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}

class ProfileAccountSection extends StatelessWidget {
  final VoidCallback onManageNotifications;
  final VoidCallback onOpenSupport;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  const ProfileAccountSection({
    super.key,
    required this.onManageNotifications,
    required this.onOpenSupport,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Account',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.cream,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            onTap: onManageNotifications,
          ),
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: onOpenSupport,
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: onSignOut,
          ),
          SettingsTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: onDeleteAccount,
            showBorder: false,
            iconColor: AppColors.error,
            titleColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showBorder;
  final Color? iconColor;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showBorder = true,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border:
              showBorder
                  ? Border(
                    bottom: BorderSide(color: AppColors.divider, width: 0.5),
                  )
                  : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryDarkBlue).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.roseGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMedium,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
