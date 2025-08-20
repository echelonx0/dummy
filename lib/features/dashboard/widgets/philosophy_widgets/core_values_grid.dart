// // lib/features/dashboard/widgets/philosophy_widgets/core_values_grid.dart
// import 'package:flutter/material.dart';
// import '../../../../constants/app_colors.dart';
// import '../../../../constants/app_text_styles.dart';

// class CoreValuesGrid extends StatelessWidget {
//   const CoreValuesGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 4,
//               height: 32,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
//                 ),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Our Core Values',
//               style: AppTextStyles.heading2.copyWith(
//                 color: AppColors.textLight,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 20),

//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 1.1,
//           children: [
//             _buildValueCard(
//               icon: Icons.favorite_border,
//               title: 'Intentional Love',
//               description:
//                   'Real connections require time, intention, and genuine compatibility.',
//               gradientColors: [
//                 AppColors.primaryAccent.withValues(alpha: 0.1),
//                 AppColors.cardBackground,
//               ],
//             ),
//             _buildValueCard(
//               icon: Icons.psychology_outlined,
//               title: 'Self-Awareness',
//               description:
//                   'Understanding yourself is the foundation of healthy relationships.',
//               gradientColors: [
//                 AppColors.primarySageGreen.withValues(alpha: 0.1),
//                 AppColors.cardBackground,
//               ],
//             ),
//             _buildValueCard(
//               icon: Icons.trending_up,
//               title: 'Continuous Growth',
//               description:
//                   'The best relationships happen when both people are growing.',
//               gradientColors: [
//                 AppColors.electricBlue.withValues(alpha: 0.1),
//                 AppColors.cardBackground,
//               ],
//             ),
//             _buildValueCard(
//               icon: Icons.auto_awesome,
//               title: 'Authentic Connection',
//               description: 'We celebrate authenticity over perfection.',
//               gradientColors: [
//                 AppColors.primaryGold.withValues(alpha: 0.1),
//                 AppColors.cardBackground,
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildValueCard({
//     required IconData icon,
//     required String title,
//     required String description,
//     required List<Color> gradientColors,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.cardBackground, AppColors.primaryGold],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppColors.primarySageGreen.withValues(alpha: 0.4),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryDarkBlue.withValues(alpha: 0.2),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.primarySageGreen,
//                   AppColors.primaryAccent.withValues(alpha: 0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primarySageGreen.withValues(alpha: 0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: AppColors.primaryDarkBlue, size: 18),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: AppTextStyles.bodyMedium.copyWith(
//               fontWeight: FontWeight.w600,
//               color: AppColors.textDark,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Expanded(
//             child: Text(
//               description,
//               style: AppTextStyles.caption.copyWith(
//                 color: AppColors.textMedium,
//                 height: 1.3,
//                 fontSize: 11,
//               ),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/features/dashboard/widgets/philosophy_widgets/core_values_grid.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class CoreValuesGrid extends StatelessWidget {
  const CoreValuesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive design for tablets
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isTablet ? 3 : 2; // More columns on tablet
    final aspectRatio = isTablet ? 1.2 : 1.1; // Better proportions

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Our Core Values',
              style: (isTablet
                      ? AppTextStyles.heading1
                      : AppTextStyles.heading2)
                  .copyWith(
                    color:
                        AppColors.primaryDarkBlue, // ✅ FIXED: Better contrast
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount, // Responsive columns
          crossAxisSpacing: isTablet ? 24 : 16, // More spacing on tablet
          mainAxisSpacing: isTablet ? 24 : 16,
          childAspectRatio: aspectRatio,
          children: [
            _buildValueCard(
              icon: Icons.favorite_border,
              title: 'Intentional Love',
              description:
                  'Real connections require time, intention, and genuine compatibility.',
              accentColor: AppColors.primarySageGreen,
              isTablet: isTablet,
            ),
            _buildValueCard(
              icon: Icons.psychology_outlined,
              title: 'Self-Awareness',
              description:
                  'Understanding yourself is the foundation of healthy relationships.',
              accentColor: AppColors.primaryAccent,
              isTablet: isTablet,
            ),
            _buildValueCard(
              icon: Icons.trending_up,
              title: 'Continuous Growth',
              description:
                  'The best relationships happen when both people are growing.',
              accentColor: AppColors.cream,
              isTablet: isTablet,
            ),
            _buildValueCard(
              icon: Icons.auto_awesome,
              title: 'Authentic Connection',
              description: 'We celebrate authenticity over perfection.',
              accentColor: AppColors.primaryGold,
              isTablet: isTablet,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16), // More padding on tablet
      decoration: BoxDecoration(
        // ✅ FIXED: High contrast background
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
            blurRadius: isTablet ? 20 : 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: isTablet ? 32 : 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced icon container
          Container(
            width: isTablet ? 48 : 36,
            height: isTablet ? 48 : 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white, // ✅ FIXED: High contrast
              size: isTablet ? 24 : 18,
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Enhanced title
          Text(
            title,
            style: (isTablet
                    ? AppTextStyles.bodyLarge
                    : AppTextStyles.bodyMedium)
                .copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream, // ✅ FIXED: High contrast
                  fontSize: isTablet ? 18 : 14,
                ),
          ),

          SizedBox(height: isTablet ? 10 : 6),

          // Enhanced description
          Expanded(
            child: Text(
              description,
              style: (isTablet
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.caption)
                  .copyWith(
                    color: AppColors.cream, // ✅ FIXED: Better contrast
                    height: 1.4,
                    fontSize: isTablet ? 14 : 11,
                  ),
              maxLines: isTablet ? 4 : 3, // More lines on tablet
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
