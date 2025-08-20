// // lib/features/events/widgets/event_card.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../../../../constants/app_colors.dart';
// import '../../../../constants/app_text_styles.dart';
// import '../../../../core/models/events_models.dart';
// import '../../../../core/subscriptions/subscription_manager.dart';
// import '../events_service.dart';

// class EventCard extends StatefulWidget {
//   final Event event;
//   final VoidCallback? onTap;
//   final bool showRegistrationStatus;
//   final bool isCompact;

//   const EventCard({
//     super.key,
//     required this.event,
//     this.onTap,
//     this.showRegistrationStatus = false,
//     this.isCompact = false, // Add this
//   });

//   @override
//   State<EventCard> createState() => _EventCardState();
// }

// class _EventCardState extends State<EventCard> {
//   final SubscriptionManager _subscriptionManager = SubscriptionManager();
//   EventRegistration? _userRegistration;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.showRegistrationStatus) {
//       _loadRegistrationStatus();
//     }
//   }

//   Future<void> _loadRegistrationStatus() async {
//     final registration = await EventsService.getUserRegistration(
//       widget.event.id,
//     );
//     if (mounted) {
//       setState(() {
//         _userRegistration = registration;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Cover Image with overlays
//             _buildCoverImage(),

//             // Content
//             Padding(
//               padding: EdgeInsets.all(
//                 widget.isCompact ? 12 : 16,
//               ), // Less padding for compact
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildTitleSection(),
//                   SizedBox(height: widget.isCompact ? 6 : 8),
//                   _buildEventDetails(),
//                   if (!widget.isCompact) ...[
//                     // Hide highlights in compact mode
//                     const SizedBox(height: 12),
//                     if (widget.event.highlights.isNotEmpty) _buildHighlights(),
//                   ],
//                   SizedBox(height: widget.isCompact ? 8 : 12),
//                   _buildBottomSection(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCoverImage() {
//     return Stack(
//       children: [
//         // Cover image
//         Container(
//           height: widget.isCompact ? 140 : 180,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//             image:
//                 widget.event.coverImageUrl.isNotEmpty
//                     ? DecorationImage(
//                       image: NetworkImage(widget.event.coverImageUrl),
//                       fit: BoxFit.cover,
//                     )
//                     : null,
//             gradient:
//                 widget.event.coverImageUrl.isEmpty
//                     ? LinearGradient(
//                       colors: [
//                         AppColors.primarySageGreen.withValues(alpha: 0.8),
//                         AppColors.primaryAccent.withValues(alpha: 0.6),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                     : null,
//           ),
//           child:
//               widget.event.coverImageUrl.isEmpty
//                   ? Center(
//                     child: Icon(Icons.event, size: 48, color: Colors.white),
//                   )
//                   : null,
//         ),

//         // Gradient overlay
//         Container(
//           height: 180,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
//             ),
//           ),
//         ),

//         // Top overlays
//         Positioned(top: 12, left: 12, child: _buildAccessBadge()),

//         Positioned(top: 12, right: 12, child: _buildCategoryBadge()),

//         // Registration status overlay
//         if (_userRegistration != null)
//           Positioned(bottom: 12, left: 12, child: _buildRegistrationBadge()),

//         // Spots remaining overlay
//         Positioned(bottom: 12, right: 12, child: _buildSpotsIndicator()),
//       ],
//     );
//   }

//   Widget _buildAccessBadge() {
//     Color badgeColor;
//     String badgeText;

//     switch (widget.event.accessType) {
//       case EventAccessType.public:
//         return const SizedBox.shrink(); // No badge for public events
//       case EventAccessType.freemiumLimited:
//         badgeColor = Colors.orange;
//         badgeText = 'LIMITED';
//         break;
//       case EventAccessType.premiumOnly:
//         badgeColor = AppColors.primaryGold;
//         badgeText = 'PREMIUM';
//         break;
//       case EventAccessType.eliteExclusive:
//         badgeColor = AppColors.primaryDarkBlue;
//         badgeText = 'ELITE';
//         break;
//       case EventAccessType.inviteOnly:
//         badgeColor = Colors.purple;
//         badgeText = 'INVITE';
//         break;
//       case EventAccessType.earlyAccess:
//         badgeColor = AppColors.primarySageGreen;
//         badgeText = 'EARLY';
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: badgeColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         badgeText,
//         style: AppTextStyles.caption.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 10,
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.6),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             widget.event.category.emoji,
//             style: const TextStyle(fontSize: 12),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             widget.event.category.displayName,
//             style: AppTextStyles.caption.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRegistrationBadge() {
//     Color badgeColor;
//     String badgeText;

