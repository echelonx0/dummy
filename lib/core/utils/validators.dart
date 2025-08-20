// lib/core/utils/validators.dart
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Simple regex for phone number (adjust for specific requirements)
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Date of birth validation
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final minimumAge = 18;

    // Check if the user is at least 18 years old
    if (now.year - value.year < minimumAge) {
      return 'You must be at least $minimumAge years old';
    } else if (now.year - value.year == minimumAge) {
      if (now.month < value.month ||
          (now.month == value.month && now.day < value.day)) {
        return 'You must be at least $minimumAge years old';
      }
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URLs might be optional
    }

    // Simple URL validation
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+([\da-zA-Z-_/?%&=]*)?$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Image file validation
  static String? validateImageFile(String? path) {
    if (path == null || path.isEmpty) {
      return 'Image is required';
    }

    final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final extension = path.split('.').last.toLowerCase();

    if (!validExtensions.contains('.$extension')) {
      return 'Invalid image format. Use jpg, jpeg, png, or webp';
    }

    return null;
  }

  // Text length validation
  static String? validateTextLength(String? value, {int min = 0, int? max}) {
    if (value == null) {
      return min > 0 ? 'Text is required' : null;
    }

    if (value.length < min) {
      return 'Text must be at least $min characters';
    }

    if (max != null && value.length > max) {
      return 'Text cannot exceed $max characters';
    }

    return null;
  }

  // Numeric value validation
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Numeric values might be optional
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }
}
