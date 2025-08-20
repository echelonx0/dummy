// lib/core/models/event_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventAccessType {
  public,           // Free for all users
  freemiumLimited,  // Free users: view only, limited spots
  premiumOnly,      // Premium+ subscribers only
  eliteExclusive,   // Elite tier exclusive events
  inviteOnly,       // Curated invite-based
  earlyAccess,      // Premium gets early registration
}

enum EventCategory {
  speedDating,      // Premium: unlimited rounds, Free: 3 rounds
  workshops,        // "Dating Skills Masterclass" 
  dinnerParties,    // Intimate 8-12 person curated groups
  mixers,           // Large social events
  retreats,         // Weekend relationship retreats
  concierge,        // 1:1 matchmaker events
  activities,       // Hiking, cooking classes, etc.
  virtual,          // Online speed dating, workshops
  seasonal,         // Holiday parties, summer events
}

enum EventStatus {
  draft,
  published,
  registrationOpen,
  registrationClosed,
  inProgress,
  completed,
  cancelled,
}

enum VenueType {
  restaurant, 
  bar, 
  coworking, 
  private, 
  outdoor, 
  virtual, 
  hotel,
}

enum RegistrationStatus {
  pending,        // Awaiting payment/approval
  confirmed,      // Paid and confirmed
  waitlisted,     // On waitlist
  cancelled,      // User cancelled
  noShow,         // Didn't attend
  attended,       // Successfully attended
}

enum PaymentMethod {
  creditCard,
  applePay,
  googlePay,
  premiumCredit,  // Using subscription credits
  free,
}

// Extensions for display
extension EventAccessTypeExtension on EventAccessType {
  String get displayName {
    switch (this) {
      case EventAccessType.public:
        return 'Public';
      case EventAccessType.freemiumLimited:
        return 'Limited Access';
      case EventAccessType.premiumOnly:
        return 'Premium Only';
      case EventAccessType.eliteExclusive:
        return 'Elite Exclusive';
      case EventAccessType.inviteOnly:
        return 'Invite Only';
      case EventAccessType.earlyAccess:
        return 'Early Access';
    }
  }

  String get description {
    switch (this) {
      case EventAccessType.public:
        return 'Open to all users';
      case EventAccessType.freemiumLimited:
        return 'Free users have limited access';
      case EventAccessType.premiumOnly:
        return 'Premium subscribers only';
      case EventAccessType.eliteExclusive:
        return 'Elite tier members only';
      case EventAccessType.inviteOnly:
        return 'By invitation only';
      case EventAccessType.earlyAccess:
        return 'Premium users get early access';
    }
  }
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.speedDating:
        return 'Speed Dating';
      case EventCategory.workshops:
        return 'Workshops';
      case EventCategory.dinnerParties:
        return 'Dinner Parties';
      case EventCategory.mixers:
        return 'Social Mixers';
      case EventCategory.retreats:
        return 'Retreats';
      case EventCategory.concierge:
        return 'Concierge Events';
      case EventCategory.activities:
        return 'Activities';
      case EventCategory.virtual:
        return 'Virtual Events';
      case EventCategory.seasonal:
        return 'Seasonal Events';
    }
  }

  String get emoji {
    switch (this) {
      case EventCategory.speedDating:
        return '⚡';
      case EventCategory.workshops:
        return '🎓';
      case EventCategory.dinnerParties:
        return '🍽️';
      case EventCategory.mixers:
        return '🥂';
      case EventCategory.retreats:
        return '🏔️';
      case EventCategory.concierge:
        return '👨‍💼';
      case EventCategory.activities:
        return '🎯';
      case EventCategory.virtual:
        return '💻';
      case EventCategory.seasonal:
        return '🎉';
    }
  }
}

// Core Models
class EventPricing {
  final double freeUserPrice;
  final double premiumPrice;
  final double elitePrice;
  final double earlyBirdDiscount;
  final bool hasWaitlistFee;
  final double waitlistFee;

  const EventPricing({
    required this.freeUserPrice,
    required this.premiumPrice,
    required this.elitePrice,
    this.earlyBirdDiscount = 0.0,
    this.hasWaitlistFee = false,
    this.waitlistFee = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'freeUserPrice': freeUserPrice,
      'premiumPrice': premiumPrice,
      'elitePrice': elitePrice,
      'earlyBirdDiscount': earlyBirdDiscount,
      'hasWaitlistFee': hasWaitlistFee,
      'waitlistFee': waitlistFee,
    };
  }

