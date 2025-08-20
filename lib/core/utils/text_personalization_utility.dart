// lib/core/utils/text_personalization_utility.dart
class TextPersonalizationUtils {
  /// Personalizes insight text by optionally adding the user's name
  /// in a natural, non-repetitive way
  static String personalizeInsightText(String text, {String? userName}) {
    if (userName == null || userName.isEmpty) {
      return text;
    }

    // Don't personalize if text is too short or already contains the name
    if (text.length < 20 ||
        text.toLowerCase().contains(userName.toLowerCase())) {
      return text;
    }

    // Random chance to personalize (not every text gets personalized)
    if (DateTime.now().millisecond % 3 != 0) {
      return text;
    }

    // Simple personalization patterns
    final personalizations = [
      '$userName, $text',
      '${text.replaceFirst('You', userName)}'.replaceFirst(
        userName,
        '$userName,',
      ),
      text.replaceFirst('This shows', '$userName, this shows'),
      text.replaceFirst('You likely', '$userName, you likely'),
    ];

    // Pick one that makes grammatical sense
    for (final personalized in personalizations) {
      if (_isGrammaticallyCorrect(personalized, userName)) {
        return personalized;
      }
    }

    return text; // Fallback to original
  }

  /// Basic grammar check for personalized text
  static bool _isGrammaticallyCorrect(String text, String userName) {
    // Avoid double names or awkward constructions
    final lowerText = text.toLowerCase();
    final lowerName = userName.toLowerCase();

    // Count name occurrences - should be 1 or 2 max
    final nameCount = lowerName.allMatches(lowerText).length;
    if (nameCount > 2) return false;

    // Avoid starting with "You, you" patterns
    if (lowerText.startsWith('$lowerName, $lowerName')) return false;

    // Avoid "You you" patterns
    if (lowerText.contains('you you')) return false;

    return true;
  }

  /// Creates a warm, personalized greeting based on context
  static String createPersonalizedGreeting(
    String? userName, {
    String context = 'general',
  }) {
    if (userName == null || userName.isEmpty) {
      return _getGenericGreeting(context);
    }

    final greetings = {
      'insights': [
        'Here\'s what we discovered about you, $userName',
        'Your personality insights, $userName',
        '$userName, let\'s explore your psychological profile',
      ],
      'growth': [
        'Your growth journey, $userName',
        '$userName, here are your development areas',
        'Ready to grow, $userName?',
      ],
      'general': [
        'Hi $userName',
        'Welcome back, $userName',
        'Good to see you, $userName',
      ],
    };

    final contextGreetings = greetings[context] ?? greetings['general']!;
    return contextGreetings[DateTime.now().second % contextGreetings.length];
  }

  static String _getGenericGreeting(String context) {
    final greetings = {
      'insights': [
        'Here\'s what we discovered about you',
        'Your personality insights',
        'Let\'s explore your psychological profile',
      ],
      'growth': [
        'Your growth journey',
        'Here are your development areas',
        'Ready to grow?',
      ],
      'general': ['Welcome back', 'Good to see you', 'Hello there'],
    };

    final contextGreetings = greetings[context] ?? greetings['general']!;
    return contextGreetings[DateTime.now().second % contextGreetings.length];
  }

  /// Formats a relationship readiness explanation with personal touch
  static String formatReadinessExplanation(
    String explanation,
    String? userName,
  ) {
    if (userName == null || userName.isEmpty) {
      return explanation;
    }

    // Add personal touch to standard explanations
    if (explanation.startsWith('Based on your profile')) {
      return explanation.replaceFirst(
        'Based on your profile',
        '$userName, based on your profile',
      );
    }

    if (explanation.startsWith('Your responses show')) {
      return explanation.replaceFirst(
        'Your responses show',
        '$userName, your responses show',
      );
    }

    if (explanation.startsWith('Analysis shows')) {
      return explanation.replaceFirst(
        'Analysis shows',
        '$userName, our analysis shows',
      );
    }

    return explanation;
  }

  /// Creates engaging section headers with optional personalization
  static String createSectionHeader(
    String baseHeader,
    String? userName, {
    bool alwaysPersonalize = false,
  }) {
    if (!alwaysPersonalize &&
        (userName == null || DateTime.now().millisecond % 2 == 0)) {
      return baseHeader;
    }

    final personalizedHeaders = {
      'Your Strengths': '$userName\'s Strengths',
      'Growth Areas': '$userName\'s Growth Opportunities',
      'Relationship Readiness': '$userName\'s Relationship Readiness',
      'Communication Style': 'How $userName Communicates',
      'Personality Insights': '$userName\'s Personality Profile',
    };

    return personalizedHeaders[baseHeader] ?? baseHeader;
  }
}
