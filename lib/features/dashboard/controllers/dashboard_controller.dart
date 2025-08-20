// lib/features/dashboard/controllers/dashboard_controller.dart
import 'dart:developer';
import 'package:flutter/material.dart';

import '../../../core/models/user_insights.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/utils/error_utils.dart';
import '../../../app/locator.dart';

class DashboardController extends ChangeNotifier {
  final _authService = locator<AuthService>();
  final _dashboardService = DashboardService();

  // User data state
  String? _userName;
  String? _userProfileImage;
  final bool _hasNotifications = true;
  bool _isLoadingUserData = true;

  // Insights state
  bool _isLoadingInsights = true;
  UserInsights? _userInsights;
  String? _insightsError;

  // Getters
  String? get userName => _userName;
  String? get userProfileImage => _userProfileImage;
  bool get hasNotifications => _hasNotifications;
  bool get isLoadingUserData => _isLoadingUserData;
  bool get isLoadingInsights => _isLoadingInsights;
  UserInsights? get userInsights => _userInsights;
  String? get insightsError => _insightsError;

  Future<void> loadUserData() async {
    try {
      _isLoadingUserData = true;
      notifyListeners();

      final user = _authService.getCurrentUser();
      if (user != null) {
        final profileData = await _authService.getUserProfileData();

        _userName = profileData?['firstName'] ??
            user.displayName?.split(' ').first ??
            'User';
        _userProfileImage = profileData?['profileImage'] ?? user.photoURL;
      }

      _isLoadingUserData = false;
      notifyListeners();
    } catch (error) {
      _isLoadingUserData = false;
      notifyListeners();
      log('Error loading user data: $error');
    }
  }

  Future<void> loadInsights() async {
    try {
      _isLoadingInsights = true;
      _insightsError = null;
      notifyListeners();

      final insights = await _dashboardService.getUserInsights();
      _userInsights = insights;
      _isLoadingInsights = false;
      notifyListeners();
    } catch (error) {
      log(error.toString());
      _isLoadingInsights = false;
      _insightsError = ErrorUtils.getHumanReadableError(error);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadUserData(),
      loadInsights(),
    ]);
  }

  void init() {
    loadUserData();
    loadInsights();
  }
}