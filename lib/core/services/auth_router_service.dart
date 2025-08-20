// lib/core/services/auth_router_service.dart
import 'package:flutter/material.dart';
import '../../app/app_nav.dart';
import '../../app/locator.dart';
import '../../features/auth/screens/modern_login_screen.dart';
import '../../features/profile/screens/profile_creation_screen.dart';
import 'auth_service.dart';

/// Service for handling routing logic after authentication events
class AuthRouterService {
  final AuthService _authService = locator<AuthService>();

  /// Routes the user to the appropriate screen after login or registration
  Future<void> routeAfterAuth(BuildContext context) async {
    // First, check if the user is authenticated
    final isAuthenticated = _authService.getCurrentUser();

    if (isAuthenticated == null) {
      _navigateToLogin(context);
      return;
    }

    // Then check onboarding status
    final hasCompletedOnboarding = await _authService.hasCompletedProfile();

    // Then check profile completion status
    final hasCompletedProfile = await _authService.hasCompletedProfile();

    if (!hasCompletedOnboarding) {
      _navigateToOnboarding(context);
    } else if (!hasCompletedProfile) {
      _navigateToProfileSetup(context);
    } else {
      _navigateToMainApp(context);
    }
  }

  /// Routes a new user after registration
  Future<void> routeAfterRegistration(BuildContext context) async {
    // New users skip onboarding and go straight to profile setup
    _navigateToProfileSetup(context);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileCreationScreen()),
      (route) => false,
    );
  }

  void _navigateToProfileSetup(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileCreationScreen()),
      (route) => false,
    );
  }

  void _navigateToMainApp(BuildContext context) {
    // Replace this with your main app screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }
}
