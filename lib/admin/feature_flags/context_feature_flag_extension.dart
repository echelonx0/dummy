// lib/core/extensions/context_feature_flag_extension.dart
import 'package:flutter/material.dart';

import 'feature_flag_builder.dart';
import 'feature_flag_service.dart';

extension ContextFeatureFlag on BuildContext {
  /// Check if a feature flag is enabled
  bool isFeatureEnabled(String flagId) {
    return FeatureFlagService().isEnabled(flagId);
  }

  /// Get feature flag metadata
  Map<String, dynamic>? getFeatureFlagMetadata(String flagId) {
    return FeatureFlagService().getFlagMetadata(flagId);
  }

  /// Show widget when feature flag is enabled
  Widget showWhenEnabled(String flagId, Widget child, {Widget? fallback}) {
    return FeatureFlagBuilder(flagId: flagId, fallback: fallback, child: child);
  }

  /// Hide widget when feature flag is enabled (show when disabled)
  Widget hideWhenEnabled(String flagId, Widget child, {Widget? fallback}) {
    return FeatureFlagBuilder(
      flagId: flagId,
      invertFlag: true,
      fallback: fallback,
      child: child,
    );
  }

  /// Conditionally build widget based on feature flag
  Widget? buildIfEnabled(String flagId, Widget Function() builder) {
    if (isFeatureEnabled(flagId)) {
      return builder();
    }
    return null;
  }

  /// Choose between two widgets based on feature flag
  Widget chooseByFlag(
    String flagId, {
    required Widget enabled,
    required Widget disabled,
  }) {
    return FeatureFlagBuilder(
      flagId: flagId,
      child: enabled,
      fallback: disabled,
    );
  }
}

// Enhanced FeatureFlagBuilder to work better with context
class ContextAwareFeatureFlagBuilder extends StatelessWidget {
  final String flagId;
  final Widget Function(BuildContext context, bool isEnabled) builder;

  const ContextAwareFeatureFlagBuilder({
    super.key,
    required this.flagId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureFlagService(),
      builder: (context, _) {
        final isEnabled = FeatureFlagService().isEnabled(flagId);
        return builder(context, isEnabled);
      },
    );
  }
}
