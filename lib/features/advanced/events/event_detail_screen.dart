// lib/features/events/screens/event_detail_screen.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/models/events_models.dart';
import '../../../core/subscriptions/subscription_manager.dart';

import 'events_service.dart';
import 'widgets/event_action_buttons.dart';
import 'widgets/event_content_cards.dart';
import 'widgets/event_detail_app_bar.dart';
import 'widgets/event_dialogs.dart';
import 'widgets/event_info_card.dart';
import 'widgets/event_pricing_card.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  EventRegistration? _userRegistration;
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadRegistrationStatus();
  }

  Future<void> _loadRegistrationStatus() async {
    setState(() => _isLoading = true);

    final registration = await EventsService.getUserRegistration(
      widget.event.id,
    );

    if (mounted) {
      setState(() {
        _userRegistration = registration;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            slivers: [
              EventDetailAppBar(
                event: widget.event,
                userRegistration: _userRegistration,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    EventInfoCard(event: widget.event),
                    EventDescriptionCard(event: widget.event),
                    EventVenueCard(event: widget.event),
                    EventHostCard(event: widget.event),
                    EventHighlightsCard(event: widget.event),
                    EventPricingCard(
                      event: widget.event,
                      subscriptionManager: _subscriptionManager,
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          ),

          // Bottom action button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EventBottomActionBar(
              event: widget.event,
              userRegistration: _userRegistration,
              subscriptionManager: _subscriptionManager,
              isRegistering: _isRegistering,
              onRegister: _handleRegister,
              onCancel: _showCancelDialog,
              onUpgrade: _showUpgradeDialog,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _isRegistering = true);

    try {
      final result = await EventsService.registerForEvent(
        widget.event,
        PaymentMethod.creditCard, // TODO: Let user choose payment method
      );

      if (result.isSuccess) {
        setState(() {
          _userRegistration = result.registration;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.registration!.status == RegistrationStatus.waitlisted
                    ? 'Successfully joined the waitlist!'
                    : 'Registration successful!',
              ),
              backgroundColor: AppColors.primarySageGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showUpgradeDialog() {
    EventUpgradeDialog.show(
      context: context,
      event: widget.event,
      onUpgradePressed: () {
        // TODO: Navigate to subscription upgrade page
      },
    );
  }

  void _showCancelDialog() {
    EventCancelDialog.show(context: context, onConfirmCancel: _handleCancel);
  }

  Future<void> _handleCancel() async {
    if (_userRegistration == null) return;

    try {
      final success = await EventsService.cancelRegistration(
        widget.event.id,
        _userRegistration!.id,
      );

      if (success) {
        setState(() {
          _userRegistration = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration cancelled successfully'),
              backgroundColor: AppColors.primarySageGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel registration'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
