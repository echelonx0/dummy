// lib/features/events/widgets/event_card_widget.dart
import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/models/events_models.dart';
import '../../../../core/subscriptions/subscription_manager.dart';
import '../events_service.dart';
import 'event_card_actions.dart';
import 'event_card_content.dart';
import 'event_card_header.dart';
import 'event_qr_section.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showRegistrationStatus;
  final bool isCompact;
  final bool startExpanded;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showRegistrationStatus = false,
    this.isCompact = false,
    this.startExpanded = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with TickerProviderStateMixin {
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  EventRegistration? _userRegistration;
  bool _isLoading = false;
  bool _isExpanded = false;

  // Animation controllers
  late AnimationController _expandController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _expandAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.startExpanded;

    // Initialize animation controllers
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create animations
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Load registration status if needed
    if (widget.showRegistrationStatus) {
      _loadRegistrationStatus();
    }

    // Set initial expansion state
    if (_isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrationStatus() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final registration = await EventsService.getUserRegistration(
        widget.event.id,
      );

      if (mounted) {
        setState(() {
          _userRegistration = registration;
          _isLoading = false;
        });

        // Start shimmer effect if registered
        if (registration != null) {
          _shimmerController.repeat(reverse: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 6 : 8,
                vertical: widget.isCompact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                    blurRadius: _isExpanded ? 20 : 15,
                    offset: const Offset(0, 6),
                    spreadRadius: _isExpanded ? 2 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect for registered events
                  if (_userRegistration != null) _buildShimmerEffect(),

                  // Main card content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with cover image and badges
                      EventCardHeader(
                        event: widget.event,
                        userRegistration: _userRegistration,
                        isCompact: widget.isCompact,
                      ),

                      // Basic content
                      EventCardContent(
                        event: widget.event,
                        isCompact: widget.isCompact,
                        isExpanded: _isExpanded,
                      ),

                      // Expandable QR section (only if registered)
                      AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, child) {
                          return SizeTransition(
                            sizeFactor: _expandAnimation,
                            child: EventQRSection(
                              event: widget.event,
                              userRegistration: _userRegistration,
                            ),
                          );
                        },
                      ),

                      // Actions section
                      EventCardActions(
                        event: widget.event,
                        userRegistration: _userRegistration,
                        subscriptionManager: _subscriptionManager,
                        isLoading: _isLoading,
                        isExpanded: _isExpanded,
                        isCompact: widget.isCompact,
                        onRegister: _handleRegister,
                        onUpgrade: _showUpgradeDialog,
                        onExpand: _toggleExpanded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    AppColors.primarySageGreen.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: [
                    (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                    _shimmerAnimation.value.clamp(0.0, 1.0),
                    (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await EventsService.registerForEvent(
        widget.event,
        PaymentMethod.creditCard,
      );

      if (result.isSuccess && mounted) {
        setState(() {
          _userRegistration = result.registration;
        });

        // Start shimmer effect for successful registration
        _shimmerController.repeat(reverse: true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.registration!.status == RegistrationStatus.waitlisted
                  ? 'Successfully joined the waitlist!'
                  : 'Registration successful!',
            ),
            backgroundColor: AppColors.primarySageGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.star_rounded, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Text('Upgrade Required'),
              ],
            ),
            content: Text(
              'This ${widget.event.accessType.displayName.toLowerCase()} event requires a ${widget.event.minimumTier} subscription or higher.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to subscription upgrade page
                },
                icon: Icon(Icons.star_rounded, size: 16),
                label: Text('Upgrade Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
