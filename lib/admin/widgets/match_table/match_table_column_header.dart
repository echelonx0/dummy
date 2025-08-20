// lib/features/admin/widgets/match_table_header.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class MatchTableHeader extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final VoidCallback? onExport;
  
  const MatchTableHeader({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Individual Match Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Row(
            children: [
              _SortDropdown(
                selectedSort: sortBy,
                onChanged: onSortChanged,
              ),
              const SizedBox(width: 12),
              _ExportButton(onPressed: onExport),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onChanged;
  
  const _SortDropdown({
    required this.selectedSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderPrimary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          isDense: true,
          dropdownColor: AppColors.surface,
          style: TextStyle(color: AppColors.textDark, fontSize: 14),
          icon: Icon(
            Icons.expand_more,
            color: AppColors.textMedium,
            size: 18,
          ),
          items: const [
            DropdownMenuItem(
              value: 'timestamp', 
              child: Text('Latest First')
            ),
            DropdownMenuItem(
              value: 'score_desc', 
              child: Text('Highest Score')
            ),
            DropdownMenuItem(
              value: 'score_asc', 
              child: Text('Lowest Score')
            ),
            DropdownMenuItem(
              value: 'processing_time', 
              child: Text('Processing Time')
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback? onPressed;
  
  const _ExportButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySageGreen,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download,
                size: 16,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(width: 6),
              Text(
                'Export CSV',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}