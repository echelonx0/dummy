// lib/app/app.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:khedoo/features/growth/providers/growth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../core/services/localization_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/auth_router_service.dart';
import '../features/advanced/psych_engine/controller/psych_controller.dart';
import '../features/advanced/worldview_engine/controllers/worldview_controller.dart';
import '../features/auth/screens/modern_login_screen.dart';
import '../features/courtship/providers/courtship_provider.dart';
import '../features/onboarding/screens/language_selection_screen.dart';
import '../core/shared/theme/app_theme.dart';
import '../core/shared/theme/theme_provider.dart';
import '../generated/l10n.dart';
import 'locator.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _locale;
  bool _isAppInitialized = false;
  bool _hasSelectedLanguage = false;

  final _authService = locator<AuthService>();
  final _authRouterService = locator<AuthRouterService>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize locale
      final locale = await LocalizationService.getCurrentLocale();
      final prefs = await SharedPreferences.getInstance();

      // Check if the user has already selected a language
      final hasSelectedLanguage =
          prefs.getBool('has_selected_language') ?? false;

      log('[App] Locale: $locale, Language selected: $hasSelectedLanguage');

      setState(() {
        _locale = locale;
        _hasSelectedLanguage = hasSelectedLanguage;
        _isAppInitialized = true;
      });

      log('[App] App initialization complete');
    } catch (error) {
      // Fallback initialization
      setState(() {
        _locale = const Locale('en');
        _hasSelectedLanguage = true;
        _isAppInitialized = true;
      });
    }
  }

  Widget _buildLoadingScreen({String? message}) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Romantic loading animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.3),
                    AppColors.primaryGold,
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Khedoo',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Your love journey begins here',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStreamBuilder() {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(message: 'Checking authentication...');
        }

        // Check for errors
        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        // User is authenticated, route based on profile completion
        return FutureBuilder<bool>(
          future: _authService.hasCompletedProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen(message: 'Loading your profile...');
            }

            if (profileSnapshot.hasError) {
              // On error, assume profile not complete and route accordingly
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _authRouterService.routeAfterAuth(context);
              });
              return _buildLoadingScreen(message: 'Welcome back...');
            }

            final hasCompletedProfile = profileSnapshot.data ?? false;

            // Route the user to appropriate screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _authRouterService.routeAfterAuth(context);
            });

            return _buildLoadingScreen(
              message:
                  hasCompletedProfile
                      ? 'Welcome back...'
                      : 'Setting up your profile...',
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show initial loading while app initializes
    if (!_isAppInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _buildLoadingScreen(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CourtshipProvider()),
        ChangeNotifierProvider(create: (_) => GrowthProvider()),
        ChangeNotifierProvider(create: (_) => WorldviewController()),
        ChangeNotifierProvider(create: (_) => PsychologyController()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Khedoo - Meaningful Connections',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            // RESTORED: Proper language selection check
            home:
                !_hasSelectedLanguage
                    ? const LanguageSelectionScreen()
                    : _buildAuthStreamBuilder(),
          );
        },
      ),
    );
  }
}
