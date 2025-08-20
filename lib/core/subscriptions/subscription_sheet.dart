import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../models/premium_feature.dart';

class SubscriptionBottomSheet extends StatefulWidget {
  final Function(String) onSubscriptionSelected;

  const SubscriptionBottomSheet({
    super.key,
    required this.onSubscriptionSelected,
  });

  static Future<void> show(
    BuildContext context, {
    Function(String)? onSubscriptionSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SubscriptionBottomSheet(
            onSubscriptionSelected:
                onSubscriptionSelected ??
                (plan) {
                  Navigator.pop(context);
                  // Handle subscription selection
                },
          ),
    );
  }

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  SubscriptionPlan _selectedTier = SubscriptionPlan.elite;
  bool _isLoading = true;
  String _errorMessage = '';
  Offerings? _offerings;

  final Map<SubscriptionPlan, String> _tierToProductId = {
    SubscriptionPlan.premium: 'unfold_premium_monthly',
    SubscriptionPlan.elite: 'unfold_elite_monthly',
    SubscriptionPlan.vip: 'unfold_vip_monthly',
  };
  final Map<SubscriptionPlan, Map<String, dynamic>> _tierDetails = {
    SubscriptionPlan.premium: {
      'title': 'Intentional',
      'subtitle': 'For serious daters',
      'description': 'Quality connections with intentional people',
      'price': '\$89',
      'savings': null,
      'features': [
        {'name': 'Unlimited messaging', 'included': true},
        {'name': '10-15 curated matches weekly', 'included': true},
        {'name': 'Profile optimization session', 'included': true},
        {'name': 'Basic matching preferences', 'included': true},
        {'name': 'Personal matchmaker', 'included': false},
        {'name': 'Date coaching calls', 'included': false},
        {'name': 'Priority matching', 'included': false},
        {'name': 'VIP events access', 'included': false},
      ],
    },
    SubscriptionPlan.elite: {
      'title': 'Concierge',
      'subtitle': 'Most popular choice',
      'description': 'Full-service dating with personal support',
      'price': '\$249',
      'savings': 'Best value',
      'features': [
        {'name': 'Everything in Intentional', 'included': true},
        {'name': 'Personal matchmaker assigned', 'included': true},
        {'name': 'Pre-date coaching calls', 'included': true},
        {'name': 'Post-date feedback sessions', 'included': true},
        {'name': 'Priority matching', 'included': true},
        {'name': 'Relationship coaching', 'included': true},
        {'name': 'Background verification', 'included': false},
        {'name': 'VIP events access', 'included': false},
      ],
    },
    SubscriptionPlan.vip: {
      'title': 'Executive',
      'subtitle': 'Ultimate experience',
      'description': 'White-glove service for discerning individuals',
      'price': '\$499',
      'savings': 'Premium experience',
      'features': [
        {'name': 'Everything in Concierge', 'included': true},
        {'name': 'Background verification for matches', 'included': true},
        {'name': 'Private events access', 'included': true},
        {'name': 'Professional photo shoot credit', 'included': true},
        {'name': 'Direct founder access', 'included': true},
        {'name': '24/7 concierge support', 'included': true},
        {'name': 'Travel matching assistance', 'included': true},
        {'name': 'Custom date planning', 'included': true},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current != null) {
        setState(() {
          _offerings = offerings;

          // Update prices from store
          for (var tier in SubscriptionPlan.values) {
            final productId = _tierToProductId[tier];
            final package = _findPackageByIdentifier(
              offerings.current!,
              productId!,
            );

            if (package != null) {
              _tierDetails[tier]!['price'] = package.storeProduct.priceString;
              _tierDetails[tier]!['rawPrice'] = package.storeProduct.price;
              _tierDetails[tier]!['period'] = _formatPeriod(
                package.packageType,
              );
            }
          }
        });
      } else {
        setState(() {
          _errorMessage = 'No subscription options available';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load subscription options: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Package? _findPackageByIdentifier(Offering offering, String identifier) {
    try {
      return offering.availablePackages.firstWhere(
        (package) =>
            package.identifier == identifier ||
            package.storeProduct.identifier == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  String _formatPeriod(PackageType packageType) {
    switch (packageType) {
      case PackageType.monthly:
        return 'month';
      case PackageType.annual:
        return 'year';
      case PackageType.weekly:
        return 'week';
      case PackageType.lifetime:
        return 'lifetime';
      default:
        return 'month';
    }
  }

  void _changeTier(SubscriptionPlan tier) {
    setState(() {
      _selectedTier = tier;
    });
  }

  Future<void> _purchase() async {
    if (_offerings == null) {
      setState(() {
        _errorMessage = 'Subscription options not available';
      });
      return;
    }

    final productId = _tierToProductId[_selectedTier];
    if (productId == null) {
      setState(() {
        _errorMessage = 'Selected tier not available';
      });
      return;
    }

    final package = _findPackageByIdentifier(_offerings!.current!, productId);
    if (package == null) {
      setState(() {
        _errorMessage = 'Subscription package not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final purchaseResult = await Purchases.purchasePackage(package);

      // Verify entitlement
      final entitlements = purchaseResult.entitlements;

      if (entitlements.active.isNotEmpty) {
        // Purchase successful
        widget.onSubscriptionSelected(_selectedTier.toString());
      } else {
        setState(() {
          _errorMessage = 'Purchase completed but access not granted';
        });
      }
    } catch (e) {
      if (e is PurchasesErrorCode) {
        // Handle specific errors
        if (e == PurchasesErrorCode.purchaseCancelledError) {
          // User cancelled, no need to show an error
        } else {
          setState(() {
            _errorMessage = 'Purchase failed: $e';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Unexpected error: $e';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final customerInfo = await Purchases.restorePurchases();

      if (customerInfo.entitlements.active.isNotEmpty) {
        // User has active subscriptions
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Subscription restored successfully!'),
        //     backgroundColor: AppColors.success,
        //   ),
        // );

        // Navigate away or update UI based on the restored subscription
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'No previous subscriptions found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to restore purchases: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTierDetails = _tierDetails[_selectedTier]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child:
          _isLoading && _offerings == null
              ? _buildLoadingState()
              : Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: AppColors.textMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Your Path',
                                style: AppTextStyles.heading1,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unlock meaningful connections',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMedium,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tier selector
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _TierTab(
                          title: 'Intentional',
                          price:
                              _tierDetails[SubscriptionPlan.premium]!['price'],
                          isSelected: _selectedTier == SubscriptionPlan.premium,
                          onTap: () => _changeTier(SubscriptionPlan.premium),
                        ),
                        _TierTab(
                          title: 'Concierge',
                          price: _tierDetails[SubscriptionPlan.elite]!['price'],
                          isSelected: _selectedTier == SubscriptionPlan.elite,
                          onTap: () => _changeTier(SubscriptionPlan.elite),
                          isRecommended: true,
                        ),
                        _TierTab(
                          title: 'Executive',
                          price: _tierDetails[SubscriptionPlan.vip]!['price'],
                          isSelected: _selectedTier == SubscriptionPlan.vip,
                          onTap: () => _changeTier(SubscriptionPlan.vip),
                          isExclusive: true,
                        ),
                      ],
                    ),
                  ),

                  // Selected tier details
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedTierDetails['title'],
                                      style: AppTextStyles.heading2,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedTierDetails['subtitle'],
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primarySageGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedTierDetails['savings'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySageGreen
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    selectedTierDetails['savings'],
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primarySageGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedTierDetails['description'],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Features list
                          ...List.generate(
                            selectedTierDetails['features'].length,
                            (index) => _FeatureItem(
                              text:
                                  selectedTierDetails['features'][index]['name'],
                              isIncluded:
                                  selectedTierDetails['features'][index]['included'],
                            ),
                          ),

                          const SizedBox(height: 32),
                          _buildSubscribeButton(selectedTierDetails),
                          const SizedBox(height: 16),
                          _buildRestoreButton(),
                          const SizedBox(height: 16),

                          // Terms and privacy
                          Text(
                            'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primarySageGreen,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading subscription options...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(Map<String, dynamic> tierDetails) {
    final period = tierDetails['period'] ?? 'month';

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySageGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.cream,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'Start Your Journey • ${tierDetails['price']}/$period',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.cream,
                    fontWeight: FontWeight.w700,
                  ),
                ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _isLoading ? null : _restorePurchases,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Restore Previous Subscription',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TierTab extends StatelessWidget {
  final String title;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRecommended;
  final bool isExclusive;

  const _TierTab({
    required this.title,
    required this.price,
    required this.isSelected,
    required this.onTap,
    this.isRecommended = false,
    this.isExclusive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRecommended || isExclusive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isRecommended
                      ? AppColors.primarySageGreen
                      : AppColors.electricBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isRecommended ? 'Most Popular' : 'Exclusive',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.cream,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (isRecommended || isExclusive) const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.primarySageGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.primarySageGreen
                        : AppColors.borderSecondary,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.cream : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isSelected
                            ? AppColors.cream.withValues(alpha: 0.9)
                            : AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  final bool isIncluded;

  const _FeatureItem({required this.text, required this.isIncluded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  isIncluded
                      ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isIncluded
                        ? AppColors.primarySageGreen
                        : AppColors.borderSecondary,
                width: 2,
              ),
            ),
            child: Icon(
              isIncluded ? Icons.check : Icons.remove,
              color:
                  isIncluded
                      ? AppColors.primarySageGreen
                      : AppColors.textMedium,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isIncluded ? AppColors.textDark : AppColors.textMedium,
                fontWeight: isIncluded ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
