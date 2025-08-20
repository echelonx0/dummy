// lib/features/events/widgets/components/event_card_header.dart
import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../core/models/events_models.dart';

class EventCardHeader extends StatelessWidget {
  final Event event;
  final EventRegistration? userRegistration;
  final bool isCompact;

  const EventCardHeader({
    super.key,
    required this.event,
    this.userRegistration,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cover image with gradient
        _buildCoverImage(),
        
        // Gradient overlay
        _buildGradientOverlay(),
        
        // Top badges
        Positioned(top: 12, left: 12, child: _buildAccessBadge()),
        Positioned(top: 12, right: 12, child: _buildCategoryBadge()),
        
        // Bottom overlays
        if (userRegistration != null)
          Positioned(bottom: 12, left: 12, child: _buildRegistrationBadge()),
        Positioned(bottom: 12, right: 12, child: _buildSpotsIndicator()),
      ],
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: isCompact ? 120 : 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        image: event.coverImageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(event.coverImageUrl),
                fit: BoxFit.cover,
              )
            : null,
        gradient: event.coverImageUrl.isEmpty
            ? LinearGradient(
                colors: [
                  AppColors.primarySageGreen.withValues(alpha: 0.8),
                  AppColors.primaryAccent.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: event.coverImageUrl.isEmpty
          ? Center(
              child: Icon(
                Icons.event_rounded,
                size: isCompact ? 32 : 48,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      height: isCompact ? 120 : 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessBadge() {
    if (event.accessType == EventAccessType.public) {
      return const SizedBox.shrink();
    }

    final badgeConfig = _getAccessBadgeConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeConfig['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        badgeConfig['text'],
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 9 : 10,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.category.emoji,
            style: TextStyle(fontSize: isCompact ? 10 : 12),
          ),
          const SizedBox(width: 4),
          Text(
            event.category.displayName,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: isCompact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationBadge() {
    if (userRegistration == null) return const SizedBox.shrink();

    final badgeConfig = _getRegistrationBadgeConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeConfig['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeConfig['icon'],
            color: Colors.white,
            size: isCompact ? 10 : 12,
          ),
          const SizedBox(width: 4),
          Text(
            badgeConfig['text'],
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotsIndicator() {
    final remaining = event.maxAttendees - event.currentAttendees;
    final indicatorColor = _getSpotsIndicatorColor(remaining);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        event.spotsRemainingText,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 9 : 10,
        ),
      ),
    );
  }

  Map<String, dynamic> _getAccessBadgeConfig() {
    switch (event.accessType) {
      case EventAccessType.freemiumLimited:
        return {'color': Colors.orange, 'text': 'LIMITED'};
      case EventAccessType.premiumOnly:
        return {'color': AppColors.primaryGold, 'text': 'PREMIUM'};
      case EventAccessType.eliteExclusive:
        return {'color': AppColors.primaryDarkBlue, 'text': 'ELITE'};
      case EventAccessType.inviteOnly:
        return {'color': Colors.purple, 'text': 'INVITE'};
      case EventAccessType.earlyAccess:
        return {'color': AppColors.primarySageGreen, 'text': 'EARLY'};
      default:
        return {'color': Colors.grey, 'text': 'EVENT'};
    }
  }

  Map<String, dynamic> _getRegistrationBadgeConfig() {
    switch (userRegistration!.status) {
      case RegistrationStatus.confirmed:
        return {
          'color': AppColors.primarySageGreen,
          'text': 'REGISTERED',
          'icon': Icons.check_circle_outline
        };
      case RegistrationStatus.waitlisted:
        return {
          'color': Colors.orange,
          'text': 'WAITLISTED',
          'icon': Icons.schedule
        };
      case RegistrationStatus.pending:
        return {
          'color': Colors.blue,
          'text': 'PENDING',
          'icon': Icons.pending
        };
      default:
        return {
          'color': Colors.grey,
          'text': 'UNKNOWN',
          'icon': Icons.help_outline
        };
    }
  }

  Color _getSpotsIndicatorColor(int remaining) {
    if (remaining <= 0) return Colors.red;
    if (remaining <= 5) return Colors.orange;
    return AppColors.primarySageGreen;
  }
}