// lib/features/events/services/events_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/events_models.dart';
import '../../../core/subscriptions/subscription_manager.dart';

class EventsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final SubscriptionManager _subscriptionManager = SubscriptionManager();

  /// Gets events with subscription-based filtering
  static Future<List<Event>> getEvents({
    EventCategory? category,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('events')
          .where('status', isEqualTo: EventStatus.registrationOpen.name)
          .orderBy('startTime');

      // Apply filters
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (city != null) {
        query = query.where('venue.city', isEqualTo: city);
      }

      if (startDate != null) {
        query = query.where(
          'startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'startTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      // Pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final events =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Event.fromMap(data);
          }).toList();

      // Filter based on user's subscription access
      return _filterEventsByAccess(events);
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  /// Filter events based on user's subscription tier
  static List<Event> _filterEventsByAccess(List<Event> events) {
    //TODO: Check this
    final userTier = _subscriptionManager.currentTier;

    return events.where((event) {
      switch (event.accessType) {
        case EventAccessType.public:
          return true;
        case EventAccessType.freemiumLimited:
          return true; // Show but with limited functionality
        case EventAccessType.premiumOnly:
          return _subscriptionManager.hasPremiumAccess;
        case EventAccessType.eliteExclusive:
          return _subscriptionManager.hasEliteAccess;
        case EventAccessType.inviteOnly:
          return false; // TODO: Check invites
        case EventAccessType.earlyAccess:
          // Show if premium user OR early access period has ended
          return _subscriptionManager.hasPremiumAccess ||
              DateTime.now().isAfter(
                event.startTime.subtract(const Duration(days: 2)),
              );
      }
    }).toList();
  }

  /// Check if user can access an event
  static bool canUserAccessEvent(Event event) {
    switch (event.accessType) {
      case EventAccessType.public:
        return true;
      case EventAccessType.freemiumLimited:
        return true;
      case EventAccessType.premiumOnly:
        return _subscriptionManager.hasPremiumAccess;
      case EventAccessType.eliteExclusive:
        return _subscriptionManager.hasEliteAccess;
      case EventAccessType.inviteOnly:
        return false; // TODO: Check user invites
      case EventAccessType.earlyAccess:
        return _subscriptionManager.hasPremiumAccess;
    }
  }

  /// Get user's registration status for an event
  static Future<EventRegistration?> getUserRegistration(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot =
          await _firestore
              .collection('events')
              .doc(eventId)
              .collection('registrations')
              .where('userId', isEqualTo: user.uid)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return EventRegistration.fromMap(data);
    } catch (e) {
      print('Error getting user registration: $e');
      return null;
    }
  }

  /// Register user for an event
  static Future<EventRegistrationResult> registerForEvent(
    Event event,
    PaymentMethod paymentMethod,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EventRegistrationResult.error('User not authenticated');
      }

      // Check access
      if (!canUserAccessEvent(event)) {
        return EventRegistrationResult.error('Insufficient subscription tier');
      }

      // Check if already registered
      final existingRegistration = await getUserRegistration(event.id);
      if (existingRegistration != null) {
        return EventRegistrationResult.error('Already registered');
      }

      // Check capacity
      if (!event.isRegistrationOpen && !event.isWaitlistAvailable) {
        return EventRegistrationResult.error('Registration closed');
      }

      // Calculate price
      final userTier = _subscriptionManager.currentTierString;
      final price = event.getPriceForTier(userTier);

      // Determine registration status
      final isWaitlist = event.currentAttendees >= event.maxAttendees;
      final status =
          isWaitlist
              ? RegistrationStatus.waitlisted
              : RegistrationStatus.pending;

      // Create registration
      final registration = EventRegistration(
        id: '', // Will be set by Firestore
        eventId: event.id,
        userId: user.uid,
        status: status,
        registeredAt: DateTime.now(),
        amountPaid: price,
        paymentMethod: paymentMethod,
        waitlistPosition:
            isWaitlist
                ? '${event.currentAttendees - event.maxAttendees + 1}'
                : null,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .add(registration.toMap());

      // Update event attendee count if not waitlisted
      if (!isWaitlist) {
        await _firestore.collection('events').doc(event.id).update({
          'currentAttendees': FieldValue.increment(1),
        });
      }

      // TODO: Process payment here

      // Confirm registration if payment successful
      await _firestore
          .collection('events')
          .doc(event.id)
          .collection('registrations')
          .doc(docRef.id)
          .update({
            'status':
                isWaitlist
                    ? RegistrationStatus.waitlisted.name
                    : RegistrationStatus.confirmed.name,
            'confirmedAt': Timestamp.fromDate(DateTime.now()),
          });

      return EventRegistrationResult.success(
        registration.copyWith(
          id: docRef.id,
          status:
              isWaitlist
                  ? RegistrationStatus.waitlisted
                  : RegistrationStatus.confirmed,
          confirmedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Error registering for event: $e');
      return EventRegistrationResult.error('Registration failed: $e');
    }
  }

  /// Cancel event registration
  static Future<bool> cancelRegistration(
    String eventId,
    String registrationId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Update registration status
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('registrations')
          .doc(registrationId)
          .update({
            'status': RegistrationStatus.cancelled.name,
            'cancelledAt': Timestamp.fromDate(DateTime.now()),
            'cancellationReason': 'User cancellation',
          });

      // Decrease attendee count
      await _firestore.collection('events').doc(eventId).update({
        'currentAttendees': FieldValue.increment(-1),
      });

      // TODO: Process refund if applicable

      return true;
    } catch (e) {
      print('Error cancelling registration: $e');
      return false;
    }
  }

  /// Get user's registered events
  static Future<List<Event>> getUserEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Get all registrations for user
      final registrationsSnapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('userId', isEqualTo: user.uid)
              .where(
                'status',
                whereIn: [
                  RegistrationStatus.confirmed.name,
                  RegistrationStatus.waitlisted.name,
                ],
              )
              .get();

      if (registrationsSnapshot.docs.isEmpty) return [];

      // Get event IDs
      final eventIds =
          registrationsSnapshot.docs
              .map((doc) => doc.data()['eventId'] as String)
              .toSet()
              .toList();

      // Get events
      final events = <Event>[];
      for (final eventId in eventIds) {
        final eventDoc =
            await _firestore.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          final data = eventDoc.data()!;
          data['id'] = eventDoc.id;
          events.add(Event.fromMap(data));
        }
      }

      // Sort by start time
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
      return events;
    } catch (e) {
      print('Error getting user events: $e');
      return [];
    }
  }

  /// Get upcoming events (next 7 days)
  static Future<List<Event>> getUpcomingEvents() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return getEvents(startDate: now, endDate: nextWeek, limit: 10);
  }

  /// Get events by category with premium prioritization
  static Future<List<Event>> getEventsByCategory(EventCategory category) async {
    final events = await getEvents(category: category);

    // Sort by access type (premium events first for premium users)
    if (_subscriptionManager.hasPremiumAccess) {
      events.sort((a, b) {
        // Premium/Elite events first
        if (a.accessType == EventAccessType.premiumOnly ||
            a.accessType == EventAccessType.eliteExclusive) {
          return -1;
        }
        if (b.accessType == EventAccessType.premiumOnly ||
            b.accessType == EventAccessType.eliteExclusive) {
          return 1;
        }
        return a.startTime.compareTo(b.startTime);
      });
    }

    return events;
  }

  /// Get recommended events based on user profile
  static Future<List<Event>> getRecommendedEvents() async {
    // TODO: Implement ML-based recommendations
    // For now, return upcoming events with premium prioritization
    return getUpcomingEvents();
  }

  /// Search events
  static Future<List<Event>> searchEvents(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll implement basic filtering
      final allEvents = await getEvents(limit: 100);

      final searchQuery = query.toLowerCase();
      return allEvents.where((event) {
        return event.title.toLowerCase().contains(searchQuery) ||
            event.description.toLowerCase().contains(searchQuery) ||
            event.category.displayName.toLowerCase().contains(searchQuery) ||
            event.venue.name.toLowerCase().contains(searchQuery) ||
            event.venue.city.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
}

// Registration result wrapper
class EventRegistrationResult {
  final bool isSuccess;
  final EventRegistration? registration;
  final String? errorMessage;

  const EventRegistrationResult._({
    required this.isSuccess,
    this.registration,
    this.errorMessage,
  });

  factory EventRegistrationResult.success(EventRegistration registration) {
    return EventRegistrationResult._(
      isSuccess: true,
      registration: registration,
    );
  }

  factory EventRegistrationResult.error(String message) {
    return EventRegistrationResult._(isSuccess: false, errorMessage: message);
  }
}

// Extension for subscription manager integration
extension SubscriptionManagerEventExtension on SubscriptionManager {
  String get currentTierString {
    if (hasEliteAccess) return 'elite';
    if (hasPremiumAccess) return 'premium';
    return 'free';
  }
}

// Registration extension for EventRegistration
extension EventRegistrationExtension on EventRegistration {
  EventRegistration copyWith({
    String? id,
    String? eventId,
    String? userId,
    RegistrationStatus? status,
    DateTime? registeredAt,
    double? amountPaid,
    PaymentMethod? paymentMethod,
    String? waitlistPosition,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return EventRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      waitlistPosition: waitlistPosition ?? this.waitlistPosition,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