//     switch (_userRegistration!.status) {
//       case RegistrationStatus.confirmed:
//         badgeColor = AppColors.primarySageGreen;
//         badgeText = 'REGISTERED';
//         break;
//       case RegistrationStatus.waitlisted:
//         badgeColor = Colors.orange;
//         badgeText = 'WAITLISTED';
//         break;
//       case RegistrationStatus.pending:
//         badgeColor = Colors.blue;
//         badgeText = 'PENDING';
//         break;
//       default:
//         return const SizedBox.shrink();
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: badgeColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.check_circle_outline, color: Colors.white, size: 12),
//           const SizedBox(width: 4),
//           Text(
//             badgeText,
//             style: AppTextStyles.caption.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpotsIndicator() {
//     final remaining = widget.event.maxAttendees - widget.event.currentAttendees;

//     Color indicatorColor = AppColors.primarySageGreen;
//     if (remaining <= 0) {
//       indicatorColor = Colors.red;
//     } else if (remaining <= 5) {
//       indicatorColor = Colors.orange;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: indicatorColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.2),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         widget.event.spotsRemainingText,
//         style: AppTextStyles.caption.copyWith(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 10,
//         ),
//       ),
//     );
//   }

//   Widget _buildTitleSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.event.title,
//                 style: AppTextStyles.heading3.copyWith(
//                   color: AppColors.textDark,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.event.shortDescription,
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.textMedium,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         if (widget.event.isEarlyBird) ...[
//           const SizedBox(width: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: AppColors.primaryGold.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: AppColors.primaryGold, width: 1),
//             ),
//             child: Text(
//               'EARLY BIRD',
//               style: AppTextStyles.caption.copyWith(
//                 color: AppColors.primaryGold,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 9,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildEventDetails() {
//     final dateFormatter = DateFormat('MMM d, y');
//     final timeFormatter = DateFormat('h:mm a');

//     return Column(
//       children: [
//         _buildDetailRow(
//           Icons.calendar_today_outlined,
//           '${dateFormatter.format(widget.event.startTime)} • ${timeFormatter.format(widget.event.startTime)}',
//         ),
//         const SizedBox(height: 4),
//         _buildDetailRow(
//           Icons.location_on_outlined,
//           '${widget.event.venue.name} • ${widget.event.venue.city}',
//         ),
//         const SizedBox(height: 4),
//         _buildDetailRow(
//           Icons.access_time_outlined,
//           '${widget.event.duration.inHours}h ${widget.event.duration.inMinutes % 60}m',
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: AppColors.textLight),
//         const SizedBox(width: 6),
//         Expanded(
//           child: Text(
//             text,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textMedium,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHighlights() {
//     return Wrap(
//       spacing: 6,
//       runSpacing: 4,
//       children:
//           widget.event.highlights.take(3).map((highlight) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: AppColors.primarySageGreen.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 highlight,
//                 style: AppTextStyles.caption.copyWith(
//                   color: AppColors.primarySageGreen,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             );
//           }).toList(),
//     );
//   }

//   Widget _buildBottomSection() {
//     return Row(
//       children: [
//         // Pricing
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildPricingInfo(),
//               if (widget.event.hostName.isNotEmpty) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   'Hosted by ${widget.event.hostName}',
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.textLight,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),

//         // Action button
//         _buildActionButton(),
//       ],
//     );
//   }

//   Widget _buildPricingInfo() {
//     final userTier = _subscriptionManager.currentTierName;
//     final price = widget.event.getPriceForTier(userTier);
//     final originalPrice = widget.event.pricing.freeUserPrice;

