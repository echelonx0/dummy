// lib/core/shared/widgets/enhanced_date_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class EnhancedDatePicker {
  /// Shows the enhanced date picker and returns the selected DateTime
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String title = 'Choose Date of Birth',
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder:
          (context) => _EnhancedDatePickerSheet(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            title: title,
          ),
    );
  }
}

class _EnhancedDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _EnhancedDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  _EnhancedDatePickerSheetState createState() =>
      _EnhancedDatePickerSheetState();
}

class _EnhancedDatePickerSheetState extends State<_EnhancedDatePickerSheet>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _dateFormat = DateFormat('EEEE, MMMM d, yyyy');
  late List<int> _yearsList;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    // Generate years list from firstDate to lastDate
    _yearsList = [];
    for (
      int year = widget.firstDate.year;
      year <= widget.lastDate.year;
      year++
    ) {
      _yearsList.add(year);
    }
    // Reverse so most recent years appear first
    _yearsList = _yearsList.reversed.toList();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _pageController = PageController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, size.height * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: size.height * 0.75,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildDateSelector()),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMedium.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // Selected date display with enhanced styling
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primarySageGreen.withValues(alpha: 0.1),
                  AppColors.primaryAccent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySageGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: AppColors.primarySageGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _dateFormat.format(_selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Enhanced year selector
          _buildYearSelector(),

          const SizedBox(height: 24),

          // Month navigation with better styling
          _buildMonthNavigation(),

          const SizedBox(height: 20),

          // Calendar grid
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDate.year,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primarySageGreen,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          borderRadius: BorderRadius.circular(16),
          dropdownColor: AppColors.cardBackground,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          items:
              _yearsList.map((int year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (int? newYear) {
            if (newYear != null) {
              HapticFeedback.lightImpact();
              setState(() {
                final daysInNewMonth =
                    DateTime(newYear, _selectedDate.month + 1, 0).day;
                final newDay =
                    _selectedDate.day > daysInNewMonth
                        ? daysInNewMonth
                        : _selectedDate.day;

                _selectedDate = DateTime(newYear, _selectedDate.month, newDay);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          _buildNavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: _canNavigateToPrevMonth() ? _goToPreviousMonth : null,
          ),

          // Month display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Next month button
          _buildNavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: _canNavigateToNextMonth() ? _goToNextMonth : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? AppColors.cardBackground
                : AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primarySageGreen.withValues(
            alpha: onPressed != null ? 0.3 : 0.1,
          ),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onPressed != null
                  ? () {
                    HapticFeedback.lightImpact();
                    onPressed();
                  }
                  : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color:
                  onPressed != null
                      ? AppColors.primarySageGreen
                      : AppColors.textMedium.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final currentDate = DateTime.now();

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                  return Text(
                    day,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
          ),
        ),

        // Calendar days grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount:
                _getDaysInMonth(_selectedDate.year, _selectedDate.month) +
                _getFirstDayOfMonth(_selectedDate.year, _selectedDate.month),
            itemBuilder: (context, index) {
              final firstDayOffset = _getFirstDayOfMonth(
                _selectedDate.year,
                _selectedDate.month,
              );

              if (index < firstDayOffset) {
                return const SizedBox.shrink();
              }

              final day = index - firstDayOffset + 1;
              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                day,
              );

              final isSelectable =
                  !date.isBefore(widget.firstDate) &&
                  !date.isAfter(widget.lastDate);
              final isSelected =
                  date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday =
                  date.year == currentDate.year &&
                  date.month == currentDate.month &&
                  date.day == currentDate.day;

              return GestureDetector(
                onTap:
                    isSelectable
                        ? () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                        : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? LinearGradient(
                              colors: [
                                AppColors.primarySageGreen,
                                AppColors.primaryAccent,
                              ],
                            )
                            : null,
                    color:
                        !isSelected && isToday
                            ? AppColors.primarySageGreen.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isToday && !isSelected
                            ? Border.all(
                              color: AppColors.primarySageGreen.withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            )
                            : null,
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primarySageGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isSelected
                                ? AppColors.primaryDarkBlue
                                : isSelectable
                                ? AppColors.textDark
                                : AppColors.textMedium.withValues(alpha: 0.4),
                        fontWeight:
                            isSelected || isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primarySageGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Confirm button
          Expanded(
            flex: 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySageGreen, AppColors.primaryAccent],
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(_selectedDate);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Date',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primaryDarkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryDarkBlue,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation logic
  bool _canNavigateToPrevMonth() {
    final prevMonth = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    return !prevMonth.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month, 1),
    );
  }

  bool _canNavigateToNextMonth() {
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    return !nextMonth.isAfter(
      DateTime(widget.lastDate.year, widget.lastDate.month, 1),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      final newMonth = _selectedDate.month - 1;
      final newYear =
          newMonth < 1 ? _selectedDate.year - 1 : _selectedDate.year;
      final month = newMonth < 1 ? 12 : newMonth;

      final daysInNewMonth = DateTime(newYear, month + 1, 0).day;
      final newDay =
          _selectedDate.day > daysInNewMonth
              ? daysInNewMonth
              : _selectedDate.day;

      _selectedDate = DateTime(newYear, month, newDay);
    });
  }

  void _goToNextMonth() {
    setState(() {
      final newMonth = _selectedDate.month + 1;
      final newYear =
          newMonth > 12 ? _selectedDate.year + 1 : _selectedDate.year;
      final month = newMonth > 12 ? 1 : newMonth;

      final daysInNewMonth = DateTime(newYear, month + 1, 0).day;
      final newDay =
          _selectedDate.day > daysInNewMonth
              ? daysInNewMonth
              : _selectedDate.day;

      _selectedDate = DateTime(newYear, month, newDay);
    });
  }

  // Helper methods
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }
}
