// lib/features/events/widgets/event_info_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khedoo/constants/app_text_styles.dart' show AppTextStyles;

import '../../../../constants/app_colors.dart' show AppColors;

import '../../../../core/models/events_models.dart';

class EventInfoCard extends StatelessWidget {
  final Event event;

  const EventInfoCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and early bird badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (event.isEarlyBird) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGold),
                  ),
                  child: Text(
                    'EARLY BIRD',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          Text(
            event.shortDescription,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
            ),
          ),

          const SizedBox(height: 20),

          // Event details
          _buildEventDetailRow(
            Icons.calendar_today_outlined,
            'Date & Time',
            _formatDateTime(),
          ),

          _buildEventDetailRow(
            Icons.access_time_outlined,
            'Duration',
            '${event.duration.inHours}h ${event.duration.inMinutes % 60}m',
          ),

          _buildEventDetailRow(
            Icons.people_outline,
            'Attendees',
            event.spotsRemainingText,
          ),

          if (event.registrationDeadline.isAfter(DateTime.now()))
            _buildEventDetailRow(
              Icons.schedule_outlined,
              'Registration Deadline',
              DateFormat(
                'MMM d, y • h:mm a',
              ).format(event.registrationDeadline),
            ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primarySageGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime() {
    final formatter = DateFormat('EEEE, MMMM d, y');
    final timeFormatter = DateFormat('h:mm a');

    return '${formatter.format(event.startTime)} at ${timeFormatter.format(event.startTime)}';
  }
}
