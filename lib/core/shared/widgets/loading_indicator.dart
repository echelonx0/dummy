// lib/shared/widgets/loading_indicator.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
// import '../../constants/app_dimensions.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 36.0,
    this.color = AppColors.primaryDarkBlue,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
