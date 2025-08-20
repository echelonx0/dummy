// lib/features/profile/widgets/advanced_profile_modal.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

import '../../../core/models/advanced_profile_models.dart';
import '../services/advanced_profile_service.dart';
import 'add_link_dialog.dart';

class AdvancedProfileModal extends StatefulWidget {
  final List<AdvancedProfileLink>? existingLinks;
  final VoidCallback? onLinksUpdated;

  const AdvancedProfileModal({
    super.key,
    this.existingLinks,
    this.onLinksUpdated,
  });

  @override
  State<AdvancedProfileModal> createState() => _AdvancedProfileModalState();
}

class _AdvancedProfileModalState extends State<AdvancedProfileModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<AdvancedProfileLink> _currentLinks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentLinks = widget.existingLinks ?? [];
    _loadExistingLinks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLinks() async {
    if (widget.existingLinks == null) {
      setState(() => _isLoading = true);
      final links = await AdvancedProfileService.getProfileLinks();
      setState(() {
        _currentLinks = links;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primarySageGreen,
                            AppColors.primarySageGreen.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advanced Profile',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Add your online presence',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppColors.textMedium),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Benefits row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySageGreen.withValues(alpha: 0.1),
                        AppColors.primaryAccent.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: AppColors.primarySageGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Show authenticity and build trust with verified links',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,

              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMedium,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: const [Tab(text: 'Add Links'), Tab(text: 'My Links')],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAddLinksTab(), _buildMyLinksTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLinksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get suggested types and remove already added ones
    final existingTypes = _currentLinks.map((link) => link.type).toSet();
    final availableTypes =
        AdvancedProfileType.values
            .where((type) => !existingTypes.contains(type))
            .toList();

    // Group types by category
    final professional =
        [
          AdvancedProfileType.linkedin,
          AdvancedProfileType.personalWebsite,
          AdvancedProfileType.github,
          AdvancedProfileType.behance,
          AdvancedProfileType.portfolio,
        ].where(availableTypes.contains).toList();

    final social =
        [
          AdvancedProfileType.instagram,
          AdvancedProfileType.twitter,
          AdvancedProfileType.youtube,
          AdvancedProfileType.tiktok,
        ].where(availableTypes.contains).toList();

    final creative =
        [
          AdvancedProfileType.medium,
          AdvancedProfileType.substack,
          AdvancedProfileType.spotify,
          AdvancedProfileType.goodreads,
          AdvancedProfileType.strava,
        ].where(availableTypes.contains).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (professional.isNotEmpty) ...[
            _buildCategorySection(
              'Professional',
              professional,
              Icons.work_outline,
            ),
            const SizedBox(height: 24),
          ],

          if (social.isNotEmpty) ...[
            _buildCategorySection('Social', social, Icons.people_outline),
            const SizedBox(height: 24),
          ],

          if (creative.isNotEmpty) ...[
            _buildCategorySection(
              'Creative & Lifestyle',
              creative,
              Icons.palette_outlined,
            ),
            const SizedBox(height: 24),
          ],

          // Custom link option
          if (availableTypes.contains(AdvancedProfileType.custom)) ...[
            _buildProfileTypeCard(AdvancedProfileType.custom),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<AdvancedProfileType> types,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMedium),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...types.map(
          (type) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProfileTypeCard(type),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTypeCard(AdvancedProfileType type) {
    return GestureDetector(
      onTap: () => _showAddLinkDialog(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primarySageGreen.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySageGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type.icon,
                color: AppColors.primarySageGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    type.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primarySageGreen,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyLinksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentLinks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'No links added yet',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your online presence to enhance your profile',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySageGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Your First Link'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _currentLinks.length,
      itemBuilder: (context, index) {
        final link = _currentLinks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildExistingLinkCard(link),
        );
      },
    );
  }

  Widget _buildExistingLinkCard(AdvancedProfileLink link) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              link.isVerified
                  ? AppColors.primarySageGreen.withValues(alpha: 0.3)
                  : AppColors.textLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  link.isVerified
                      ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                      : AppColors.textLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              link.type.icon,
              color:
                  link.isVerified
                      ? AppColors.primarySageGreen
                      : AppColors.textMedium,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      link.customTitle ?? link.type.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (link.isVerified) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        color: AppColors.primarySageGreen,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  link.url,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textMedium),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showAddLinkDialog(link.type, existingLink: link);
                  break;
                case 'verify':
                  _verifyLink(link);
                  break;
                case 'delete':
                  _confirmDeleteLink(link);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (!link.isVerified)
                    const PopupMenuItem(
                      value: 'verify',
                      child: Row(
                        children: [
                          Icon(Icons.verified_outlined),
                          SizedBox(width: 8),
                          Text('Verify'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  void _showAddLinkDialog(
    AdvancedProfileType type, {
    AdvancedProfileLink? existingLink,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AddLinkDialog(
            type: type,
            existingLink: existingLink,
            onLinkAdded: (link) {
              setState(() {
                if (existingLink != null) {
                  // Replace existing link
                  final index = _currentLinks.indexWhere((l) => l.type == type);
                  if (index != -1) {
                    _currentLinks[index] = link;
                  }
                } else {
                  // Add new link
                  _currentLinks.add(link);
                }
              });

              // Switch to My Links tab
              _tabController.animateTo(1);

              // Notify parent
              widget.onLinksUpdated?.call();
            },
          ),
    );
  }

  Future<void> _verifyLink(AdvancedProfileLink link) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verifying link...'),
          backgroundColor: AppColors.primarySageGreen,
        ),
      );

      final isVerified = await AdvancedProfileService.verifyLink(link);

      if (isVerified) {
        final verifiedLink = link.copyWith(isVerified: true);
        await AdvancedProfileService.saveProfileLink(verifiedLink);

        setState(() {
          final index = _currentLinks.indexWhere((l) => l.type == link.type);
          if (index != -1) {
            _currentLinks[index] = verifiedLink;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link verified successfully! ✅'),
              backgroundColor: AppColors.primarySageGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not verify link. Please check the URL.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteLink(AdvancedProfileLink link) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Link'),
            content: Text(
              'Are you sure you want to remove your ${link.type.displayName} link?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteLink(link);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteLink(AdvancedProfileLink link) async {
    try {
      final success = await AdvancedProfileService.removeProfileLink(link.type);

      if (success) {
        setState(() {
          _currentLinks.removeWhere((l) => l.type == link.type);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link removed successfully'),
              backgroundColor: AppColors.primarySageGreen,
            ),
          );
        }

        widget.onLinksUpdated?.call();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove link. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing link. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
