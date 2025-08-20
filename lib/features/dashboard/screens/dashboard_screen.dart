// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../controllers/dashboard_controller.dart';

import '../widgets/dashboard_content_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refresh,
          color: AppColors.primaryDarkBlue,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return DashboardContent(
                  userName: _controller.userName,
                  userProfileImage: _controller.userProfileImage,
                  hasNotifications: _controller.hasNotifications,
                  isLoadingUserData: _controller.isLoadingUserData,
                  isLoadingInsights: _controller.isLoadingInsights,
                  userInsights: _controller.userInsights,
                  insightsError: _controller.insightsError,
                  onRetryInsights: _controller.loadInsights,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
