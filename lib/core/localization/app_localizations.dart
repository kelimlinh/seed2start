import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

abstract class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('vi'),
    Locale('en'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations chưa được khởi tạo.');
    return localizations!;
  }

  String get appName;
  String get welcome;
  String get login;
  String get register;
  String get email;
  String get password;
  String get name;
  String get forgotPassword;
  String get noAccount;
  String get haveAccount;
  String get logout;
  String get home;
  String get invalidEmail;
  String get weakPassword;
  String get wrongCredentials;
  String get emailUsed;
  String get somethingWrong;
  String get language;
  String get vietnamese;
  String get english;
  String get loginSubtitle;
  String get createYourAccount;
  String get registerSubtitle;
  String get confirmPassword;
  String get showPassword;
  String get hidePassword;
  String get emailRequired;
  String get passwordRequired;
  String get nameRequired;
  String get passwordsDoNotMatch;
  String get enterEmailToReset;
  String get resetEmailSent;
  String get tooManyRequests;
  String get registrationUnavailable;

  String get hello;
  String helloName(String name);
  String get homeSubtitle;
  String get today;
  String get dailyFocusTitle;
  String get dailyFocusBody;
  String get yourSpace;
  String get journey;
  String get workbook;
  String get me;
  String get goals;
  String get reflection;
  String get journeySummary;
  String get goalsSummary;
  String get reflectionSummary;
  String get workbookSummary;
  String get gentleReminder;
  String get moduleComingSoon;
  String get homeContinueJourney;
  String get homeJourneyComplete;
  String get homeThreeChapters;
  String get homeMeetMam;
  String get homeMamBody;
  String get continueJourney;
  String get openWorkbook;

  String get addGoal;
  String get goalsPageSubtitle;
  String get activeGoals;
  String get completedGoals;
  String get inProgress;
  String get done;
  String get noGoalsYet;
  String get noGoalsBody;
  String get createFirstGoal;
  String get newGoal;
  String get editGoal;
  String get goalTitle;
  String get goalTitleHint;
  String get goalDescription;
  String get goalDescriptionHint;
  String get goalTimeframe;
  String get shortTerm;
  String get longTerm;
  String get progress;
  String get createGoal;
  String get saveChanges;
  String get goalTitleRequired;
  String get goalCreated;
  String get goalUpdated;
  String get goalActions;
  String get delete;
  String get deleteGoal;
  String get deleteGoalConfirm;
  String get goalsLoadError;
  String get tryAgainLater;

  String get journeyTitle;
  String get journeyPageSubtitle;
  String get yourHeroProgress;
  String journeyProgressText(int completed, int total);
  String get heroTitle;
  String get heroSubtitle;
  String get hope;
  String get hopeSubtitle;
  String get selfEfficacy;
  String get selfEfficacySubtitle;
  String get resilience;
  String get resilienceSubtitle;
  String get optimism;
  String get optimismSubtitle;
  String get smallActivities;
  String get hopeActivityOneTitle;
  String get hopeActivityOneBody;
  String get hopeActivityTwoTitle;
  String get hopeActivityTwoBody;
  String get efficacyActivityOneTitle;
  String get efficacyActivityOneBody;
  String get efficacyActivityTwoTitle;
  String get efficacyActivityTwoBody;
  String get resilienceActivityOneTitle;
  String get resilienceActivityOneBody;
  String get resilienceActivityTwoTitle;
  String get resilienceActivityTwoBody;
  String get optimismActivityOneTitle;
  String get optimismActivityOneBody;
  String get optimismActivityTwoTitle;
  String get optimismActivityTwoBody;
  String get markActivityComplete;
  String get markActivityIncomplete;
  String get journeyLoadError;

  String get reflectionPageSubtitle;
  String get howAreYouToday;
  String get moodPrompt;
  String get moodVeryLow;
  String get moodLow;
  String get moodOkay;
  String get moodGood;
  String get moodGreat;
  String get moodLoadError;
  String get recentReflections;
  String get addReflection;
  String get writeReflection;
  String get editReflection;
  String get reflectionPrompt;
  String get reflectionHint;
  String get reflectionRequired;
  String get saveReflection;
  String get reflectionSaved;
  String get reflectionUpdated;
  String get reflectionLoadError;
  String get noReflectionsYet;
  String get noReflectionsBody;
  String get reflectionActions;
  String get deleteReflection;
  String get deleteReflectionConfirm;
  String get justNow;

  String get workbookPageSubtitle;
  String workbookChapterNumber(int number);
  String workbookChapterProgressText(int completed, int total);
  String get workbookYourProgress;
  String workbookProgressText(int completed, int total);
  String workbookSectionTitle(String sectionId);
  String workbookLessonTitle(String lessonId);
  String workbookLessonSummary(String lessonId);
  String workbookLessonNumber(int number);
  String get workbookDigitalCompanion;
  String get workbookAskMam;
  String get workbookReturnToBook;
  String get workbookReturnToBookBody;
  String workbookCompanionPrompt(String lessonId);
  String workbookOpenLinkedActivity(String lessonId);
  String get workbookMarkComplete;
  String get workbookMarkIncomplete;
  String get workbookLoadError;
  String get workbookLessonNotFound;
  String get workbookQrLink;
  String get copy;
  String get copied;

  String get progressSpace;
  String get progressPageSubtitle;
  String levelNumber(int level);
  String totalXp(int xp);
  String xpToNextLevel(int xp);
  String get currentStreak;
  String get badgesEarned;
  String get yourBadges;
  String get howXpWorks;
  String get earned;
  String get notYet;
  String get badgeFirstStep;
  String get badgeFirstStepBody;
  String get badgeLevelTwo;
  String get badgeLevelTwoBody;
  String get badgeLevelFour;
  String get badgeLevelFourBody;
  String get badgeStreakThree;
  String get badgeStreakThreeBody;
  String get badgeStreakSeven;
  String get badgeStreakSevenBody;
  String get rewardMood;
  String get rewardReflection;
  String get rewardJourney;
  String get rewardWorkbook;
  String get rewardGoal;
  String get gamificationLoadError;
  String get personalProgress;
  String streakDays(int days);

  String get aiCoach;
  String get aiHomeSummary;
  String get aiGreeting;
  String get aiSubtitle;
  String get aiPromptGoal;
  String get aiPromptReflection;
  String get aiPromptDifficulty;
  String get aiPromptStrengths;
  String get aiEmpty;
  String get aiInputHint;
  String get aiError;
  String get aiClearConversation;

  String get profile;
  String get profileSubtitle;
  String get student;
  String get editName;
  String get save;
  String get cancel;
  String get profileUpdated;
  String get privacy;
  String get privateByDefault;
  String get privacyDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(
        locale.languageCode == 'en'
            ? AppLocalizationsEn(locale)
            : AppLocalizationsVi(locale),
      );

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
