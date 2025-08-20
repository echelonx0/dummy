// lib/features/growth/widgets/enhanced_journal_entry_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../models/growth_models.dart';
import '../providers/growth_provider.dart';
import '../widgets/new_growth_widgets.dart';

class EnhancedJournalEntryModal extends StatefulWidget {
  const EnhancedJournalEntryModal({super.key});

  @override
  State<EnhancedJournalEntryModal> createState() =>
      _EnhancedJournalEntryModalState();
}

class _EnhancedJournalEntryModalState extends State<EnhancedJournalEntryModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;
  int _moodIntensity = 5;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.1,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusXL),
                topRight: Radius.circular(AppDimensions.radiusXL),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundLight,
                        AppColors.softPink.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusXL),
                      topRight: Radius.circular(AppDimensions.radiusXL),
                    ),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      MediaQuery.of(context).size.height *
                          _slideAnimation.value,
                    ),
                    child: _buildModalContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            const SizedBox(height: AppDimensions.paddingXL),
            _buildMoodSection(),
            const SizedBox(height: AppDimensions.paddingXL),
            _buildContentSection(),
            const SizedBox(height: AppDimensions.paddingXXL),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(Icons.close, color: AppColors.primaryDarkBlue, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Text(
            'New entry',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDarkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<GrowthProvider>(
          builder: (context, provider, child) {
            return Container(
              margin: const EdgeInsets.only(right: AppDimensions.paddingM),
              child: ElevatedButton(
                onPressed: provider.isSubmittingEntry ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  elevation: 0,
                ),
                child:
                    provider.isSubmittingEntry
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Save',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return EnhancedGlassmorphicContainer(
      backgroundColor: AppColors.softPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today? 💭',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryDarkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Give your reflection a title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return EnhancedGlassmorphicContainer(
      backgroundColor: AppColors.softPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(Icons.mood, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Text(
                'Current Mood',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildMoodSelector(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildMoodIntensitySlider(),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children:
          MoodType.values.map((mood) {
            final isSelected = _selectedMood == mood;
            final moodColor = _getMoodColor(mood);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedMood = mood);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? moodColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: isSelected ? moodColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: moodColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Text(
                      mood.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? moodColor : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMoodIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Intensity',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.accentGradient),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Text(
                '$_moodIntensity/10',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getMoodColor(_selectedMood),
            inactiveTrackColor: _getMoodColor(
              _selectedMood,
            ).withValues(alpha: 0.2),
            thumbColor: _getMoodColor(_selectedMood),
            overlayColor: _getMoodColor(_selectedMood).withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _moodIntensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged:
                (value) => setState(() => _moodIntensity = value.toInt()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mild',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            Text(
              'Intense',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return EnhancedGlassmorphicContainer(
      backgroundColor: AppColors.softPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Text(
                'Your Thoughts',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText:
                  'Share what\'s on your heart and mind...\n\n• What made you feel this way?\n• What are you grateful for?\n• What would you like to remember about today?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDarkBlue,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    'Writing regularly helps you understand your emotions and grow as a person. You\'re building emotional intelligence! 💚',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.excited:
        return AppColors.primaryGold;
      case MoodType.happy:
        return AppColors.primaryAccent;
      case MoodType.content:
        return AppColors.success;
      case MoodType.neutral:
        return AppColors.textMedium;
      case MoodType.anxious:
        return AppColors.warning;
      case MoodType.sad:
        return AppColors.primarySageGreen;
      case MoodType.frustrated:
        return AppColors.error;
      case MoodType.confident:
        return AppColors.primaryDarkBlue;
      case MoodType.grateful:
        return AppColors.primaryAccent;
      case MoodType.inspired:
        return AppColors.primaryGold;
    }
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.excited:
        return '🤩';
      case MoodType.happy:
        return '😊';
      case MoodType.content:
        return '😌';
      case MoodType.neutral:
        return '😐';
      case MoodType.anxious:
        return '😰';
      case MoodType.sad:
        return '😢';
      case MoodType.frustrated:
        return '😤';
      case MoodType.confident:
        return '💪';
      case MoodType.grateful:
        return '🙏';
      case MoodType.inspired:
        return '✨';
    }
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: AppDimensions.paddingS),
              const Expanded(
                child: Text('Please fill in both title and content'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          margin: const EdgeInsets.all(AppDimensions.paddingL),
        ),
      );
      return;
    }

    try {
      final success = await context.read<GrowthProvider>().createJournalEntry(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mood: _selectedMood,
        moodIntensity: _moodIntensity,
        tags: _tags,
      );

      if (success && mounted) {
        Navigator.pop(context);
        HapticFeedback.heavyImpact();

        // Show success celebration
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => RomanticCelebrationOverlay(
                message: 'Beautiful reflection saved! 💕',
                subtitle: 'You\'re growing stronger every day',
                onDismiss: () => Navigator.pop(context),
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(child: Text('Failed to save entry: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            margin: const EdgeInsets.all(AppDimensions.paddingL),
          ),
        );
      }
    }
  }
}
