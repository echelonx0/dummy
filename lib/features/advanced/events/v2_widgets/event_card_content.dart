// lib/features/events/widgets/components/event_card_content.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../core/models/events_models.dart';

class EventCardContent extends StatelessWidget {
  final Event event;
  final bool isCompact;
  final bool isExpanded;

  const EventCardContent({
    super.key,
    required this.event,
    this.isCompact = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(),
          SizedBox(height: isCompact ? 6 : 8),
          _buildBasicDetails(),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            _buildExpandedDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 16 : 18,
                ),
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                event.shortDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMedium,
                  fontSize: isCompact ? 13 : 14,
                ),
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (event.isEarlyBird) ...[
          const SizedBox(width: 8),
          _buildEarlyBirdBadge(),
        ],
      ],
    );
  }

  Widget _buildEarlyBirdBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primaryGold, width: 1),
      ),
      child: Text(
        'EARLY BIRD',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryGold,
          fontWeight: FontWeight.bold,
          fontSize: isCompact ? 8 : 9,
        ),
      ),
    );
  }

  Widget _buildBasicDetails() {
    final dateFormatter = DateFormat('MMM d, y');
    final timeFormatter = DateFormat('h:mm a');

    return Column(
      children: [
        _buildDetailRow(
          Icons.calendar_today_outlined,
          '${dateFormatter.format(event.startTime)} • ${timeFormatter.format(event.startTime)}',
        ),
        const SizedBox(height: 4),
        _buildDetailRow(
          Icons.location_on_outlined,
          '${event.venue.name} • ${event.venue.city}',
        ),
        if (!isCompact) ...[
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.access_time_outlined,
            '${event.duration.inHours}h ${event.duration.inMinutes % 60}m',
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: isCompact ? 14 : 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
              fontSize: isCompact ? 11 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.description.isNotEmpty) ...[
          Text(
            'About',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],
        if (event.highlights.isNotEmpty) ...[
          Text(
            'What\'s Included',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildHighlights(),
          const SizedBox(height: 12),
        ],
        if (event.hostName.isNotEmpty) ...[
          Text(
            'Host',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            event.hostName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHighlights() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: event.highlights.take(isExpanded ? 6 : 3).map((highlight) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySageGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primarySageGreen.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            highlight,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primarySageGreen,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }
}