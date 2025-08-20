// lib/features/events/widgets/event_detail_app_bar.dart
import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../core/models/events_models.dart';

class EventDetailAppBar extends StatelessWidget {
  final Event event;
  final EventRegistration? userRegistration;

  const EventDetailAppBar({
    super.key,
    required this.event,
    this.userRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            event.coverImageUrl.isNotEmpty
                ? Image.network(event.coverImageUrl, fit: BoxFit.cover)
                : Image.asset('assets/images/events.png', fit: BoxFit.cover),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Badges overlay
            Positioned(top: 100, left: 16, child: _buildAccessBadge()),
            Positioned(top: 100, right: 16, child: _buildCategoryBadge()),

            // Registration status
            if (userRegistration != null)
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildRegistrationBadge(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessBadge() {
    if (event.accessType == EventAccessType.public) {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    String badgeText;

    switch (event.accessType) {
      case EventAccessType.freemiumLimited:
        badgeColor = Colors.orange;
        badgeText = 'LIMITED ACCESS';
        break;
      case EventAccessType.premiumOnly:
        badgeColor = AppColors.primaryGold;
        badgeText = 'PREMIUM ONLY';
        break;
      case EventAccessType.eliteExclusive:
        badgeColor = AppColors.primaryDarkBlue;
        badgeText = 'ELITE EXCLUSIVE';
        break;
      case EventAccessType.inviteOnly:
        badgeColor = Colors.purple;
        badgeText = 'INVITE ONLY';
        break;
      case EventAccessType.earlyAccess:
        badgeColor = AppColors.primarySageGreen;
        badgeText = 'EARLY ACCESS';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(event.category.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            event.category.displayName,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationBadge() {
    if (userRegistration == null) return const SizedBox.shrink();

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (userRegistration!.status) {
      case RegistrationStatus.confirmed:
        badgeColor = AppColors.primarySageGreen;
        badgeText = 'REGISTERED';
        badgeIcon = Icons.check_circle;
        break;
      case RegistrationStatus.waitlisted:
        badgeColor = Colors.orange;
        badgeText = 'WAITLISTED';
        badgeIcon = Icons.schedule;
        break;
      case RegistrationStatus.pending:
        badgeColor = Colors.blue;
        badgeText = 'PENDING';
        badgeIcon = Icons.pending;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
