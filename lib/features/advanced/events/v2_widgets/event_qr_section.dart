// lib/features/events/widgets/components/event_qr_section.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_text_styles.dart';
import '../../../../../core/models/events_models.dart';

class EventQRSection extends StatelessWidget {
  final Event event;
  final EventRegistration? userRegistration;

  const EventQRSection({super.key, required this.event, this.userRegistration});

  @override
  Widget build(BuildContext context) {
    // Only show QR code if user is registered
    if (userRegistration == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySageGreen.withValues(alpha: 0.05),
            AppColors.primaryAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_rounded,
                color: AppColors.primarySageGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Event Ticket',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // QR Code
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _generateQRData(),
                  version: QrVersions.auto,
                  size: 80,
                  foregroundColor: AppColors.backgroundLight,
                ),
              ),
              const SizedBox(width: 16),
              // Ticket details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket ID',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userRegistration!.id.substring(0, 8).toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registered',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRegistrationDate(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barcode alternative
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomPaint(
              painter: BarcodePainter(data: userRegistration!.id),
              size: const Size(double.infinity, 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userRegistration!.id.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String chipText;

    switch (userRegistration!.status) {
      case RegistrationStatus.confirmed:
        chipColor = AppColors.primarySageGreen;
        chipText = 'CONFIRMED';
        break;
      case RegistrationStatus.waitlisted:
        chipColor = Colors.orange;
        chipText = 'WAITLISTED';
        break;
      case RegistrationStatus.pending:
        chipColor = Colors.blue;
        chipText = 'PENDING';
        break;
      default:
        chipColor = Colors.grey;
        chipText = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        chipText,
        style: AppTextStyles.caption.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _generateQRData() {
    return 'EVENT:${event.id}|USER:${userRegistration!.id}|STATUS:${userRegistration!.status.name}';
  }

  String _formatRegistrationDate() {
    // This would typically come from the registration object
    // For now, using current date as placeholder
    return 'Today'; // You can format this properly with your date
  }
}

// Custom painter for barcode-like design
class BarcodePainter extends CustomPainter {
  final String data;

  BarcodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    // Generate barcode-like pattern based on data hash
    final hash = data.hashCode;
    final barWidth = size.width / 40;

    for (int i = 0; i < 40; i++) {
      // Create pseudo-random bar heights based on hash and position
      final shouldDrawBar = (hash >> (i % 16)) & 1 == 1;
      final isThick = (hash >> ((i + 8) % 16)) & 1 == 1;

      if (shouldDrawBar) {
        final height = isThick ? size.height : size.height * 0.6;
        final rect = Rect.fromLTWH(
          i * barWidth,
          (size.height - height) / 2,
          barWidth * 0.8,
          height,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
