// lib/core/services/feature_flag_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'feature_flag.dart';

class FeatureFlagService extends ChangeNotifier {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, FeatureFlag> _flags = {};
  StreamSubscription? _flagsSubscription;
  bool _isInitialized = false;

  // Public getters
  bool get isInitialized => _isInitialized;
  Map<String, FeatureFlag> get flags => Map.from(_flags);

  // Initialize service - call this in main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    _debugLog('Initializing FeatureFlagService...');

    try {
      // Start listening to flags collection
      _flagsSubscription = _firestore
          .collection('app_config')
          .doc('feature_flags')
          .collection('flags')
          .snapshots()
          .listen(_onFlagsUpdate, onError: _onFlagsError);

      // Wait for initial data
      await _waitForInitialData();
      _isInitialized = true;
      _debugLog('FeatureFlagService initialized successfully');
    } catch (e) {
      _debugLog('Error initializing FeatureFlagService: $e');
      _isInitialized = true; // Continue with empty flags
    }
  }

  /// Checks if basic flags exist, if not adds them
  Future<void> setupDefaultFlags() async {
    _debugLog('Checking default feature flags in Firestore...');

    final flagsCollection = _firestore
        .collection('app_config')
        .doc('feature_flags')
        .collection('flags');

    final snapshot = await flagsCollection.get();

    if (snapshot.docs.isNotEmpty) {
      _debugLog('Feature flags already exist in Firestore. Skipping setup.');
      return; // flags exist, skip adding
    }

    _debugLog('No feature flags found, adding default flags...');

    final defaultFlags = <String, Map<String, dynamic>>{
      'new_ui_enabled': {
        'isEnabled': false,
        'enabledForUserIds': [],
        'enabledForTiers': ['premium'],
        'enabledUntil': null,
        'metadata': {'description': 'Toggle new UI'},
      },
      'beta_feature_x': {
        'isEnabled': false,
        'enabledForUserIds': [],
        'enabledForTiers': [],
        'enabledUntil': null,
        'metadata': {'description': 'Beta Feature X test'},
      },
      'subscription_management_enabled': {
        'isEnabled': false,
        'enabledForUserIds': [],
        'enabledForTiers': [],
        'enabledUntil': null,
        'metadata': {'description': 'Subscription featues'},
      },
      'global_flag': {
        'isEnabled': false,
        'enabledForUserIds': [],
        'enabledForTiers': [],
        'enabledUntil': null,
        'metadata': {'description': 'General Flag Manager'},
      },
    };

    final batch = _firestore.batch();

    defaultFlags.forEach((flagId, data) {
      final docRef = flagsCollection.doc(flagId);
      batch.set(docRef, data);
    });

    try {
      await batch.commit();
      _debugLog('Default feature flags added successfully.');
    } catch (e) {
      _debugLog('Error adding default feature flags: $e');
    }
  }

  /// Call this in main.dart to initialize service and ensure default flags exist
  Future<void> initializeAndSetupDefaults() async {
    await initialize(); // existing init
    await setupDefaultFlags(); // new function to add defaults if needed
  }

  Future<void> _waitForInitialData() async {
    final completer = Completer<void>();
    Timer? timeoutTimer;

    timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        _debugLog('Timeout waiting for initial flags data');
        completer.complete();
      }
    });

    void checkCompletion() {
      if (_flags.isNotEmpty && !completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete();
      }
    }

    addListener(checkCompletion); // ✅ just call it

    await completer.future;

    removeListener(checkCompletion); // ✅ remove with same function
    timeoutTimer.cancel();
  }

  void _onFlagsUpdate(QuerySnapshot snapshot) {
    _debugLog('Received ${snapshot.docs.length} feature flags');

    final newFlags = <String, FeatureFlag>{};

    for (final doc in snapshot.docs) {
      try {
        final flag = FeatureFlag.fromFirestore(doc);
        newFlags[flag.id] = flag;
      } catch (e) {
        _debugLog('Error parsing flag ${doc.id}: $e');
      }
    }

    _flags = newFlags;
    notifyListeners();
    _debugLog('Updated ${_flags.length} feature flags');
  }

  void _onFlagsError(error) {
    _debugLog('Error listening to feature flags: $error');
  }

  // Main method - check if feature is enabled
  bool isEnabled(String flagId) {
    final flag = _flags[flagId];
    if (flag == null) {
      _debugLog('Flag not found: $flagId, defaulting to false');
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _debugLog('No authenticated user, using global flag state');
      return flag.isEnabled;
    }

    // TODO: Get user tier from user profile
    final userTier = 'free'; // Replace with actual user tier logic

    final isEnabled = flag.isEnabledForUser(
      userId: user.uid,
      userTier: userTier,
    );

    _debugLog('Flag $flagId for user ${user.uid}: $isEnabled');
    return isEnabled;
  }

  // Get flag metadata (for A/B testing, etc.)
  Map<String, dynamic>? getFlagMetadata(String flagId) {
    return _flags[flagId]?.metadata;
  }

  // Check multiple flags at once
  Map<String, bool> isEnabledBatch(List<String> flagIds) {
    return {for (final flagId in flagIds) flagId: isEnabled(flagId)};
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      print('[FeatureFlagService] $message');
    }
  }

  @override
  void dispose() {
    _flagsSubscription?.cancel();
    super.dispose();
  }
}
