// lib/core/utils/helpers.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shared/widgets/animated_modal.dart';

class Helpers {
  // Show error modal
  static void showErrorModal(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    Widget? actionButton,
  }) {
    AnimatedModal.show(
      context: context,
      message: message,
      title: title,
      type: ModalType.error,
      onDismiss: onDismiss,
      duration: duration,
      actionButton: actionButton,
    );
  }

  // Show success modal
  static void showSuccessModal(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    Widget? actionButton,
  }) {
    AnimatedModal.show(
      context: context,
      message: message,
      title: title,
      type: ModalType.success,
      onDismiss: onDismiss,
      duration: duration,
      actionButton: actionButton,
    );
  }

  // Show info modal
  static void showInfoModal(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    Widget? actionButton,
  }) {
    AnimatedModal.show(
      context: context,
      message: message,
      title: title,
      type: ModalType.info,
      onDismiss: onDismiss,
      duration: duration,
      actionButton: actionButton,
    );
  }

  // Show warning modal
  static void showWarningModal(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
    Widget? actionButton,
  }) {
    AnimatedModal.show(
      context: context,
      message: message,
      title: title,
      type: ModalType.warning,
      onDismiss: onDismiss,
      duration: duration,
      actionButton: actionButton,
    );
  }

  // Format date
  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format time
  static String formatTime(DateTime time, {String format = 'h:mm a'}) {
    return DateFormat(format).format(time);
  }

  // Format date and time
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM d, yyyy h:mm a',
  }) {
    return DateFormat(format).format(dateTime);
  }

  // Calculate age from date of birth
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    String initials = '';

    if (nameParts.length > 1) {
      initials = nameParts[0][0] + nameParts[1][0];
    } else {
      initials = nameParts[0][0];
    }

    return initials.toUpperCase();
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // This is a simple formatter for US phone numbers; adjust for your needs
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
    }

    return phoneNumber;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    return '${text.substring(0, maxLength)}...';
  }

  // Platform-aware back button handling
  static Future<bool> onWillPop(BuildContext context, [String? message]) async {
    if (message != null) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
      );

      return shouldPop ?? false;
    }

    return true;
  }

  // Delay execution
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  // Check if the device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return '';

    final words = text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    return capitalizedWords.join(' ');
  }

  // Convert hexColor to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();

    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(message ?? 'Loading...'),
              ],
            ),
          ),
    );
  }

  // Hide the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Generate a random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Check if string is a valid URL
  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+([\da-zA-Z-_/?%&=]*)?$',
    );

    return urlRegExp.hasMatch(url);
  }

  // Check if string is a valid email
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    return emailRegExp.hasMatch(email);
  }

  // Get orientation type
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  // Get screen size category
  static String getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) return 'phone';
    if (width < 900) return 'tablet';
    if (width < 1200) return 'desktop';
    return 'large';
  }

  // Show a custom toast message
  static void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