  factory EventPricing.fromMap(Map<String, dynamic> map) {
    return EventPricing(
      freeUserPrice: (map['freeUserPrice'] ?? 0.0).toDouble(),
      premiumPrice: (map['premiumPrice'] ?? 0.0).toDouble(),
      elitePrice: (map['elitePrice'] ?? 0.0).toDouble(),
      earlyBirdDiscount: (map['earlyBirdDiscount'] ?? 0.0).toDouble(),
      hasWaitlistFee: map['hasWaitlistFee'] ?? false,
      waitlistFee: (map['waitlistFee'] ?? 0.0).toDouble(),
    );
  }
}

class Venue {
  final String id;
  final String name;
  final String address;
  final GeoPoint? location;
  final String city;
  final VenueType type;
  final Map<String, dynamic> amenities;
  final List<String> photos;
  final String description;
  final bool isPartner;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    this.location,
    required this.city,
    required this.type,
    this.amenities = const {},
    this.photos = const [],
    this.description = '',
    this.isPartner = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'city': city,
      'type': type.name,
      'amenities': amenities,
      'photos': photos,
      'description': description,
      'isPartner': isPartner,
    };
  }

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      location: map['location'],
      city: map['city'] ?? '',
      type: VenueType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => VenueType.private,
      ),
      amenities: Map<String, dynamic>.from(map['amenities'] ?? {}),
      photos: List<String>.from(map['photos'] ?? []),
      description: map['description'] ?? '',
      isPartner: map['isPartner'] ?? false,
    );
  }
}

class Event {
  // Basic Info
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final EventCategory category;
  final EventAccessType accessType;
  
  // Venue & Timing
  final Venue venue;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String timeZone;
  
  // Access Control
  final String minimumTier; // 'free', 'premium', 'elite'
  final List<String> requiredTags;
  final int maxAttendees;
  final int minAttendees;
  final int currentAttendees;
  final bool waitlistEnabled;
  
  // Pricing
  final EventPricing pricing;
  final DateTime? earlyBirdDeadline;
  final DateTime registrationDeadline;
  
  // Content
  final List<String> imageUrls;
  final String coverImageUrl;
  final String hostName;
  final String hostBio;
  final List<String> highlights;
  
