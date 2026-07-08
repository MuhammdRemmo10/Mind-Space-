import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MindSpace'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your mind. Organized.'**
  String get appTagline;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @notAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get noRecordsYet;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{action} will be available soon.'**
  String comingSoon(Object action);

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @spaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get spaces;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @moreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access articles, files, settings, and profile sections from here.'**
  String get moreSubtitle;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notes, tasks, and articles you marked as important.'**
  String get favoritesSubtitle;

  /// No description provided for @archiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content you moved out of active work without deleting.'**
  String get archiveSubtitle;

  /// No description provided for @trashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted content stays here until you restore it.'**
  String get trashSubtitle;

  /// No description provided for @contentLibraryFailed.
  ///
  /// In en, this message translates to:
  /// **'Content could not be loaded.'**
  String get contentLibraryFailed;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get removeFromFavorites;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite content yet.'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark notes, tasks, or articles as favorite to find them here.'**
  String get emptyFavoritesSubtitle;

  /// No description provided for @emptyArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty.'**
  String get emptyArchiveTitle;

  /// No description provided for @emptyArchiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived content will appear here.'**
  String get emptyArchiveSubtitle;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty.'**
  String get emptyTrashTitle;

  /// No description provided for @emptyTrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes, tasks, and articles will appear here.'**
  String get emptyTrashSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumPriority;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highPriority;

  /// No description provided for @urgentPriority.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentPriority;

  /// No description provided for @privateVisibility.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateVisibility;

  /// No description provided for @friendsVisibility.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsVisibility;

  /// No description provided for @publicVisibility.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicVisibility;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your mind. Organized.'**
  String get splashTagline;

  /// No description provided for @onboardingWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write. Organize. Achieve.'**
  String get onboardingWriteTitle;

  /// No description provided for @onboardingWriteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture ideas, organize your knowledge, and focus on your goals.'**
  String get onboardingWriteSubtitle;

  /// No description provided for @onboardingAllInOneTitle.
  ///
  /// In en, this message translates to:
  /// **'All in One Place'**
  String get onboardingAllInOneTitle;

  /// No description provided for @onboardingAllInOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notes, tasks, articles, and spaces in one workspace.'**
  String get onboardingAllInOneSubtitle;

  /// No description provided for @onboardingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Everywhere'**
  String get onboardingSyncTitle;

  /// No description provided for @onboardingSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your mind from any device. Your data stays up to date.'**
  String get onboardingSyncSubtitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your mind. Organized.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authFeatureNotes.
  ///
  /// In en, this message translates to:
  /// **'Organize your notes'**
  String get authFeatureNotes;

  /// No description provided for @authFeatureTasks.
  ///
  /// In en, this message translates to:
  /// **'Track your tasks'**
  String get authFeatureTasks;

  /// No description provided for @authFeatureSync.
  ///
  /// In en, this message translates to:
  /// **'Stay synced on every device'**
  String get authFeatureSync;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your MindSpace account.'**
  String get loginSubtitle;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start organizing your information securely.'**
  String get registerSubtitle;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinLength;

  /// No description provided for @fullNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters.'**
  String get fullNameMinLength;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters.'**
  String get usernameMinLength;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Email address or password is incorrect.'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account. Check your information.'**
  String get registerFailed;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your notes, spaces, tasks, and ideas in one organized system.'**
  String get dashboardSubtitle;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// No description provided for @createSpace.
  ///
  /// In en, this message translates to:
  /// **'Create Space'**
  String get createSpace;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @dashboardFocusReady.
  ///
  /// In en, this message translates to:
  /// **'Your workspace is ready for today'**
  String get dashboardFocusReady;

  /// No description provided for @dashboardMostActiveSpace.
  ///
  /// In en, this message translates to:
  /// **'Most active space: {space}'**
  String dashboardMostActiveSpace(Object space);

  /// No description provided for @dashboardWritingSummary.
  ///
  /// In en, this message translates to:
  /// **'{days}-day writing streak, {words} words written.'**
  String dashboardWritingSummary(Object days, Object words);

  /// No description provided for @openAll.
  ///
  /// In en, this message translates to:
  /// **'Open All'**
  String get openAll;

  /// No description provided for @emptySpacesPreview.
  ///
  /// In en, this message translates to:
  /// **'No spaces yet. Create your first space and start your MindSpace map.'**
  String get emptySpacesPreview;

  /// No description provided for @notesWorkspaceFallback.
  ///
  /// In en, this message translates to:
  /// **'Workspace for notes'**
  String get notesWorkspaceFallback;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Notes'**
  String get recentNotes;

  /// No description provided for @recentTasks.
  ///
  /// In en, this message translates to:
  /// **'Recent Tasks'**
  String get recentTasks;

  /// No description provided for @statisticsSummary.
  ///
  /// In en, this message translates to:
  /// **'Statistics Summary'**
  String get statisticsSummary;

  /// No description provided for @writingStreak.
  ///
  /// In en, this message translates to:
  /// **'Writing Streak'**
  String get writingStreak;

  /// No description provided for @wordsWritten.
  ///
  /// In en, this message translates to:
  /// **'Words Written'**
  String get wordsWritten;

  /// No description provided for @mostActiveSpace.
  ///
  /// In en, this message translates to:
  /// **'Most Active Space'**
  String get mostActiveSpace;

  /// No description provided for @mostUsedTags.
  ///
  /// In en, this message translates to:
  /// **'Most Used Tags'**
  String get mostUsedTags;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noTagsYet;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Dashboard could not be loaded'**
  String get dashboardLoadFailed;

  /// No description provided for @dashboardDataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Dashboard data could not be loaded.'**
  String get dashboardDataLoadFailed;

  /// No description provided for @totalSpaces.
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get totalSpaces;

  /// No description provided for @totalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get totalNotes;

  /// No description provided for @totalTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get totalTasks;

  /// No description provided for @totalArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get totalArticles;

  /// No description provided for @totalFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get totalFiles;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String dayCount(num count);

  /// No description provided for @spacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize spaces for your notes only.'**
  String get spacesSubtitle;

  /// No description provided for @spacesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Spaces could not be loaded.'**
  String get spacesLoadFailed;

  /// No description provided for @deleteSpaceQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this space?'**
  String get deleteSpaceQuestion;

  /// No description provided for @deleteSpaceContent.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be moved to Trash. You can restore it later.'**
  String deleteSpaceContent(Object name);

  /// No description provided for @activeSpacesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active spaces} one{1 active space} other{{count} active spaces}}'**
  String activeSpacesCount(num count);

  /// No description provided for @pinnedFavoriteSpaces.
  ///
  /// In en, this message translates to:
  /// **'{pinned} pinned, {favorites} favorite spaces'**
  String pinnedFavoriteSpaces(Object pinned, Object favorites);

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get operations;

  /// No description provided for @spaceNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description has been added for this space.'**
  String get spaceNoDescription;

  /// No description provided for @openNotes.
  ///
  /// In en, this message translates to:
  /// **'Open Notes'**
  String get openNotes;

  /// No description provided for @emptySpacesTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not created a space yet.'**
  String get emptySpacesTitle;

  /// No description provided for @emptySpacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first space and start organizing your notes.'**
  String get emptySpacesSubtitle;

  /// No description provided for @createFirstSpace.
  ///
  /// In en, this message translates to:
  /// **'Create First Space'**
  String get createFirstSpace;

  /// No description provided for @editSpace.
  ///
  /// In en, this message translates to:
  /// **'Edit Space'**
  String get editSpace;

  /// No description provided for @spaceName.
  ///
  /// In en, this message translates to:
  /// **'Space name'**
  String get spaceName;

  /// No description provided for @spaceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Space name is required.'**
  String get spaceNameRequired;

  /// No description provided for @notesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your ideas, links, and content in the selected space.'**
  String get notesSubtitle;

  /// No description provided for @notesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Notes could not be loaded.'**
  String get notesLoadFailed;

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @notesNeedSpace.
  ///
  /// In en, this message translates to:
  /// **'You need to create a space first.'**
  String get notesNeedSpace;

  /// No description provided for @notesNeedSpaceLong.
  ///
  /// In en, this message translates to:
  /// **'You need to create a space before creating a note.'**
  String get notesNeedSpaceLong;

  /// No description provided for @notesEmptyInSpace.
  ///
  /// In en, this message translates to:
  /// **'There are no notes in this space yet.'**
  String get notesEmptyInSpace;

  /// No description provided for @contentMissing.
  ///
  /// In en, this message translates to:
  /// **'No content added.'**
  String get contentMissing;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note Details'**
  String get noteDetails;

  /// No description provided for @noteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes} one{1 note} other{{count} notes}}'**
  String noteCount(num count);

  /// No description provided for @noSpaceSelected.
  ///
  /// In en, this message translates to:
  /// **'No space selected'**
  String get noSpaceSelected;

  /// No description provided for @inSpace.
  ///
  /// In en, this message translates to:
  /// **'In {space}'**
  String inSpace(Object space);

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get space;

  /// No description provided for @spaceRequired.
  ///
  /// In en, this message translates to:
  /// **'Space selection is required.'**
  String get spaceRequired;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleRequired;

  /// No description provided for @friendVisibilityShort.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friendVisibilityShort;

  /// No description provided for @publicVisibilityShort.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicVisibilityShort;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create task lists and track daily work in separate flows.'**
  String get tasksSubtitle;

  /// No description provided for @tasksLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Tasks could not be loaded.'**
  String get tasksLoadFailed;

  /// No description provided for @defaultTaskListName.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get defaultTaskListName;

  /// No description provided for @defaultTaskListDescription.
  ///
  /// In en, this message translates to:
  /// **'Your daily tasks'**
  String get defaultTaskListDescription;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create Task'**
  String get createTask;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createList;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get newList;

  /// No description provided for @tasksNeedList.
  ///
  /// In en, this message translates to:
  /// **'You need to create a task list first.'**
  String get tasksNeedList;

  /// No description provided for @taskProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} tasks'**
  String taskProgress(Object completed, Object total);

  /// No description provided for @listFullyCompleted.
  ///
  /// In en, this message translates to:
  /// **'List is 100% complete'**
  String get listFullyCompleted;

  /// No description provided for @completionStatus.
  ///
  /// In en, this message translates to:
  /// **'Completion Status'**
  String get completionStatus;

  /// No description provided for @noListSelected.
  ///
  /// In en, this message translates to:
  /// **'No list selected'**
  String get noListSelected;

  /// No description provided for @taskListProgressSentence.
  ///
  /// In en, this message translates to:
  /// **'{list} has {completed} / {total} tasks'**
  String taskListProgressSentence(Object list, Object completed, Object total);

  /// No description provided for @percentageValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentageValue(Object value);

  /// No description provided for @taskCompletedSentence.
  ///
  /// In en, this message translates to:
  /// **'Task is 100% complete.'**
  String get taskCompletedSentence;

  /// No description provided for @taskIncompleteSentence.
  ///
  /// In en, this message translates to:
  /// **'Task is not completed.'**
  String get taskIncompleteSentence;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'There are no tasks in this list yet.'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create the first task and start tracking this list.'**
  String get emptyTasksSubtitle;

  /// No description provided for @createTaskList.
  ///
  /// In en, this message translates to:
  /// **'Create Task List'**
  String get createTaskList;

  /// No description provided for @taskListName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get taskListName;

  /// No description provided for @taskListNameRequired.
  ///
  /// In en, this message translates to:
  /// **'List name is required.'**
  String get taskListNameRequired;

  /// No description provided for @taskList.
  ///
  /// In en, this message translates to:
  /// **'Task list'**
  String get taskList;

  /// No description provided for @taskListRequired.
  ///
  /// In en, this message translates to:
  /// **'Task list selection is required.'**
  String get taskListRequired;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Task title is required.'**
  String get taskTitleRequired;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetails;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @markIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Incomplete'**
  String get markIncomplete;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile information could not be loaded.'**
  String get profileLoadFailed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changeCoverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Change cover photo'**
  String get changeCoverPhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @defaultBiography.
  ///
  /// In en, this message translates to:
  /// **'I organize my mind every day.'**
  String get defaultBiography;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage language, theme, notifications, security, and backup preferences.'**
  String get settingsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get systemLanguage;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get backupRestore;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @settingsAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Settings'**
  String get settingsAction;

  /// No description provided for @articlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize long-form writing, cover images, and publishing flow.'**
  String get articlesSubtitle;

  /// No description provided for @createArticle.
  ///
  /// In en, this message translates to:
  /// **'Create Article'**
  String get createArticle;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @publishedArticles.
  ///
  /// In en, this message translates to:
  /// **'Published articles'**
  String get publishedArticles;

  /// No description provided for @readingTime.
  ///
  /// In en, this message translates to:
  /// **'Reading time'**
  String get readingTime;

  /// No description provided for @taggedArticles.
  ///
  /// In en, this message translates to:
  /// **'Tagged articles'**
  String get taggedArticles;

  /// No description provided for @articlesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Articles could not be loaded.'**
  String get articlesLoadFailed;

  /// No description provided for @articlesNeedSpace.
  ///
  /// In en, this message translates to:
  /// **'Create a space first.'**
  String get articlesNeedSpace;

  /// No description provided for @articlesNeedSpaceLong.
  ///
  /// In en, this message translates to:
  /// **'Articles live inside note spaces. Create a space, then start writing.'**
  String get articlesNeedSpaceLong;

  /// No description provided for @articlesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No articles in this space yet.'**
  String get articlesEmpty;

  /// No description provided for @articlesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write a long-form article, add a cover image, and publish it when it is ready.'**
  String get articlesEmptySubtitle;

  /// No description provided for @articleCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No articles} one{1 article} other{{count} articles}}'**
  String articleCountSummary(num count);

  /// No description provided for @selectCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Select cover image'**
  String get selectCoverImage;

  /// No description provided for @changeCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get changeCoverImage;

  /// No description provided for @articleContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Article content is required.'**
  String get articleContentRequired;

  /// No description provided for @publishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get publishNow;

  /// No description provided for @publishNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn this on to make the article visible with the selected privacy level.'**
  String get publishNowSubtitle;

  /// No description provided for @publishArticle.
  ///
  /// In en, this message translates to:
  /// **'Publish Article'**
  String get publishArticle;

  /// No description provided for @profileArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get profileArticles;

  /// No description provided for @noProfileArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles have been published yet.'**
  String get noProfileArticles;

  /// No description provided for @articleReadingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String articleReadingMinutes(Object minutes);

  /// No description provided for @filesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store images, PDFs, documents, audio, and video attachments neatly.'**
  String get filesSubtitle;

  /// No description provided for @addFile.
  ///
  /// In en, this message translates to:
  /// **'Add File'**
  String get addFile;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @pdfFiles.
  ///
  /// In en, this message translates to:
  /// **'PDF files'**
  String get pdfFiles;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @audioVideo.
  ///
  /// In en, this message translates to:
  /// **'Audio and video'**
  String get audioVideo;
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
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
