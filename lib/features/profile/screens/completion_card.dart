// lib/features/profile/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';

// ============================================================================
// PROFILE PHOTO DISPLAY
// ============================================================================

class ProfilePhotoDisplay extends StatelessWidget {
  final String? photoUrl;
  final String? userName;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEdit;

  const ProfilePhotoDisplay({
    super.key,
    this.photoUrl,
    this.userName,
    this.size = 60,
    this.showEditButton = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGold,
                AppColors.primaryGold.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child:
              photoUrl != null && photoUrl!.isNotEmpty
                  ? ClipOval(
                    child: Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => _buildDefaultAvatar(),
                    ),
                  )
                  : _buildDefaultAvatar(),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primaryDarkBlue,
                  size: size * 0.15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        userName?.substring(0, 1).toUpperCase() ?? 'U',
        style: AppTextStyles.heading2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

// ============================================================================
// TRUST SCORE DISPLAY - Premium Revenue Driver
// ============================================================================

// class TrustScoreDisplay extends StatelessWidget {
//   final double trustScore;
//   final String trustTrend;
//   final VoidCallback onViewDetails;
//   final bool isPremium;
//   final VoidCallback? onUpgradeToPremium;

//   const TrustScoreDisplay({
//     super.key,
//     required this.trustScore,
//     required this.trustTrend,
//     required this.onViewDetails,
//     this.isPremium = false,
//     this.onUpgradeToPremium,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color scoreColor = _getScoreColor(trustScore);
//     final String scoreLabel = _getScoreLabel(trustScore);

//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.paddingL),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusL),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Trust Score Circle
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: scoreColor.withValues(alpha: 0.1),
//               border: Border.all(color: scoreColor, width: 3),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     trustScore.toInt().toString(),
//                     style: AppTextStyles.heading3.copyWith(
//                       color: scoreColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 24,
//                     ),
//                   ),
//                   Text(
//                     'Trust',
//                     style: AppTextStyles.caption.copyWith(
//                       color: scoreColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(width: AppDimensions.paddingL),

//           // Trust Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Trust Score',
//                       style: AppTextStyles.heading3.copyWith(fontSize: 18),
//                     ),
//                     const SizedBox(width: AppDimensions.paddingS),
//                     _buildTrendIcon(),
//                   ],
//                 ),

//                 const SizedBox(height: AppDimensions.paddingS),

//                 Text(
//                   scoreLabel,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textMedium,
//                   ),
//                 ),

//                 const SizedBox(height: AppDimensions.paddingS),

//                 // Premium Feature Hint
//                 if (!isPremium) ...[
//                   GestureDetector(
//                     onTap: onUpgradeToPremium,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: AppDimensions.paddingM,
//                         vertical: AppDimensions.paddingS,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryGold.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(
//                           AppDimensions.radiusS,
//                         ),
//                         border: Border.all(
//                           color: AppColors.primaryGold.withValues(alpha: 0.3),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.star,
//                             color: AppColors.primaryGold,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'See detailed breakdown',
//                             style: AppTextStyles.caption.copyWith(
//                               color: AppColors.primaryGold,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // Action Button
//           GestureDetector(
//             onTap: isPremium ? onViewDetails : onUpgradeToPremium,
//             child: Container(
//               padding: const EdgeInsets.all(AppDimensions.paddingM),
//               decoration: BoxDecoration(
//                 color: scoreColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//               ),
//               child: Icon(
//                 isPremium ? Icons.arrow_forward_ios : Icons.star,
//                 color: scoreColor,
//                 size: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendIcon() {
//     IconData icon;
//     Color color;

//     switch (trustTrend) {
//       case 'improving':
//         icon = Icons.trending_up;
//         color = const Color(0xFF95E1A3); // Mint green
//         break;
//       case 'declining':
//         icon = Icons.trending_down;
//         color = const Color(0xFFFF6B9D); // Coral pink
//         break;
//       default:
//         icon = Icons.trending_flat;
//         color = AppColors.textMedium;
//     }

//     return Icon(icon, color: color, size: 16);
//   }

//   Color _getScoreColor(double score) {
//     if (score >= 80) return const Color(0xFF95E1A3); // Mint green
//     if (score >= 60) return const Color(0xFFFFE66D); // Sunset orange
//     return const Color(0xFFFF6B9D); // Coral pink
//   }

//   String _getScoreLabel(double score) {
//     if (score >= 90) return 'Excellent standing';
//     if (score >= 80) return 'Good standing';
//     if (score >= 60) return 'Fair standing';
//     if (score >= 40) return 'Needs improvement';
//     return 'Low standing';
//   }
// }

// ============================================================================
// PROFILE COMPLETION CARD
// ============================================================================

class ProfileCompletionCard extends StatelessWidget {
  final double completionPercentage;
  final Map<String, dynamic> completionStatus;
  final VoidCallback onImproveProfile;

  const ProfileCompletionCard({
    super.key,
    required this.completionPercentage,
    required this.completionStatus,
    required this.onImproveProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = completionPercentage >= 100;
    final Color cardColor =
        isComplete ? const Color(0xFF95E1A3) : const Color(0xFFFFE66D);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.pending,
                  color: cardColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completion',
                      style: AppTextStyles.heading3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isComplete
                          ? 'Your profile is complete!'
                          : '${completionPercentage.toInt()}% complete',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Progress Bar
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(cardColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          if (!isComplete) ...[
            const SizedBox(height: AppDimensions.paddingL),
            GestureDetector(
              onTap: onImproveProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: cardColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: cardColor, size: 16),
                    const SizedBox(width: AppDimensions.paddingS),
                    Text(
                      'Improve Profile',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// PROFILE STATS CARD
// ============================================================================

class ProfileStatsCard extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final VoidCallback onViewDetails;

  const ProfileStatsCard({
    super.key,
    required this.profileData,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _generateStats();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Insights',
                style: AppTextStyles.heading3.copyWith(fontSize: 18),
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textMedium,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  stats['attachmentStyle']!,
                  'Attachment',
                  const Color(0xFF4ECDC4), // Electric blue
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildStatItem(
                  stats['matchQuality']!,
                  'Match Quality',
                  const Color(0xFFB794F6), // Lavender purple
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  stats['responseRate']!,
                  'Response Rate',
                  const Color(0xFF95E1A3), // Mint green
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildStatItem(
                  stats['profileViews']!,
                  'Profile Views',
                  const Color(0xFFFFE66D), // Sunset orange
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _generateStats() {
    return {
      'attachmentStyle':
          profileData?['attachmentStyle']?.toString().capitalize() ?? 'Unknown',
      'matchQuality': '${(profileData?['averageMatchScore'] ?? 75).toInt()}%',
      'responseRate': '${(profileData?['responseRate'] ?? 85).toInt()}%',
      'profileViews': '${profileData?['profileViews'] ?? 12}',
    };
  }
}

// ============================================================================
// PROFILE SETTINGS TILE
// ============================================================================

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showBorder;
  final Widget? trailing;

  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showBorder = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textMedium,
                size: 16,
              ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingS,
          ),
        ),
        if (showBorder)
          Divider(
            color: AppColors.divider,
            height: 1,
            indent: AppDimensions.paddingXL,
            endIndent: AppDimensions.paddingL,
          ),
      ],
    );
  }
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
