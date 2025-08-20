// lib/main.dart
import 'dart:io';

import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide LogLevel;
import 'admin/feature_flags/feature_flag_service.dart';
import 'app/app.dart';
import 'app/locator.dart';
import 'firebase_options.dart';

// Move initPlatformState outside main
Future<void> initPlatformState() async {
  // await Purchases.setDebugLogsEnabled(true); // Remove this in production

  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("goog_GqixNuzJZEKcaKigeGkCgHHyHHY");
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration("appl_XZHVobbyqqKdsnxkfvHiBWDRSqh");
  } else {
    // Other platforms
    return;
  }

  await Purchases.configure(configuration);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = ClarityConfig(
    projectId: "s0quarq78o",
    logLevel:
        LogLevel
            .None, // Note: Use "LogLevel.Verbose" value while testing to debug initialization issues.
  );
  // Initialize RevenueCat
  await initPlatformState();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Feature Flags
  // Setup service locator
  setupLocator();

  await FeatureFlagService().initializeAndSetupDefaults();

  runApp(
    ClarityWidget(
      app: KeyboardDismissWrapper(child: const App()),
      clarityConfig: config,
    ),
  );
}

class KeyboardDismissWrapper extends StatelessWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Creates a [KeyboardDismissWrapper].
  ///
  /// The [child] parameter is required and represents the widget tree to be wrapped.
  const KeyboardDismissWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // When a tap is detected, unfocus any currently focused input field
      onTap: () {
        // Get the primary focus node and unfocus it
        final FocusScopeNode currentFocus = FocusScope.of(context);

        // Only unfocus if focus is active and not on an "unfocusable" widget
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      // Setting behavior to opaque ensures all taps are detected,
      // even in areas with no visible content
      behavior: HitTestBehavior.opaque,
      // Pass through all gestures except for tap
      excludeFromSemantics: true,
      // Pass the entire app as the child
      child: child,
    );
  }
}
