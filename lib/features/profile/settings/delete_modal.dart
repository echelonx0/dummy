// lib/features/profile/widgets/delete_account_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/locator.dart';
import '../../auth/screens/modern_login_screen.dart';

class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key});

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const DeleteAccountModal(),
    );
  }
}

class _DeleteAccountModalState extends State<DeleteAccountModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final _authService = locator<AuthService>();
  final _confirmationController = TextEditingController();

  int _currentStep = 0;
  bool _isDeleting = false;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _confirmationController.addListener(_checkConfirmation);
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _checkConfirmation() {
    final isValid = _confirmationController.text.toLowerCase() == 'delete';
    if (isValid != _canProceed) {
      setState(() => _canProceed = isValid);
      if (isValid) HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: _buildGlassmorphismModal(),
        );
      },
    );
  }

  Widget _buildGlassmorphismModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: _buildModalContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent() {
    return Column(
      children: [
        _buildHandle(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProgressIndicator(),
                const SizedBox(height: 32),
                Expanded(child: _buildCurrentStep()),
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textMedium.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryDarkBlue : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
            child:
                isCompleted
                    ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarkBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                    : null,
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWarningStep();
      case 1:
        return _buildConfirmationStep();
      case 2:
        return _buildFinalStep();
      default:
        return _buildWarningStep();
    }
  }

  Widget _buildWarningStep() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.warning_outlined,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Delete Account?',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This action cannot be undone. All your data, matches, and conversations will be permanently deleted.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What will be deleted:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildDeletionList(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDeletionList() {
    final items = [
      'Your profile and photos',
      'All matches and conversations',
      'Trust score and feedback',
      'Account preferences',
    ];

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.close, size: 14, color: Colors.red.withOpacity(0.7)),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.edit_outlined,
            color: AppColors.primaryDarkBlue,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Type "DELETE" to confirm',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please type DELETE (case insensitive) to confirm account deletion.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _confirmationController,
          decoration: InputDecoration(
            hintText: 'Type DELETE here...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryDarkBlue,
                width: 2,
              ),
            ),
            suffixIcon:
                _canProceed
                    ? Icon(Icons.check_circle, color: AppColors.primaryDarkBlue)
                    : null,
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      children: [
        if (_isDeleting) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Deleting Account...',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we process your request.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Final Confirmation',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This is your last chance. Once you tap "Delete Forever", your account will be permanently deleted.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_currentStep < 2) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceedToNext() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep == 0 ? 'I Understand' : 'Continue',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (!_isDeleting) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _deleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete Forever',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (!_isDeleting)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _currentStep > 0 ? _previousStep : _cancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMedium,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep > 0 ? 'Back' : 'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _canProceed;
      default:
        return false;
    }
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<void> _deleteAccount() async {
    HapticFeedback.heavyImpact();

    setState(() => _isDeleting = true);

    try {
      await _authService.deleteAccount();

      // Close modal and navigate to login
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
