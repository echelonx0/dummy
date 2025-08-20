// lib/features/admin/widgets/analytics_filters.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../models/match_analytics_models.dart';

class AnalyticsFiltersWidget extends StatefulWidget {
  final AnalyticsFilters initialFilters;
  final ValueChanged<AnalyticsFilters> onFiltersChanged;

  const AnalyticsFiltersWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  @override
  State<AnalyticsFiltersWidget> createState() => _AnalyticsFiltersWidgetState();
}

class _AnalyticsFiltersWidgetState extends State<AnalyticsFiltersWidget> {
  late AnalyticsFilters _filters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilters(AnalyticsFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _resetFilters() {
    final resetFilters = AnalyticsFilters();
    _updateFilters(resetFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Filter Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.primarySageGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterBadge(),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Content
          if (_isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Time Range Selection
                  _TimeRangeSelector(
                    selectedRange: _filters.timeRange,
                    onChanged:
                        (range) =>
                            _updateFilters(_filters.copyWith(timeRange: range)),
                  ),

                  const SizedBox(height: 20),

                  // Score Range
                  _ScoreRangeSelector(
                    minScore: _filters.minScore,
                    maxScore: _filters.maxScore,
                    onChanged:
                        (min, max) => _updateFilters(
                          _filters.copyWith(minScore: min, maxScore: max),
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Compatibility Factor Filter
                  _FactorSelector(
                    selectedFactor: _filters.factorFilter,
                    onChanged:
                        (factor) => _updateFilters(
                          _filters.copyWith(factorFilter: factor),
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Date Range (Advanced)
                  _DateRangeSelector(
                    startDate: _filters.startDate,
                    endDate: _filters.endDate,
                    onChanged:
                        (start, end) => _updateFilters(
                          _filters.copyWith(startDate: start, endDate: end),
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: Icon(
                          Icons.refresh,
                          size: 16,
                          color: AppColors.textMedium,
                        ),
                        label: Text(
                          'Reset Filters',
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _getActiveFiltersCount(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBadge() {
    final activeCount = _getActiveFiltersCountInt();
    if (activeCount == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primarySageGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        activeCount.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryAccent,
        ),
      ),
    );
  }

  String _getActiveFiltersCount() {
    final count = _getActiveFiltersCountInt();
    if (count == 0) return 'No active filters';
    return '$count active filter${count == 1 ? '' : 's'}';
  }

  int _getActiveFiltersCountInt() {
    int count = 0;
    if (_filters.timeRange != '24h') count++;
    if (_filters.minScore != 0 || _filters.maxScore != 100) count++;
    if (_filters.factorFilter != null && _filters.factorFilter != 'all')
      count++;
    if (_filters.startDate != null || _filters.endDate != null) count++;
    return count;
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onChanged;

  const _TimeRangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _TimeRangeChip(
              label: 'Last Hour',
              value: '1h',
              isSelected: selectedRange == '1h',
              onTap: () => onChanged('1h'),
            ),
            _TimeRangeChip(
              label: 'Last 24h',
              value: '24h',
              isSelected: selectedRange == '24h',
              onTap: () => onChanged('24h'),
            ),
            _TimeRangeChip(
              label: 'Last 7 Days',
              value: '7d',
              isSelected: selectedRange == '7d',
              onTap: () => onChanged('7d'),
            ),
            _TimeRangeChip(
              label: 'Last 30 Days',
              value: '30d',
              isSelected: selectedRange == '30d',
              onTap: () => onChanged('30d'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeRangeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
      selectedColor: AppColors.primarySageGreen.withValues(alpha: 0.3),
      checkmarkColor: AppColors.primarySageGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryAccent : AppColors.textMedium,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _ScoreRangeSelector extends StatelessWidget {
  final int minScore;
  final int maxScore;
  final Function(int, int) onChanged;

  const _ScoreRangeSelector({
    required this.minScore,
    required this.maxScore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score Range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$minScore% - $maxScore%',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primarySageGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(minScore.toDouble(), maxScore.toDouble()),
          min: 0,
          max: 100,
          divisions: 20,
          labels: RangeLabels('$minScore%', '$maxScore%'),
          activeColor: AppColors.primarySageGreen,
          inactiveColor: AppColors.borderPrimary.withValues(alpha: 0.3),
          onChanged: (values) {
            onChanged(values.start.round(), values.end.round());
          },
        ),
      ],
    );
  }
}

class _FactorSelector extends StatelessWidget {
  final String? selectedFactor;
  final ValueChanged<String?> onChanged;

  const _FactorSelector({
    required this.selectedFactor,
    required this.onChanged,
  });

  static const factors = [
    'all',
    'Core Values',
    'Lifestyle',
    'Relationship Goals',
    'Attachment Style',
    'Communication',
    'Dealbreakers',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compatibility Factor',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.borderPrimary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFactor ?? 'all',
              isDense: true,
              dropdownColor: AppColors.surface,
              items:
                  factors
                      .map(
                        (factor) => DropdownMenuItem(
                          value: factor,
                          child: Text(
                            factor == 'all' ? 'All Factors' : factor,
                            style: TextStyle(color: AppColors.textDark),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onChanged;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DateSelector(
                label: 'Start Date',
                date: startDate,
                onChanged: (date) => onChanged(date, endDate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateSelector(
                label: 'End Date',
                date: endDate,
                onChanged: (date) => onChanged(startDate, date),
              ),
            ),
          ],
        ),
        if (startDate != null || endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => onChanged(null, null),
                  icon: Icon(Icons.clear, size: 16, color: AppColors.error),
                  label: Text(
                    'Clear Dates',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderPrimary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: Text(
                date != null
                    ? '${date!.month}/${date!.day}/${date!.year}'
                    : 'Select date',
                style: TextStyle(
                  color:
                      date != null ? AppColors.textDark : AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primarySageGreen,
              onPrimary: AppColors.primaryAccent,
              surface: AppColors.surface,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }
}
