import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

// ==========================================================================
// MATCH CARD HEADER COMPONENT
// ==========================================================================

class MatchCardHeader extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final String profession;
  final int compatibility;

  const MatchCardHeader({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.profession,
    required this.compatibility,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile photo
        MatchCardProfilePhoto(imageUrl: imageUrl),

        const SizedBox(width: 16),

        // Name, age, profession
        Expanded(
          child: MatchCardBasicInfo(
            name: name,
            age: age,
            profession: profession,
          ),
        ),

        // Compatibility badge
        MatchCardCompatibilityBadge(compatibility: compatibility),
      ],
    );
  }
}

// ==========================================================================
// PROFILE PHOTO COMPONENT
// ==========================================================================

class MatchCardProfilePhoto extends StatelessWidget {
  final String imageUrl;

  const MatchCardProfilePhoto({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryGold,
              child: Icon(
                Icons.person,
                color: AppColors.primaryAccent,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================================================
// BASIC INFO COMPONENT
// ==========================================================================

class MatchCardBasicInfo extends StatelessWidget {
  final String name;
  final int age;
  final String profession;

  const MatchCardBasicInfo({
    super.key,
    required this.name,
    required this.age,
    required this.profession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$age',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          profession,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primarySageGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// COMPATIBILITY BADGE COMPONENT
// ==========================================================================

class MatchCardCompatibilityBadge extends StatelessWidget {
  final int compatibility;

  const MatchCardCompatibilityBadge({super.key, required this.compatibility});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: AppColors.primaryDarkBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            '$compatibility%',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryDarkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// BIO COMPONENT
// ==========================================================================

class MatchCardBio extends StatelessWidget {
  final String bio;

  const MatchCardBio({super.key, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Text(
      bio,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMedium,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ==========================================================================
// SHARED VALUES COMPONENT
// ==========================================================================

class MatchCardSharedValues extends StatelessWidget {
  final List<String> sharedValues;

  const MatchCardSharedValues({super.key, required this.sharedValues});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.primarySageGreen,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Shared values:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children:
              sharedValues.take(3).map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primarySageGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