  // Status
  final EventStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.category,
    required this.accessType,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.timeZone,
    required this.minimumTier,
    this.requiredTags = const [],
    required this.maxAttendees,
    this.minAttendees = 1,
    this.currentAttendees = 0,
    this.waitlistEnabled = true,
    required this.pricing,
    this.earlyBirdDeadline,
    required this.registrationDeadline,
    this.imageUrls = const [],
    this.coverImageUrl = '',
    required this.hostName,
    this.hostBio = '',
    this.highlights = const [],
    this.status = EventStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'category': category.name,
      'accessType': accessType.name,
      'venue': venue.toMap(),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'duration': duration.inMinutes,
      'timeZone': timeZone,
      'minimumTier': minimumTier,
      'requiredTags': requiredTags,
      'maxAttendees': maxAttendees,
      'minAttendees': minAttendees,
      'currentAttendees': currentAttendees,
      'waitlistEnabled': waitlistEnabled,
      'pricing': pricing.toMap(),
      'earlyBirdDeadline': earlyBirdDeadline != null 
        ? Timestamp.fromDate(earlyBirdDeadline!) 
        : null,
      'registrationDeadline': Timestamp.fromDate(registrationDeadline),
      'imageUrls': imageUrls,
      'coverImageUrl': coverImageUrl,
      'hostName': hostName,
      'hostBio': hostBio,
      'highlights': highlights,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      category: EventCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => EventCategory.mixers,
      ),
      accessType: EventAccessType.values.firstWhere(
        (e) => e.name == map['accessType'],
        orElse: () => EventAccessType.public,
      ),
      venue: Venue.fromMap(Map<String, dynamic>.from(map['venue'] ?? {})),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      duration: Duration(minutes: map['duration'] ?? 0),
      timeZone: map['timeZone'] ?? 'UTC',
      minimumTier: map['minimumTier'] ?? 'free',
      requiredTags: List<String>.from(map['requiredTags'] ?? []),
      maxAttendees: map['maxAttendees'] ?? 0,
      minAttendees: map['minAttendees'] ?? 1,
      currentAttendees: map['currentAttendees'] ?? 0,
      waitlistEnabled: map['waitlistEnabled'] ?? true,
      pricing: EventPricing.fromMap(Map<String, dynamic>.from(map['pricing'] ?? {})),
      earlyBirdDeadline: map['earlyBirdDeadline'] != null 
        ? (map['earlyBirdDeadline'] as Timestamp).toDate()
        : null,
      registrationDeadline: (map['registrationDeadline'] as Timestamp).toDate(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      coverImageUrl: map['coverImageUrl'] ?? '',
      hostName: map['hostName'] ?? '',
      hostBio: map['hostBio'] ?? '',
      highlights: List<String>.from(map['highlights'] ?? []),
      status: EventStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EventStatus.draft,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
        ? (map['updatedAt'] as Timestamp).toDate()
        : null,
      cancelledAt: map['cancelledAt'] != null 
        ? (map['cancelledAt'] as Timestamp).toDate()
        : null,
      cancellationReason: map['cancellationReason'],
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    EventCategory? category,
    EventAccessType? accessType,
    Venue? venue,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? timeZone,
    String? minimumTier,
    List<String>? requiredTags,
    int? maxAttendees,
    int? minAttendees,
    int? currentAttendees,
    bool? waitlistEnabled,
    EventPricing? pricing,
    DateTime? earlyBirdDeadline,
    DateTime? registrationDeadline,
    List<String>? imageUrls,
    String? coverImageUrl,
    String? hostName,
    String? hostBio,
    List<String>? highlights,
    EventStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      accessType: accessType ?? this.accessType,
      venue: venue ?? this.venue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      timeZone: timeZone ?? this.timeZone,
      minimumTier: minimumTier ?? this.minimumTier,
      requiredTags: requiredTags ?? this.requiredTags,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      minAttendees: minAttendees ?? this.minAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      waitlistEnabled: waitlistEnabled ?? this.waitlistEnabled,
      pricing: pricing ?? this.pricing,
      earlyBirdDeadline: earlyBirdDeadline ?? this.earlyBirdDeadline,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      imageUrls: imageUrls ?? this.imageUrls,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      hostName: hostName ?? this.hostName,
      hostBio: hostBio ?? this.hostBio,
      highlights: highlights ?? this.highlights,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  // Helper methods
  bool get isRegistrationOpen {
    final now = DateTime.now();
    return status == EventStatus.registrationOpen &&
           now.isBefore(registrationDeadline) &&
           currentAttendees < maxAttendees;
  }

  bool get isWaitlistAvailable {
    return waitlistEnabled && 
           currentAttendees >= maxAttendees &&
           DateTime.now().isBefore(registrationDeadline);
  }

  bool get isEarlyBird {
    if (earlyBirdDeadline == null) return false;
    return DateTime.now().isBefore(earlyBirdDeadline!);
  }

  double getPriceForTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return isEarlyBird 
          ? pricing.freeUserPrice * (1 - pricing.earlyBirdDiscount)
          : pricing.freeUserPrice;
      case 'premium':
        return isEarlyBird 
          ? pricing.premiumPrice * (1 - pricing.earlyBirdDiscount)
          : pricing.premiumPrice;
      case 'elite':
        return isEarlyBird 
          ? pricing.elitePrice * (1 - pricing.earlyBirdDiscount)
          : pricing.elitePrice;
      default:
        return pricing.freeUserPrice;
    }
  }

  String get spotsRemainingText {
    final remaining = maxAttendees - currentAttendees;
    if (remaining <= 0) return 'Sold out';
    if (remaining == 1) return '1 spot left';
    if (remaining <= 5) return '$remaining spots left';
    return '$currentAttendees/$maxAttendees attending';
  }
}

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final double amountPaid;
  final PaymentMethod paymentMethod;
  final String? waitlistPosition;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    required this.amountPaid,
    required this.paymentMethod,
    this.waitlistPosition,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'status': status.name,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod.name,
      'waitlistPosition': waitlistPosition,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  factory EventRegistration.fromMap(Map<String, dynamic> map) {
    return EventRegistration(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      status: RegistrationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RegistrationStatus.pending,
      ),
      registeredAt: (map['registeredAt'] as Timestamp).toDate(),
      amountPaid: (map['amountPaid'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      waitlistPosition: map['waitlistPosition'],
      confirmedAt: map['confirmedAt'] != null 
        ? (map['confirmedAt'] as Timestamp).toDate()
        : null,
      cancelledAt: map['cancelledAt'] != null 
        ? (map['cancelledAt'] as Timestamp).toDate()
        : null,
      cancellationReason: map['cancellationReason'],
    );
  }
}
