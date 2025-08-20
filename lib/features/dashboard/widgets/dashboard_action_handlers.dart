// lib/features/dashboard/widgets/dashboard_action_handlers.dart
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../account/widgets/matchmaker_persona_card.dart';
import 'dashboard_modal_handlers.dart';

class DashboardActionHandlers {
  static void handleLinkedInConnect(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('LinkedIn connection coming soon!'),
        backgroundColor: AppColors.primarySageGreen,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.primaryAccent,
          onPressed: () {},
        ),
      ),
    );
  }

  static void handleJournalStart(BuildContext context) {
    DashboardModalHandler.showJournalModal(context);
  }

  static void handleCharacterSelect(BuildContext context) {
    // Show MatchmakerPersonaCard instead of selection flow
    // since user already has a default persona
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Your AI Matchmaker',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your personalized dating companion',
                    style: TextStyle(fontSize: 16, color: AppColors.textMedium),
                  ),

                  const SizedBox(height: 32),

                  // Matchmaker Persona Card
                  Expanded(child: MatchmakerPersonaCard()),
                ],
              ),
            ),
          ),
    );
  }

  static void handlePremiumPsychologyTap(BuildContext context) {
    DashboardModalHandler.showPremiumPsychologyModal(context);
  }
}
