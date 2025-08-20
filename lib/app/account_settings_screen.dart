// lib/features/profile/screens/account_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../generated/l10n.dart';
import '../core/services/auth_service.dart';
import '../core/services/firebase_service.dart';
import '../core/shared/widgets/custom_button.dart';
import '../core/shared/widgets/custom_text_field.dart';
import 'locator.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _authService = locator<AuthService>();
  final _firebaseService = locator<FirebaseService>();

  bool _isLoading = false;
  bool _discoveryEnabled = true;
  bool _notificationsEnabled = true;
  Map<String, dynamic>? _profileData;

  // Text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Load profile data from Firestore
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );

        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;

          setState(() {
            _profileData = data;

            // Populate text controllers
            _nameController.text = data['displayName'] ?? '';
            _emailController.text = user.email ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';

            // Set toggles based on user preferences
            _discoveryEnabled = data['isAvailable'] ?? true;
            _notificationsEnabled = data['notificationsEnabled'] ?? true;
          });
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Update user profile
        await _firebaseService.updateDocument('profiles', user.uid, {
          'displayName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'isAvailable': _discoveryEnabled,
          'notificationsEnabled': _notificationsEnabled,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Update Firebase Auth display name
        await _authService.updateUserProfile(
          displayName: _nameController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).profileUpdateSuccess),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);

    // First, confirm with the user
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteAccount),
            content: Text(l10n.deleteAccountConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if (result != true) return;

    // Double-check with a second confirmation
    final finalConfirmation = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.finalConfirmation),
            content: Text(l10n.permanentDeletion),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.confirmDelete),
              ),
            ],
          ),
    );

    if (finalConfirmation != true) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        // Delete profile data
        await _firebaseService.deleteDocument('profiles', user.uid);

        // Delete all conversations and matches
        final matchesSnapshot =
            await FirebaseFirestore.instance
                .collection('profiles')
                .doc(user.uid)
                .collection('matchRecommendations')
                .get();

        for (final doc in matchesSnapshot.docs) {
          await doc.reference.delete();
        }

        // Get conversations to delete
        final profileDoc = await _firebaseService.getDocumentById(
          'profiles',
          user.uid,
        );
        if (profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>;
          final conversationIds = List<String>.from(
            data['ongoingConversations'] ?? [],
          );

          // Delete each conversation
          for (final id in conversationIds) {
            await FirebaseFirestore.instance
                .collection('conversations')
                .doc(id)
                .delete();
          }
        }

        // Sign out
        await _authService.signOut();

        // Navigate back to login
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSettings),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          _isLoading && _profileData == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _buildSectionTitle(l10n.profileInformation),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Profile Photo
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryDarkBlue
                                .withOpacity(0.1),
                            backgroundImage:
                                _profileData?['profileImage'] != null
                                    ? NetworkImage(
                                      _profileData!['profileImage'],
                                    )
                                    : null,
                            child:
                                _profileData?['profileImage'] == null
                                    ? Text(
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text[0]
                                              .toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: AppColors.primaryDarkBlue,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          TextButton.icon(
                            onPressed: () {
                              // Show photo picker in a real implementation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.featureNotAvailable),
                                ),
                              );
                            },
                            icon: const Icon(Icons.photo_camera),
                            label: Text(l10n.changePhoto),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    CustomTextField(
                      label: l10n.fullName,
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    CustomTextField(
                      label: l10n.email,
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      readOnly: true, // Email can't be changed directly
                      hint: l10n.emailCannotBeChanged,
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    CustomTextField(
                      label: l10n.phoneNumber,
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Privacy Section
                    _buildSectionTitle(l10n.privacyDiscovery),
                    const SizedBox(height: AppDimensions.paddingM),

                    _buildToggleSetting(
                      title: l10n.enableDiscovery,
                      subtitle: l10n.enableDiscoveryDescription,
                      value: _discoveryEnabled,
                      onChanged:
                          (value) => setState(() => _discoveryEnabled = value),
                      icon: Icons.visibility,
                    ),

                    const Divider(height: AppDimensions.paddingXL),

                    _buildToggleSetting(
                      title: l10n.enableNotifications,
                      subtitle: l10n.enableNotificationsDescription,
                      value: _notificationsEnabled,
                      onChanged:
                          (value) =>
                              setState(() => _notificationsEnabled = value),
                      icon: Icons.notifications_outlined,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Danger Zone
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                color: Colors.red,
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Text(
                                l10n.dangerZone,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingM),

                          Text(
                            l10n.deleteAccountWarning,
                            style: const TextStyle(color: Colors.red),
                          ),

                          const SizedBox(height: AppDimensions.paddingL),

                          CustomButton(
                            text: l10n.deleteAccount,
                            onPressed: _deleteAccount,
                            type: ButtonType.danger,
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.paddingXXL),

                    // Save Button
                    CustomButton(
                      text: l10n.saveChanges,
                      onPressed: _saveProfile,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      isFullWidth: true,
                    ),

                    const SizedBox(height: AppDimensions.paddingL),

                    // Logout Button
                    CustomButton(
                      text: l10n.signOut,
                      onPressed: _authService.signOut,
                      type: ButtonType.secondary,
                      isFullWidth: true,
                    ),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // App Version
                    Center(
                      child: Text(
                        'App Version 1.0.0',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primaryDarkBlue, size: 24),

        const SizedBox(width: AppDimensions.paddingM),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryDarkBlue,
        ),
      ],
    );
  }
}
