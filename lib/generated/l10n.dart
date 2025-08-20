import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_fr.dart';
import 'l10n_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('sw'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Deep Connect'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Meaningful Connections Through Deep Understanding'**
  String get tagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @continueJourney.
  ///
  /// In en, this message translates to:
  /// **'Let\'s continue your journey'**
  String get continueJourney;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get invalidPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get unknownError;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get termsAgreement;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Email Sent'**
  String get resetEmailSent;

  /// No description provided for @resetEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'If an account exists with this email, you will receive password reset instructions.'**
  String get resetEmailMessage;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Deep Understanding'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Our unique approach moves beyond superficial matching'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Psychological Compatibility'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Find partners who complement your personality and values'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Guided Journey'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Our AI tool helps you connect on a meaningful level'**
  String get onboardingDesc3;

  /// No description provided for @profileCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get profileCreationTitle;

  /// No description provided for @profileCreationDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build a profile that represents the real you'**
  String get profileCreationDesc;

  /// No description provided for @basicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfoTitle;

  /// No description provided for @basicInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with some basic details about you'**
  String get basicInfoDesc;

  /// No description provided for @uploadPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get uploadPhotosTitle;

  /// No description provided for @uploadPhotosDesc.
  ///
  /// In en, this message translates to:
  /// **'Add photos that show the real you'**
  String get uploadPhotosDesc;

  /// No description provided for @uploadMainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload main photo'**
  String get uploadMainPhoto;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get addMorePhotos;

  /// No description provided for @coreValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Core Values'**
  String get coreValuesTitle;

  /// No description provided for @coreValuesDesc.
  ///
  /// In en, this message translates to:
  /// **'What principles guide your life?'**
  String get coreValuesDesc;

  /// No description provided for @lifestyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyleTitle;

  /// No description provided for @lifestyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your day-to-day life'**
  String get lifestyleDesc;

  /// No description provided for @relationshipGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship Goals'**
  String get relationshipGoalsTitle;

  /// No description provided for @relationshipGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for in a relationship?'**
  String get relationshipGoalsDesc;

  /// No description provided for @deepQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Understanding'**
  String get deepQuestionsTitle;

  /// No description provided for @deepQuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explore some reflective questions'**
  String get deepQuestionsDesc;

  /// No description provided for @assessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Psychological Assessment'**
  String get assessmentTitle;

  /// No description provided for @assessmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand your relationship patterns'**
  String get assessmentDesc;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Get References'**
  String get feedbackTitle;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Add credibility with feedback from people who know you'**
  String get feedbackDesc;

  /// No description provided for @profileCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Complete!'**
  String get profileCompleteTitle;

  /// No description provided for @profileCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile is now ready for matching'**
  String get profileCompleteDesc;

  /// No description provided for @matchPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Preferences'**
  String get matchPreferencesTitle;

  /// No description provided for @matchPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Who would you like to meet?'**
  String get matchPreferencesDesc;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age Range'**
  String get ageRange;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @heightRange.
  ///
  /// In en, this message translates to:
  /// **'Height Range'**
  String get heightRange;

  /// No description provided for @interestedIn.
  ///
  /// In en, this message translates to:
  /// **'Interested In'**
  String get interestedIn;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @nonBinary.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get nonBinary;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @matchesTab.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTab;

  /// No description provided for @insightsTab.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTab;

  /// No description provided for @growthTab.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthTab;

  /// No description provided for @aiCoachTab.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get aiCoachTab;

  /// No description provided for @matchJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Matching Journey'**
  String get matchJourneyTitle;

  /// No description provided for @currentStage.
  ///
  /// In en, this message translates to:
  /// **'Current Stage'**
  String get currentStage;

  /// No description provided for @ongoingConversations.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Conversations'**
  String get ongoingConversations;

  /// No description provided for @potentialMatches.
  ///
  /// In en, this message translates to:
  /// **'Potential Matches'**
  String get potentialMatches;

  /// No description provided for @matchCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Match Compatibility'**
  String get matchCompatibility;

  /// No description provided for @compatibilityMessage1.
  ///
  /// In en, this message translates to:
  /// **'High compatibility based on communication styles and values'**
  String get compatibilityMessage1;

  /// No description provided for @compatibilityMessage2.
  ///
  /// In en, this message translates to:
  /// **'Strong alignment on life goals and emotional intelligence'**
  String get compatibilityMessage2;

  /// No description provided for @conversationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Conversation in progress'**
  String get conversationInProgress;

  /// No description provided for @introductionPhase.
  ///
  /// In en, this message translates to:
  /// **'Introduction phase'**
  String get introductionPhase;

  /// No description provided for @continueConversation.
  ///
  /// In en, this message translates to:
  /// **'Continue Conversation'**
  String get continueConversation;

  /// No description provided for @relationshipType.
  ///
  /// In en, this message translates to:
  /// **'Relationship Type'**
  String get relationshipType;

  /// No description provided for @yourAttachmentStyle.
  ///
  /// In en, this message translates to:
  /// **'Your Attachment Style'**
  String get yourAttachmentStyle;

  /// No description provided for @lookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking For'**
  String get lookingFor;

  /// No description provided for @lookingForValue.
  ///
  /// In en, this message translates to:
  /// **'Someone who is emotionally available and shares your values'**
  String get lookingForValue;

  /// No description provided for @updatePreferences.
  ///
  /// In en, this message translates to:
  /// **'Update Preferences'**
  String get updatePreferences;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @relationshipReadinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship Readiness'**
  String get relationshipReadinessTitle;

  /// No description provided for @insightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile and responses, our AI has assessed:'**
  String get insightsDescription;

  /// No description provided for @readinessProgress.
  ///
  /// In en, this message translates to:
  /// **'You\'re on your way to relationship readiness'**
  String get readinessProgress;

  /// No description provided for @whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What this means:'**
  String get whatThisMeans;

  /// No description provided for @readinessExplanation.
  ///
  /// In en, this message translates to:
  /// **'You have a solid foundation for building meaningful relationships. With some focused growth in specific areas, you\'ll be even more prepared for a fulfilling partnership.'**
  String get readinessExplanation;

  /// No description provided for @areasForGrowthTitle.
  ///
  /// In en, this message translates to:
  /// **'Areas for Growth'**
  String get areasForGrowthTitle;

  /// No description provided for @areasForGrowthDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile analysis and relationship goals, we\'ve identified these areas where focused development could enhance your relationship success:'**
  String get areasForGrowthDescription;

  /// No description provided for @insightsFooter.
  ///
  /// In en, this message translates to:
  /// **'Remember, these insights are meant to help you grow. Everyone has areas they can develop, and addressing these can lead to more fulfilling relationships.'**
  String get insightsFooter;

  /// No description provided for @growthJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Growth Journey'**
  String get growthJourneyTitle;

  /// No description provided for @growthJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal growth is an essential part of finding and maintaining meaningful relationships. Your custom path is designed to help you become your best self.'**
  String get growthJourneyDescription;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress: 30%'**
  String get overallProgress;

  /// No description provided for @growthTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Growth Tasks'**
  String get growthTasksTitle;

  /// No description provided for @growthTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete these activities to expand your relationship skills and readiness:'**
  String get growthTasksDescription;

  /// No description provided for @logActivityCompletion.
  ///
  /// In en, this message translates to:
  /// **'Log Activity Completion'**
  String get logActivityCompletion;

  /// No description provided for @growthResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Resources'**
  String get growthResourcesTitle;

  /// No description provided for @growthResourcesDescription.
  ///
  /// In en, this message translates to:
  /// **'Helpful resources customized to your growth areas:'**
  String get growthResourcesDescription;

  /// No description provided for @resourceTitle1.
  ///
  /// In en, this message translates to:
  /// **'Active Listening: The Complete Guide'**
  String get resourceTitle1;

  /// No description provided for @resourceDetails1.
  ///
  /// In en, this message translates to:
  /// **'Article • 8 min read'**
  String get resourceDetails1;

  /// No description provided for @resourceTitle2.
  ///
  /// In en, this message translates to:
  /// **'Breaking Free from Avoidant Patterns'**
  String get resourceTitle2;

  /// No description provided for @resourceDetails2.
  ///
  /// In en, this message translates to:
  /// **'Video • 12 min'**
  String get resourceDetails2;

  /// No description provided for @resourceTitle3.
  ///
  /// In en, this message translates to:
  /// **'Social Confidence Building Exercises'**
  String get resourceTitle3;

  /// No description provided for @resourceDetails3.
  ///
  /// In en, this message translates to:
  /// **'Interactive • 15 min daily'**
  String get resourceDetails3;

  /// No description provided for @aiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI Relationship Coach'**
  String get aiCoachTitle;

  /// No description provided for @aiMatchmakerTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Matchmaker'**
  String get aiMatchmakerTitle;

  /// No description provided for @aiMatchmakerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your guide to meaningful connections'**
  String get aiMatchmakerSubtitle;

  /// No description provided for @aiCoachDescription.
  ///
  /// In en, this message translates to:
  /// **'I\'m here to guide your matchmaking journey, provide insight into your relationship patterns, and help you grow into your best self for meaningful partnerships.'**
  String get aiCoachDescription;

  /// No description provided for @startNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Start New Conversation'**
  String get startNewConversation;

  /// No description provided for @conversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Conversations'**
  String get conversationsTitle;

  /// No description provided for @conversationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Continue your ongoing conversations:'**
  String get conversationsDescription;

  /// No description provided for @weeklyReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reflection'**
  String get weeklyReflectionTitle;

  /// No description provided for @weeklyReflectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Taking time to reflect helps build self-awareness:'**
  String get weeklyReflectionDescription;

  /// No description provided for @thisWeeksQuestion.
  ///
  /// In en, this message translates to:
  /// **'This week\'s question:'**
  String get thisWeeksQuestion;

  /// No description provided for @reflectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did your recent social interaction challenge your comfort zone, and what did you learn about yourself?'**
  String get reflectionQuestion;

  /// No description provided for @shareReflection.
  ///
  /// In en, this message translates to:
  /// **'Share Your Reflection'**
  String get shareReflection;

  /// No description provided for @tourTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Complete Dashboard'**
  String get tourTitle1;

  /// No description provided for @tourDescription1.
  ///
  /// In en, this message translates to:
  /// **'Your journey to meaningful relationships starts here. Let\'s explore how this platform will help you find compatible matches and grow personally.'**
  String get tourDescription1;

  /// No description provided for @tourTitle2.
  ///
  /// In en, this message translates to:
  /// **'Match Journey'**
  String get tourTitle2;

  /// No description provided for @tourDescription2.
  ///
  /// In en, this message translates to:
  /// **'Discover potential matches based on psychological compatibility, not just appearance. Our AI matchmaker will guide conversations and help you build connections gradually.'**
  String get tourDescription2;

  /// No description provided for @tourTitle3.
  ///
  /// In en, this message translates to:
  /// **'Personal Insights'**
  String get tourTitle3;

  /// No description provided for @tourDescription3.
  ///
  /// In en, this message translates to:
  /// **'Receive honest, thoughtful feedback about your relationship patterns and readiness. Understanding yourself is the first step to finding meaningful connections.'**
  String get tourDescription3;

  /// No description provided for @tourTitle4.
  ///
  /// In en, this message translates to:
  /// **'Growth Pathway'**
  String get tourTitle4;

  /// No description provided for @tourDescription4.
  ///
  /// In en, this message translates to:
  /// **'Track your personal development with tailored activities that enhance your relationship skills and readiness. Growth and matching go hand in hand here.'**
  String get tourDescription4;

  /// No description provided for @tourTitle5.
  ///
  /// In en, this message translates to:
  /// **'AI Relationship Coach'**
  String get tourTitle5;

  /// No description provided for @tourDescription5.
  ///
  /// In en, this message translates to:
  /// **'Your AI coach will guide both your matching journey and personal growth, providing support, insights, and conversation facilitation.'**
  String get tourDescription5;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Experience'**
  String get personalizeExperience;

  /// No description provided for @customizeFeedback.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Feedback'**
  String get customizeFeedback;

  /// No description provided for @feedbackIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Our AI matchmaker and coach will provide guidance on both your matching journey and personal growth. Tell us how you prefer to receive feedback.'**
  String get feedbackIntroduction;

  /// No description provided for @chooseTone.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Feedback Tone'**
  String get chooseTone;

  /// No description provided for @chooseStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Communication Style'**
  String get chooseStyle;

  /// No description provided for @chooseFrequency.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Feedback Frequency'**
  String get chooseFrequency;

  /// No description provided for @directToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct & Straightforward'**
  String get directToneTitle;

  /// No description provided for @directToneDescription.
  ///
  /// In en, this message translates to:
  /// **'I appreciate clear, unfiltered feedback to help me improve quickly'**
  String get directToneDescription;

  /// No description provided for @balancedToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanced & Constructive'**
  String get balancedToneTitle;

  /// No description provided for @balancedToneDescription.
  ///
  /// In en, this message translates to:
  /// **'I want honest feedback balanced with encouragement and suggestions'**
  String get balancedToneDescription;

  /// No description provided for @gentleToneTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle & Supportive'**
  String get gentleToneTitle;

  /// No description provided for @gentleToneDescription.
  ///
  /// In en, this message translates to:
  /// **'I prefer feedback that emphasizes positives while gently suggesting improvements'**
  String get gentleToneDescription;

  /// No description provided for @analyticalStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytical'**
  String get analyticalStyleTitle;

  /// No description provided for @analyticalStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Data-driven insights and logical explanations'**
  String get analyticalStyleDescription;

  /// No description provided for @narrativeStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get narrativeStyleTitle;

  /// No description provided for @narrativeStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Story-based feedback that contextualizes observations'**
  String get narrativeStyleDescription;

  /// No description provided for @visualStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get visualStyleTitle;

  /// No description provided for @visualStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Heavy use of charts, progress indicators, and visual representations'**
  String get visualStyleDescription;

  /// No description provided for @weeklyFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyFrequencyTitle;

  /// No description provided for @weeklyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Regular feedback to keep me on track'**
  String get weeklyFrequencyDescription;

  /// No description provided for @biweeklyFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Bi-Weekly'**
  String get biweeklyFrequencyTitle;

  /// No description provided for @biweeklyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Consistent but not too frequent check-ins'**
  String get biweeklyFrequencyDescription;

  /// No description provided for @monthlyFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyFrequencyTitle;

  /// No description provided for @monthlyFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Periodic check-ins to review progress'**
  String get monthlyFrequencyDescription;

  /// No description provided for @onDemandFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Only When I Ask'**
  String get onDemandFrequencyTitle;

  /// No description provided for @onDemandFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'I prefer to control when I receive feedback'**
  String get onDemandFrequencyDescription;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences & Continue'**
  String get saveAndContinue;

  /// No description provided for @canChangePreferences.
  ///
  /// In en, this message translates to:
  /// **'You can change these preferences anytime in your settings'**
  String get canChangePreferences;

  /// No description provided for @selectAllPreferences.
  ///
  /// In en, this message translates to:
  /// **'Please select all preferences before continuing'**
  String get selectAllPreferences;

  /// No description provided for @errorSavingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error saving preferences'**
  String get errorSavingPreferences;

  /// No description provided for @relationshipReadiness.
  ///
  /// In en, this message translates to:
  /// **'Relationship Readiness'**
  String get relationshipReadiness;

  /// No description provided for @relationshipReadinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile and responses, our AI has assessed your relationship readiness:'**
  String get relationshipReadinessDesc;

  /// No description provided for @relationshipStrengths.
  ///
  /// In en, this message translates to:
  /// **'Your Relationship Strengths'**
  String get relationshipStrengths;

  /// No description provided for @strengthsDesc.
  ///
  /// In en, this message translates to:
  /// **'These are areas where you demonstrate strong relationship skills and qualities:'**
  String get strengthsDesc;

  /// No description provided for @areasForGrowth.
  ///
  /// In en, this message translates to:
  /// **'Areas for Growth'**
  String get areasForGrowth;

  /// No description provided for @growthAreasDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile analysis and relationship goals, we\'ve identified these areas where focused development could enhance your relationship success:'**
  String get growthAreasDesc;

  /// No description provided for @growthAreasNote.
  ///
  /// In en, this message translates to:
  /// **'Remember, these insights are meant to help you grow. Everyone has areas they can develop, and addressing these can lead to more fulfilling relationships.'**
  String get growthAreasNote;

  /// No description provided for @refreshInsights.
  ///
  /// In en, this message translates to:
  /// **'Refresh Insights'**
  String get refreshInsights;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @viewTutorial.
  ///
  /// In en, this message translates to:
  /// **'View Tutorial'**
  String get viewTutorial;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @privacyDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Discovery'**
  String get privacyDiscovery;

  /// No description provided for @enableDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Enable Discovery'**
  String get enableDiscovery;

  /// No description provided for @enableDiscoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow AI to recommend your profile to other users'**
  String get enableDiscoveryDesc;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about new matches and messages'**
  String get enableNotificationsDesc;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will permanently remove all your data, matches, and conversations. This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @finalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// No description provided for @finalDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. Are you absolutely sure?'**
  String get finalDeleteConfirmation;

  /// No description provided for @yesDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete My Account'**
  String get yesDeleteAccount;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changesSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get changesSuccessful;

  /// No description provided for @enableDiscoveryDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow others to see your profile and receive match recommendations'**
  String get enableDiscoveryDescription;

  /// No description provided for @enableNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about new matches and messages'**
  String get enableNotificationsDescription;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? All your data will be permanently lost.'**
  String get deleteAccountConfirmation;

  /// No description provided for @permanentDeletion.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your profile data, matches, and conversations will be deleted.'**
  String get permanentDeletion;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete My Account'**
  String get confirmDelete;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available yet'**
  String get featureNotAvailable;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed directly'**
  String get emailCannotBeChanged;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'re about to begin a different kind of matchmaking experience.'**
  String get welcomeDescription;

  /// No description provided for @createRichProfile.
  ///
  /// In en, this message translates to:
  /// **'Create a Rich Profile'**
  String get createRichProfile;

  /// No description provided for @createRichProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlike traditional apps, we\'ll help you build a comprehensive profile that captures your personality, values, and relationship vision.'**
  String get createRichProfileDesc;

  /// No description provided for @psychologicalAssessment.
  ///
  /// In en, this message translates to:
  /// **'Psychological Assessment'**
  String get psychologicalAssessment;

  /// No description provided for @psychologicalAssessmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Our brief psychological assessment helps identify your attachment style and relationship patterns.'**
  String get psychologicalAssessmentDesc;

  /// No description provided for @aiGuidedMatching.
  ///
  /// In en, this message translates to:
  /// **'AI-Guided Matching'**
  String get aiGuidedMatching;

  /// No description provided for @aiGuidedMatchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Our AI matchmaker will introduce you to compatible partners based on deep compatibility factors.'**
  String get aiGuidedMatchingDesc;

  /// No description provided for @meaningfulConversations.
  ///
  /// In en, this message translates to:
  /// **'Meaningful Conversations'**
  String get meaningfulConversations;

  /// No description provided for @meaningfulConversationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect through guided conversations designed to build understanding before meeting.'**
  String get meaningfulConversationsDesc;

  /// No description provided for @letsCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Create Your Profile'**
  String get letsCreateProfile;

  /// No description provided for @timeEstimate.
  ///
  /// In en, this message translates to:
  /// **'This will take about 20-30 minutes, but you can save and return anytime.'**
  String get timeEstimate;

  /// No description provided for @joinThousands.
  ///
  /// In en, this message translates to:
  /// **'Join thousands finding deep connection'**
  String get joinThousands;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get weakPassword;

  /// No description provided for @operationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Operation not allowed'**
  String get operationNotAllowed;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'This operation requires recent authentication. Please log in again'**
  String get requiresRecentLogin;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled'**
  String get userDisabled;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get tooManyRequests;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred'**
  String get authenticationError;

  /// No description provided for @googleSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign in was canceled'**
  String get googleSignInCanceled;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google'**
  String get googleSignInFailed;

  /// No description provided for @uploadImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get uploadImageFailed;

  /// No description provided for @getDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get document'**
  String get getDocumentFailed;

  /// No description provided for @addDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add document'**
  String get addDocumentFailed;

  /// No description provided for @setDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set document'**
  String get setDocumentFailed;

  /// No description provided for @updateDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update document'**
  String get updateDocumentFailed;

  /// No description provided for @deleteDocumentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete document'**
  String get deleteDocumentFailed;

  /// No description provided for @queryCollectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to query collection'**
  String get queryCollectionFailed;

  /// No description provided for @storageObjectNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get storageObjectNotFound;

  /// No description provided for @storageUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Not authorized to access this file'**
  String get storageUnauthorized;

  /// No description provided for @storageCanceled.
  ///
  /// In en, this message translates to:
  /// **'Upload was canceled'**
  String get storageCanceled;

  /// No description provided for @storageUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown storage error occurred'**
  String get storageUnknownError;

  /// No description provided for @storageInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get storageInvalidFormat;

  /// No description provided for @storageQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Storage quota exceeded'**
  String get storageQuotaExceeded;

  /// No description provided for @storageGenericError.
  ///
  /// In en, this message translates to:
  /// **'Storage error occurred'**
  String get storageGenericError;

  /// No description provided for @firestorePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get firestorePermissionDenied;

  /// No description provided for @firestoreNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get firestoreNotFound;

  /// No description provided for @firestoreAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Document already exists'**
  String get firestoreAlreadyExists;

  /// No description provided for @firestoreResourceExhausted.
  ///
  /// In en, this message translates to:
  /// **'Resource exhausted'**
  String get firestoreResourceExhausted;

  /// No description provided for @firestoreFailedPrecondition.
  ///
  /// In en, this message translates to:
  /// **'Failed precondition'**
  String get firestoreFailedPrecondition;

  /// No description provided for @firestoreAborted.
  ///
  /// In en, this message translates to:
  /// **'Operation was aborted'**
  String get firestoreAborted;

  /// No description provided for @firestoreOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Operation out of range'**
  String get firestoreOutOfRange;

  /// No description provided for @firestoreUnimplemented.
  ///
  /// In en, this message translates to:
  /// **'Operation not implemented'**
  String get firestoreUnimplemented;

  /// No description provided for @firestoreInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal error'**
  String get firestoreInternal;

  /// No description provided for @firestoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get firestoreUnavailable;

  /// No description provided for @firestoreDataLoss.
  ///
  /// In en, this message translates to:
  /// **'Data loss detected'**
  String get firestoreDataLoss;

  /// No description provided for @firestoreUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get firestoreUnauthenticated;

  /// No description provided for @firestoreGenericError.
  ///
  /// In en, this message translates to:
  /// **'Database error occurred'**
  String get firestoreGenericError;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @tapToChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Tap to change language'**
  String get tapToChangeLanguage;

  /// No description provided for @beginJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin Journey'**
  String get beginJourney;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @resetEmailSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your email for a link to reset your password.'**
  String get resetEmailSuccessMessage;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get forgotPasswordInstructions;

  /// No description provided for @missingLocalization.
  ///
  /// In en, this message translates to:
  /// **'Missing localization'**
  String get missingLocalization;

  /// No description provided for @featureAiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered'**
  String get featureAiPowered;

  /// No description provided for @featurePsychologicalMatching.
  ///
  /// In en, this message translates to:
  /// **'Psychological Matching'**
  String get featurePsychologicalMatching;

  /// No description provided for @featureValuesAlignment.
  ///
  /// In en, this message translates to:
  /// **'Values Alignment'**
  String get featureValuesAlignment;

  /// No description provided for @featureAttachmentStyle.
  ///
  /// In en, this message translates to:
  /// **'Attachment Style'**
  String get featureAttachmentStyle;

  /// No description provided for @featureGuidedIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Guided Introduction'**
  String get featureGuidedIntroduction;

  /// No description provided for @featureQualityOverQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quality Over Quantity'**
  String get featureQualityOverQuantity;

  /// No description provided for @notReadyYetTitle.
  ///
  /// In en, this message translates to:
  /// **'We believe timing is everything'**
  String get notReadyYetTitle;

  /// No description provided for @notReadyYetExplanation.
  ///
  /// In en, this message translates to:
  /// **'Based on your responses, it seems you might benefit from some time to focus on yourself before diving into our intensive matchmaking process.'**
  String get notReadyYetExplanation;

  /// No description provided for @successfulMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Our most successful members are:'**
  String get successfulMembersTitle;

  /// No description provided for @readinessCriteria1.
  ///
  /// In en, this message translates to:
  /// **'Emotionally available and healed from past relationships'**
  String get readinessCriteria1;

  /// No description provided for @readinessCriteria2.
  ///
  /// In en, this message translates to:
  /// **'Clear about their relationship goals and timeline'**
  String get readinessCriteria2;

  /// No description provided for @readinessCriteria3.
  ///
  /// In en, this message translates to:
  /// **'Ready to invest 30+ minutes daily in meaningful conversations'**
  String get readinessCriteria3;

  /// No description provided for @readinessCriteria4.
  ///
  /// In en, this message translates to:
  /// **'Committed to personal growth and authentic connection'**
  String get readinessCriteria4;

  /// No description provided for @understandTakeMeBack.
  ///
  /// In en, this message translates to:
  /// **'I understand, take me back'**
  String get understandTakeMeBack;

  /// No description provided for @notifyWhenReady.
  ///
  /// In en, this message translates to:
  /// **'Notify me when I can reapply'**
  String get notifyWhenReady;

  /// No description provided for @selfRespectMessage.
  ///
  /// In en, this message translates to:
  /// **'Taking time to prepare for love is an act of self-respect.\nWe\'ll be here when you\'re ready.'**
  String get selfRespectMessage;

  /// No description provided for @notifyModalTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll reach out when the time is right'**
  String get notifyModalTitle;

  /// No description provided for @notifyModalDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll notify you in 3-6 months when you can reapply to our exclusive community.'**
  String get notifyModalDescription;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @stayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get stayConnected;

  /// No description provided for @emailCaptureDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll check in with you in a few months to see if you\'re ready for our exclusive matchmaking experience.'**
  String get emailCaptureDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailPlaceholder;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @emailSavedConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Perfect! We\'ll reach out when you\'re ready for meaningful connection.'**
  String get emailSavedConfirmation;

  /// No description provided for @readinessAssessmentProgress.
  ///
  /// In en, this message translates to:
  /// **'READINESS ASSESSMENT • {current}/{total}'**
  String readinessAssessmentProgress(int current, int total);

  /// No description provided for @genuinelyReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re looking for members who are genuinely ready for meaningful relationships'**
  String get genuinelyReadyMessage;

  /// No description provided for @welcomeExclusiveCommunity.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Our Exclusive Community'**
  String get welcomeExclusiveCommunity;

  /// No description provided for @acceptedCommunityMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been accepted into a curated community of relationship-ready professionals. Your journey to meaningful connection starts now.'**
  String get acceptedCommunityMessage;

  /// No description provided for @whatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next:'**
  String get whatHappensNext;

  /// No description provided for @expectationStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Complete your comprehensive profile (20 min)'**
  String get expectationStep1;

  /// No description provided for @expectationStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Take psychological compatibility assessment (10 min)'**
  String get expectationStep2;

  /// No description provided for @expectationStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Meet your AI matchmaker'**
  String get expectationStep3;

  /// No description provided for @expectationStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Receive your first curated matches within 48 hours'**
  String get expectationStep4;

  /// No description provided for @createPremiumProfile.
  ///
  /// In en, this message translates to:
  /// **'Create My Premium Profile'**
  String get createPremiumProfile;

  /// No description provided for @averageTimeAndSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Average profile completion time: 28 minutes\nMember satisfaction rate: 94%'**
  String get averageTimeAndSatisfaction;

  /// No description provided for @readinessQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How long have you been single?'**
  String get readinessQuestion1;

  /// No description provided for @readinessAnswer1a.
  ///
  /// In en, this message translates to:
  /// **'Less than 3 months'**
  String get readinessAnswer1a;

  /// No description provided for @readinessAnswer1b.
  ///
  /// In en, this message translates to:
  /// **'3-6 months'**
  String get readinessAnswer1b;

  /// No description provided for @readinessAnswer1c.
  ///
  /// In en, this message translates to:
  /// **'6-12 months'**
  String get readinessAnswer1c;

  /// No description provided for @readinessAnswer1d.
  ///
  /// In en, this message translates to:
  /// **'Over a year'**
  String get readinessAnswer1d;

  /// No description provided for @readinessQuestion2.
  ///
  /// In en, this message translates to:
  /// **'What\'s your relationship goal timeline?'**
  String get readinessQuestion2;

  /// No description provided for @readinessAnswer2a.
  ///
  /// In en, this message translates to:
  /// **'I want to be married within 2 years'**
  String get readinessAnswer2a;

  /// No description provided for @readinessAnswer2b.
  ///
  /// In en, this message translates to:
  /// **'I\'m ready for a serious commitment'**
  String get readinessAnswer2b;

  /// No description provided for @readinessAnswer2c.
  ///
  /// In en, this message translates to:
  /// **'I\'m exploring what\'s possible'**
  String get readinessAnswer2c;

  /// No description provided for @readinessAnswer2d.
  ///
  /// In en, this message translates to:
  /// **'I\'m just curious about the app'**
  String get readinessAnswer2d;

  /// No description provided for @readinessQuestion3.
  ///
  /// In en, this message translates to:
  /// **'How much time can you dedicate to meaningful conversations?'**
  String get readinessQuestion3;

  /// No description provided for @readinessAnswer3a.
  ///
  /// In en, this message translates to:
  /// **'30+ minutes daily'**
  String get readinessAnswer3a;

  /// No description provided for @readinessAnswer3b.
  ///
  /// In en, this message translates to:
  /// **'15-30 minutes daily'**
  String get readinessAnswer3b;

  /// No description provided for @readinessAnswer3c.
  ///
  /// In en, this message translates to:
  /// **'A few times per week'**
  String get readinessAnswer3c;

  /// No description provided for @readinessAnswer3d.
  ///
  /// In en, this message translates to:
  /// **'When I feel like it'**
  String get readinessAnswer3d;

  /// No description provided for @invitationOnlyPremium.
  ///
  /// In en, this message translates to:
  /// **'INVITATION ONLY • PREMIUM MATCHMAKING'**
  String get invitationOnlyPremium;

  /// No description provided for @mainHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome to where intentional people find lasting love'**
  String get mainHeadline;

  /// No description provided for @socialProofMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re not another dating app. We\'re a selective community where quality relationships begin.'**
  String get socialProofMessage;

  /// No description provided for @memberDescription.
  ///
  /// In en, this message translates to:
  /// **'Only verified professionals who are serious about finding their life partner.'**
  String get memberDescription;

  /// No description provided for @beginExclusiveJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin Your Exclusive Journey'**
  String get beginExclusiveJourney;

  /// No description provided for @processDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This process takes 20-30 minutes.\nWe maintain high standards - apply thoughtfully.'**
  String get processDisclaimer;

  /// No description provided for @feedbackScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Get References'**
  String get feedbackScreenTitle;

  /// No description provided for @feedbackScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add credibility with feedback from people who know you well'**
  String get feedbackScreenSubtitle;

  /// No description provided for @whyReferencesMatter.
  ///
  /// In en, this message translates to:
  /// **'Why References Matter'**
  String get whyReferencesMatter;

  /// No description provided for @referencesExplanation.
  ///
  /// In en, this message translates to:
  /// **'Getting feedback from people who know you provides external validation and reveals blind spots in your self-assessment. Research shows that profiles with third-party validation are perceived as more trustworthy and receive more quality matches.'**
  String get referencesExplanation;

  /// No description provided for @feedbackProcess.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a short questionnaire to each person you list. Their responses will be summarized and integrated into your match profile.'**
  String get feedbackProcess;

  /// No description provided for @requestReferences.
  ///
  /// In en, this message translates to:
  /// **'Request References'**
  String get requestReferences;

  /// No description provided for @requestReferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add up to 3 people who know you well. At least one is recommended for a complete profile.'**
  String get requestReferencesDesc;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy Note'**
  String get privacyNote;

  /// No description provided for @privacyExplanation.
  ///
  /// In en, this message translates to:
  /// **'References will not see your answers to assessment questions. They will only provide their perspective on your key traits and relationship qualities. You\'ll be able to review their feedback before it\'s included in your profile.'**
  String get privacyExplanation;

  /// No description provided for @reference1.
  ///
  /// In en, this message translates to:
  /// **'Reference 1'**
  String get reference1;

  /// No description provided for @reference2.
  ///
  /// In en, this message translates to:
  /// **'Reference 2'**
  String get reference2;

  /// No description provided for @reference3.
  ///
  /// In en, this message translates to:
  /// **'Reference 3'**
  String get reference3;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get nameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get emailHint;

  /// No description provided for @relationshipToYou.
  ///
  /// In en, this message translates to:
  /// **'Relationship to You'**
  String get relationshipToYou;

  /// No description provided for @relationshipFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationshipFriend;

  /// No description provided for @relationshipFamily.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get relationshipFamily;

  /// No description provided for @relationshipFormerPartner.
  ///
  /// In en, this message translates to:
  /// **'Former Partner'**
  String get relationshipFormerPartner;

  /// No description provided for @relationshipColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get relationshipColleague;

  /// No description provided for @relationshipRoommate.
  ///
  /// In en, this message translates to:
  /// **'Roommate'**
  String get relationshipRoommate;

  /// No description provided for @skipFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip Feedback Requests?'**
  String get skipFeedbackTitle;

  /// No description provided for @skipFeedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Getting feedback from people who know you helps create a more accurate profile. Are you sure you want to skip this step?'**
  String get skipFeedbackMessage;

  /// No description provided for @skipAnyway.
  ///
  /// In en, this message translates to:
  /// **'Skip Anyway'**
  String get skipAnyway;

  /// No description provided for @sendRequests.
  ///
  /// In en, this message translates to:
  /// **'Send Requests'**
  String get sendRequests;

  /// No description provided for @feedbackRequestsSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback Requests Sent'**
  String get feedbackRequestsSent;

  /// No description provided for @feedbackRequestsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your feedback requests have been sent successfully! We\'ll notify you when responses come in.'**
  String get feedbackRequestsSuccess;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feedback data'**
  String get failedToLoad;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save feedback requests'**
  String get failedToSave;

  /// No description provided for @failedToSkip.
  ///
  /// In en, this message translates to:
  /// **'Failed to skip feedback step'**
  String get failedToSkip;

  /// No description provided for @emailSubject.
  ///
  /// In en, this message translates to:
  /// **'Help {userName} find meaningful love - Your perspective matters'**
  String emailSubject(Object userName);

  /// No description provided for @emailGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {referenceName}!'**
  String emailGreeting(Object referenceName);

  /// No description provided for @emailIntro.
  ///
  /// In en, this message translates to:
  /// **'{userName} has asked you to provide a character reference as part of their application to an exclusive matchmaking platform.'**
  String emailIntro(Object userName);

  /// No description provided for @emailExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your honest perspective about {userName}\'s personality and relationship qualities will help create a more complete picture for potential matches.'**
  String emailExplanation(Object userName);

  /// No description provided for @emailTimeEstimate.
  ///
  /// In en, this message translates to:
  /// **'This will take about 5 minutes of your time.'**
  String get emailTimeEstimate;

  /// No description provided for @emailCTA.
  ///
  /// In en, this message translates to:
  /// **'Provide Reference'**
  String get emailCTA;

  /// No description provided for @emailFooter.
  ///
  /// In en, this message translates to:
  /// **'This reference is confidential and will only be used to enhance {userName}\'s matchmaking profile.'**
  String emailFooter(Object userName);

  /// No description provided for @emailDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'If you received this email in error or prefer not to participate, you can simply ignore it.'**
  String get emailDisclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
