import 'personalisation_models.dart';

class PersonalizationQuestions {
  static const List<PersonalizationQuestion> partnerQuestions = [
    PersonalizationQuestion(
      id: 'education',
      question: 'What level of education should your ideal partner have?',
      options: [
        PersonalizationOption(
          value: 'high_school',
          label: 'High School',
          points: 5,
        ),
        PersonalizationOption(
          value: 'some_college',
          label: 'Some College',
          points: 10,
        ),
        PersonalizationOption(
          value: 'bachelors',
          label: 'Bachelor\'s Degree',
          points: 20,
        ),
        PersonalizationOption(
          value: 'masters',
          label: 'Master\'s Degree',
          points: 25,
        ),
        PersonalizationOption(
          value: 'doctorate',
          label: 'Doctorate',
          points: 30,
        ),
        PersonalizationOption(
          value: 'not_important',
          label: 'Education level not important',
          points: 15,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'financial',
      question:
          'What\'s important regarding your partner\'s financial situation?',
      options: [
        PersonalizationOption(
          value: 'financially_stable',
          label: 'Financially stable',
          points: 15,
        ),
        PersonalizationOption(
          value: 'comfortable',
          label: 'Comfortable lifestyle',
          points: 25,
        ),
        PersonalizationOption(
          value: 'high_earner',
          label: 'High earner',
          points: 35,
        ),
        PersonalizationOption(
          value: 'not_factor',
          label: 'Not a factor in attraction',
          points: 10,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'career',
      question: 'How important is career success in a partner?',
      options: [
        PersonalizationOption(
          value: 'very_important',
          label: 'Very important to me',
          points: 20,
        ),
        PersonalizationOption(
          value: 'somewhat_important',
          label: 'Somewhat important',
          points: 15,
        ),
        PersonalizationOption(
          value: 'not_important',
          label: 'Not important',
          points: 5,
        ),
        PersonalizationOption(
          value: 'other_qualities',
          label: 'I value other qualities more',
          points: 10,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'lifestyle',
      question: 'What lifestyle compatibility matters to you?',
      options: [
        PersonalizationOption(
          value: 'similar_standards',
          label: 'Similar living standards',
          points: 20,
        ),
        PersonalizationOption(
          value: 'shared_experiences',
          label: 'Ability to share experiences',
          points: 15,
        ),
        PersonalizationOption(
          value: 'travel_ability',
          label: 'Travel and adventure together',
          points: 25,
        ),
        PersonalizationOption(
          value: 'love_matters',
          label: 'Love matters most',
          points: 10,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'background',
      question: 'How important is similar social/cultural background?',
      options: [
        PersonalizationOption(
          value: 'very_important',
          label: 'Very important',
          points: 15,
        ),
        PersonalizationOption(
          value: 'somewhat_important',
          label: 'Somewhat important',
          points: 10,
        ),
        PersonalizationOption(
          value: 'open_differences',
          label: 'Open to differences',
          points: 20,
        ),
        PersonalizationOption(
          value: 'irrelevant',
          label: 'Irrelevant to love',
          points: 15,
        ),
      ],
    ),
  ];

  static const List<PersonalizationQuestion> personalQuestions = [
    PersonalizationQuestion(
      id: 'education',
      question: 'What\'s your highest level of education?',
      options: [
        PersonalizationOption(
          value: 'high_school',
          label: 'High School',
          points: 5,
        ),
        PersonalizationOption(
          value: 'some_college',
          label: 'Some College',
          points: 10,
        ),
        PersonalizationOption(
          value: 'bachelors',
          label: 'Bachelor\'s Degree',
          points: 20,
        ),
        PersonalizationOption(
          value: 'masters',
          label: 'Master\'s Degree',
          points: 25,
        ),
        PersonalizationOption(
          value: 'doctorate',
          label: 'Doctorate',
          points: 30,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'financial',
      question: 'What best describes your financial situation?',
      options: [
        PersonalizationOption(
          value: 'net_worth_1m',
          label: 'Net worth \$1M+',
          points: 40,
        ),
        PersonalizationOption(
          value: 'net_worth_500k',
          label: 'Net worth \$500K-\$1M',
          points: 35,
        ),
        PersonalizationOption(
          value: 'net_worth_250k',
          label: 'Net worth \$250K-\$500K',
          points: 30,
        ),
        PersonalizationOption(
          value: 'net_worth_100k',
          label: 'Net worth \$100K-\$250K',
          points: 20,
        ),
        PersonalizationOption(
          value: 'stable_income',
          label: 'Stable income, building wealth',
          points: 15,
        ),
        PersonalizationOption(
          value: 'prefer_not_say',
          label: 'Prefer not to say',
          points: 10,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'career',
      question: 'How would you describe your career status?',
      options: [
        PersonalizationOption(
          value: 'executive',
          label: 'Executive/Leadership role',
          points: 20,
        ),
        PersonalizationOption(
          value: 'professional',
          label: 'Professional specialist',
          points: 18,
        ),
        PersonalizationOption(
          value: 'manager',
          label: 'Manager/Supervisor',
          points: 15,
        ),
        PersonalizationOption(
          value: 'skilled',
          label: 'Skilled professional',
          points: 10,
        ),
        PersonalizationOption(
          value: 'entry_level',
          label: 'Early career',
          points: 5,
        ),
        PersonalizationOption(
          value: 'entrepreneur',
          label: 'Entrepreneur/Business owner',
          points: 20,
        ),
      ],
    ),
    PersonalizationQuestion(
      id: 'lifestyle',
      question: 'How would you describe your lifestyle?',
      options: [
        PersonalizationOption(
          value: 'luxury',
          label: 'Luxury lifestyle, premium experiences',
          points: 10,
        ),
        PersonalizationOption(
          value: 'comfortable',
          label: 'Comfortable, selective experiences',
          points: 7,
        ),
        PersonalizationOption(
          value: 'modest',
          label: 'Modest, mindful spending',
          points: 5,
        ),
        PersonalizationOption(
          value: 'building',
          label: 'Building toward my goals',
          points: 6,
        ),
      ],
    ),
  ];
}
