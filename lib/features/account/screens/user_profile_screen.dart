// lib/features/profile/screens/profile_management_screen.dart
import 'package:flutter/material.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../services/profile_management_screen.dart';
import '../widgets/profile_header_widgets.dart';
import '../widgets/profile_cards.dart';
import '../widgets/profile_settings_section.dart';
import '../services/profile_actions_controller.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final _service = ProfileManagementService();
  late final ProfileActionsController _controller;

  ProfileData? _profileData;
  String? _currentPersona;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfileActionsController(context: context, service: _service);
    _loadUserData();
    _loadCurrentPersona();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final profileData = await _service.loadUserData();
      setState(() => _profileData = profileData);
    } catch (e) {
      _controller.showErrorSnackBar(
        'Failed to load profile data: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentPersona() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persona = prefs.getString('matchmaker_persona');
      setState(() => _currentPersona = persona ?? 'sage'); // Default to sage
    } catch (e) {
      // Default to sage if loading fails
      setState(() => _currentPersona = 'sage');
    }
  }

  Future<void> _onPersonaChanged() async {
    // Reload the current persona after it's been changed
    await _loadCurrentPersona();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadUserData();
            await _loadCurrentPersona();
          },
          color: AppColors.primarySageGreen,
          child: CustomScrollView(slivers: [_buildHeader(), _buildContent()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child:
          _profileData != null
              ? ProfileManagementHeader(
                profileData: _profileData!,
                onEditProfile: _controller.editProfile,
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildContent() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (_isLoading)
            DelayedDisplay(
              delay: const Duration(milliseconds: 200),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_profileData != null) ...[
            // Overview Cards (includes Matchmaker Persona Card at top)
            DelayedDisplay(
              delay: const Duration(milliseconds: 500),
              child: ProfileOverviewCards(
                profileData: _profileData!,
                currentPersona: _currentPersona,
                onViewTrustScoreDetails: _controller.viewTrustScoreDetails,
                onImproveProfile: _controller.improveProfile,
                onPersonaChanged: _onPersonaChanged,
              ),
            ),

            const SizedBox(height: 20),

            // Settings Section
            DelayedDisplay(
              delay: const Duration(milliseconds: 700),
              child: ProfileSettingsSection(
                onEditProfile: _controller.editProfile,
                onEditPreferences: _controller.editPreferences,
                onManagePrivacy: _controller.managePrivacy,
                onManageVisibility: _controller.manageVisibility,
              ),
            ),

            const SizedBox(height: 20),

            // Account Section
            DelayedDisplay(
              delay: const Duration(milliseconds: 800),
              child: ProfileAccountSection(
                onManageNotifications: _controller.manageNotifications,
                onOpenSupport: _controller.openSupport,
                onSignOut: _controller.signOut,
                onDeleteAccount: _controller.deleteAccount,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ]),
      ),
    );
  }
}
