// Rest of the file remains the same...
// (JournalEntryModal, TaskDetailsModal, etc.)
// =============================================================================
// JOURNAL ENTRY MODAL
// =============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../models/growth_models.dart';
import '../providers/growth_provider.dart';
import 'growth_widgets.dart';

class JournalEntryModal extends StatefulWidget {
  const JournalEntryModal({super.key});

  @override
  State<JournalEntryModal> createState() => _JournalEntryModalState();
}

class _JournalEntryModalState extends State<JournalEntryModal>
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
      duration: const Duration(milliseconds: 600),
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
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: GrowthColors.creamyWhite.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: GrowthColors.soulfulPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Entry 📝',
          style: AppTextStyles.heading3.copyWith(
            color: GrowthColors.soulfulPurple,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Consumer<GrowthProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isSubmittingEntry ? null : _saveEntry,
                child:
                    provider.isSubmittingEntry
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              GrowthColors.hopeBlue,
                            ),
                          ),
                        )
                        : Text(
                          'Save',
                          style: TextStyle(
                            color: GrowthColors.hopeBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'How are you feeling today?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: GrowthColors.softLavender.withValues(alpha: 0.3),
              ),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Mood selector
            Text(
              'Current Mood',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: GrowthColors.soulfulPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(),

            const SizedBox(height: 20),

            // Mood intensity
            Text(
              'Intensity: ${_moodIntensity}/10',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: GrowthColors.hopeBlue,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _moodIntensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: _selectedMood.moodColor,
              onChanged:
                  (value) => setState(() => _moodIntensity = value.toInt()),
            ),

            const SizedBox(height: 20),

            // Content input
            Text(
              'Your Thoughts',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: GrowthColors.soulfulPurple,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Share what\'s on your heart and mind...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: GrowthColors.softLavender.withValues(alpha: 0.3),
              ),
              style: AppTextStyles.bodyMedium,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          MoodType.values.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedMood = mood);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? mood.moodColor.withValues(alpha: 0.2)
                          : GrowthColors.softLavender.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? mood.moodColor : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood.moodEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      mood.name,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            isSelected ? mood.moodColor : AppColors.textMedium,
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

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in both title and content'),
          backgroundColor: GrowthColors.nurturingPink,
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

      if (success) {
        Navigator.pop(context);
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save entry: ${e.toString()}'),
          backgroundColor: GrowthColors.nurturingPink,
        ),
      );
    }
  }
}

// =============================================================================
// TASK DETAILS MODAL (Placeholder)
// =============================================================================

class TaskDetailsModal extends StatelessWidget {
  final GrowthTask task;

  const TaskDetailsModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: GrowthColors.creamyWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: Text(
          'Task Details for: ${task.title}',
          style: AppTextStyles.heading3,
        ),
      ),
    );
  }
}

// =============================================================================
// JOURNAL ENTRY DETAILS MODAL (Placeholder)
// =============================================================================

class JournalEntryDetailsModal extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryDetailsModal({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: GrowthColors.creamyWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: Text('Entry: ${entry.title}', style: AppTextStyles.bodySmall),
      ),
    );
  }
}

// Extension for mood colors
extension MoodTypeExtension on MoodType {
  Color get moodColor {
    switch (this) {
      case MoodType.excited:
        return GrowthColors.warmGold;
      case MoodType.happy:
        return GrowthColors.nurturingPink;
      case MoodType.content:
        return GrowthColors.growthGreen;
      case MoodType.neutral:
        return const Color(0xFF9E9E9E);
      case MoodType.anxious:
        return const Color(0xFFFFB74D);
      case MoodType.sad:
        return GrowthColors.hopeBlue;
      case MoodType.frustrated:
        return const Color(0xFFEF5350);
      case MoodType.confident:
        return GrowthColors.soulfulPurple;
      case MoodType.grateful:
        return GrowthColors.nurturingPink;
      case MoodType.inspired:
        return GrowthColors.warmGold;
    }
  }

  String get moodEmoji {
    switch (this) {
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
}