//     if (price == 0) {
//       return Text(
//         'FREE',
//         style: AppTextStyles.bodyLarge.copyWith(
//           color: AppColors.primarySageGreen,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//     }

//     return Row(
//       children: [
//         Text(
//           '\$${price.toStringAsFixed(0)}',
//           style: AppTextStyles.bodyLarge.copyWith(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         if (price < originalPrice) ...[
//           const SizedBox(width: 6),
//           Text(
//             '\$${originalPrice.toStringAsFixed(0)}',
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textLight,
//               decoration: TextDecoration.lineThrough,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildActionButton() {
//     // Check user access
//     if (!EventsService.canUserAccessEvent(widget.event)) {
//       return _buildUpgradeButton();
//     }

//     // If user is registered, show status
//     if (_userRegistration != null) {
//       return _buildRegisteredButton();
//     }

//     // Show register button
//     return _buildRegisterButton();
//   }

//   Widget _buildUpgradeButton() {
//     return ElevatedButton(
//       onPressed: () {
//         // TODO: Navigate to subscription upgrade
//         _showUpgradeDialog();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primaryGold,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.star, size: 16),
//           const SizedBox(width: 4),
//           Text(
//             'Upgrade',
//             style: AppTextStyles.bodySmall.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRegisteredButton() {
//     Color buttonColor;
//     String buttonText;
//     IconData buttonIcon;

//     switch (_userRegistration!.status) {
//       case RegistrationStatus.confirmed:
//         buttonColor = AppColors.primarySageGreen;
//         buttonText = 'Registered';
//         buttonIcon = Icons.check_circle;
//         break;
//       case RegistrationStatus.waitlisted:
//         buttonColor = Colors.orange;
//         buttonText = 'Waitlisted';
//         buttonIcon = Icons.schedule;
//         break;
//       case RegistrationStatus.pending:
//         buttonColor = Colors.blue;
//         buttonText = 'Pending';
//         buttonIcon = Icons.pending;
//         break;
//       default:
//         return _buildRegisterButton();
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: buttonColor.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: buttonColor),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(buttonIcon, size: 16, color: buttonColor),
//           const SizedBox(width: 4),
//           Text(
//             buttonText,
//             style: AppTextStyles.bodySmall.copyWith(
//               color: buttonColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRegisterButton() {
//     final isWaitlist =
//         widget.event.currentAttendees >= widget.event.maxAttendees;

//     return ElevatedButton(
//       onPressed: _isLoading ? null : _handleRegister,
//       style: ElevatedButton.styleFrom(
//         backgroundColor:
//             isWaitlist ? Colors.orange : AppColors.primarySageGreen,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child:
//           _isLoading
//               ? SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//               : Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(isWaitlist ? Icons.schedule : Icons.add, size: 16),
//                   const SizedBox(width: 4),
//                   Text(
//                     isWaitlist ? 'Join Waitlist' : 'Register',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//     );
//   }

//   Future<void> _handleRegister() async {
//     setState(() => _isLoading = true);

//     try {
//       final result = await EventsService.registerForEvent(
//         widget.event,
//         PaymentMethod.creditCard, // TODO: Let user choose
//       );

//       if (result.isSuccess) {
//         setState(() {
//           _userRegistration = result.registration;
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 result.registration!.status == RegistrationStatus.waitlisted
//                     ? 'Added to waitlist successfully!'
//                     : 'Registration successful!',
//               ),
//               backgroundColor: AppColors.primarySageGreen,
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(result.errorMessage ?? 'Registration failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _showUpgradeDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text('Upgrade Required'),
//             content: Text(
//               'This ${widget.event.accessType.displayName.toLowerCase()} event requires a ${widget.event.minimumTier} subscription or higher.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   // TODO: Navigate to subscription page
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryGold,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Upgrade Now'),
//               ),
//             ],
//           ),
//     );
//   }
// }

// // Extension for subscription manager
// extension SubscriptionManagerExtension on SubscriptionManager {
//   String get currentTierString {
//     if (hasEliteAccess) return 'elite';
//     if (hasPremiumAccess) return 'premium';
//     return 'free';
//   }
// }
