// lib/features/admin/widgets/match_row_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../models/match_analytics_models.dart';

class MatchRowWidget extends StatelessWidget {
  final MatchAnalytic match;
  final VoidCallback onTap;

  const MatchRowWidget({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            children: [
              // Match Details
              Expanded(flex: 3, child: _MatchDetailsCell(match: match)),

              // Score
              Expanded(
                flex: 2,
                child: _ScoreCell(score: match.compatibilityScore),
              ),

              // Top Factors
              Expanded(
                flex: 3,
                child: _TopFactorsCell(factors: match.compatibilityFactors),
              ),

              // Processing Time
              Expanded(
                flex: 2,
                child: _ProcessingTimeCell(
                  processingTimeMs: match.processingTimeMs,
                ),
              ),

              // Run ID
              Expanded(flex: 2, child: _RunIdCell(runId: match.runId)),

              // Actions
              SizedBox(
                width: 80,
                child: _ActionsCell(
                  onView: onTap,
                  onCopy: () => _copyMatchId(context, match.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyMatchId(BuildContext context, String matchId) {
    Clipboard.setData(ClipboardData(text: matchId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Match ID copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _MatchDetailsCell extends StatelessWidget {
  final MatchAnalytic match;

  const _MatchDetailsCell({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${match.userAId.substring(0, 8)}... → ${match.userBId.substring(0, 8)}...',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDateTime(match.timestamp),
          style: TextStyle(color: AppColors.textMedium, fontSize: 12),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ScoreCell extends StatelessWidget {
  final int score;

  const _ScoreCell({required this.score});

  @override
  Widget build(BuildContext context) {
    return ScoreBadge(score: score);
  }
}

class ScoreBadge extends StatelessWidget {
  final int score;

  const ScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;

    if (score >= 75) {
      badgeColor = AppColors.success.withValues(alpha: 0.15);
      textColor = AppColors.success;
    } else if (score >= 50) {
      badgeColor = AppColors.warning.withValues(alpha: 0.15);
      textColor = AppColors.warning;
    } else {
      badgeColor = AppColors.error.withValues(alpha: 0.15);
      textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TopFactorsCell extends StatelessWidget {
  final List<FactorScore> factors;

  const _TopFactorsCell({required this.factors});

  @override
  Widget build(BuildContext context) {
    final topFactors =
        [...factors]
          ..sort((a, b) => b.score.compareTo(a.score))
          ..take(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          topFactors
              .map(
                (factor) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          factor.factor,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMedium,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${factor.score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _ProcessingTimeCell extends StatelessWidget {
  final int processingTimeMs;

  const _ProcessingTimeCell({required this.processingTimeMs});

  @override
  Widget build(BuildContext context) {
    final seconds = processingTimeMs / 1000;

    return Text(
      '${seconds.toStringAsFixed(1)}s',
      style: TextStyle(
        color: AppColors.textMedium,
        fontSize: 14,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _RunIdCell extends StatelessWidget {
  final String runId;

  const _RunIdCell({required this.runId});

  @override
  Widget build(BuildContext context) {
    final displayId =
        runId.length > 8 ? '...${runId.substring(runId.length - 8)}' : runId;

    return Text(
      displayId,
      style: TextStyle(
        color: AppColors.textMedium,
        fontSize: 12,
        fontFamily: 'monospace',
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onCopy;

  const _ActionsCell({required this.onView, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.visibility,
          color: AppColors.primarySageGreen,
          onPressed: onView,
          tooltip: 'View Details',
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.copy,
          color: AppColors.textMedium,
          onPressed: onCopy,
          tooltip: 'Copy ID',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}
