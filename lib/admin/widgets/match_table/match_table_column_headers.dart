// lib/features/admin/widgets/match_table_column_headers.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class MatchTableColumnHeaders extends StatelessWidget {
  const MatchTableColumnHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell(title: 'Match Details')),
          Expanded(flex: 2, child: _HeaderCell(title: 'Score')),
          Expanded(flex: 3, child: _HeaderCell(title: 'Top Factors')),
          Expanded(flex: 2, child: _HeaderCell(title: 'Processing')),
          Expanded(flex: 2, child: _HeaderCell(title: 'Run ID')),
          SizedBox(width: 80, child: _HeaderCell(title: 'Actions')),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  
  const _HeaderCell({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
        letterSpacing: 0.5,
      ),
    );
  }
}