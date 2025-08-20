// lib/core/widgets/feature_flag_builder.dart
import 'package:flutter/material.dart';
import 'feature_flag_service.dart';

class FeatureFlagBuilder extends StatelessWidget {
  final String flagId;
  final Widget child;
  final Widget? fallback;
  final bool invertFlag; // Show when disabled

  const FeatureFlagBuilder({
    super.key,
    required this.flagId,
    required this.child,
    this.fallback,
    this.invertFlag = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FeatureFlagService(),
      builder: (context, _) {
        final isEnabled = FeatureFlagService().isEnabled(flagId);
        final shouldShow = invertFlag ? !isEnabled : isEnabled;

        if (shouldShow) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}

// Extension for easier usage
extension WidgetFeatureFlag on Widget {
  Widget showWhenEnabled(String flagId, {Widget? fallback}) {
    return FeatureFlagBuilder(flagId: flagId, fallback: fallback, child: this);
  }

  Widget hideWhenEnabled(String flagId, {Widget? fallback}) {
    return FeatureFlagBuilder(
      flagId: flagId,
      invertFlag: true,
      fallback: fallback,
      child: this,
    );
  }
}
