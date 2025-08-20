// lib/features/events/widgets/event_dialogs.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/models/events_models.dart';

class EventUpgradeDialog extends StatelessWidget {
  final Event event;
  final VoidCallback onUpgradePressed;

  const EventUpgradeDialog({
    super.key,
    required this.event,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upgrade Required'),
      content: Text(
        'This ${event.accessType.displayName.toLowerCase()} event requires a ${event.minimumTier} subscription or higher.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onUpgradePressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            foregroundColor: Colors.white,
          ),
          child: Text('Upgrade Now'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required Event event,
    required VoidCallback onUpgradePressed,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => EventUpgradeDialog(
            event: event,
            onUpgradePressed: onUpgradePressed,
          ),
    );
  }
}

class EventCancelDialog extends StatelessWidget {
  final VoidCallback onConfirmCancel;

  const EventCancelDialog({super.key, required this.onConfirmCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Registration'),
      content: Text(
        'Are you sure you want to cancel your registration for this event?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Keep Registration'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmCancel();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Cancel Registration'),
        ),
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirmCancel,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EventCancelDialog(onConfirmCancel: onConfirmCancel),
    );
  }
}
