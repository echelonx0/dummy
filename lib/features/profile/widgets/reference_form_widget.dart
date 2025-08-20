// lib/features/profile/widgets/reference_form_widget.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_dimensions.dart';
import '../../../generated/l10n.dart';

class ReferenceFormWidget extends StatelessWidget {
  final int index;
  final String title;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final List<String> relationshipTypes;
  final String selectedRelationshipType;
  final ValueChanged<String?> onRelationshipTypeChanged;

  const ReferenceFormWidget({
    super.key,
    required this.index,
    required this.title,
    required this.nameController,
    required this.emailController,
    required this.relationshipTypes,
    required this.selectedRelationshipType,
    required this.onRelationshipTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),

        const SizedBox(height: AppDimensions.paddingM),

        // Name Field
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.nameLabel,
            hintText: l10n.nameHint,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
          textCapitalization: TextCapitalization.words,
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Email Field
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: l10n.emailLabel,
            hintText: l10n.emailHint,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),

          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Relationship Type Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.relationshipToYou, style: AppTextStyles.bodySmall),

            const SizedBox(height: AppDimensions.paddingS),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedRelationshipType,
                  onChanged: onRelationshipTypeChanged,
                  items:
                      relationshipTypes.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _getLocalizedRelationshipType(l10n, value),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getLocalizedRelationshipType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'Friend':
        return l10n.relationshipFriend;
      case 'Family Member':
        return l10n.relationshipFamily;
      case 'Former Partner':
        return l10n.relationshipFormerPartner;
      case 'Colleague':
        return l10n.relationshipColleague;
      case 'Roommate':
        return l10n.relationshipRoommate;
      default:
        return type;
    }
  }
}
