// lib/core/utils/ui_helpers.dart
import 'package:flutter/material.dart';

class UIHelpers {
  UIHelpers._();

  /// Maps growth task categories to appropriate icons
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'communication':
        return Icons.chat_outlined;
      case 'emotional':
        return Icons.favorite_outline;
      case 'social':
        return Icons.people_outline;
      case 'self-awareness':
        return Icons.psychology_outlined;
      default:
        return Icons.task_alt_outlined;
    }
  }

  /// Creates a standard modal drag handle
  static Widget buildModalHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Creates a standard modal header with title and close button
  static Widget buildModalHeader({
    required String title,
    required VoidCallback onClose,
    required TextStyle titleStyle,
    required Color closeIconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(title, style: titleStyle),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: closeIconColor),
          ),
        ],
      ),
    );
  }

  /// Standard modal decoration
  static BoxDecoration getModalDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );
  }
}