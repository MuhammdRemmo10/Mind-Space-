// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MindSpace';

  @override
  String get appTagline => 'Your mind. Organized.';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get retry => 'Retry';

  @override
  String get notAdded => 'Not added';

  @override
  String get noRecordsYet => 'No records yet.';

  @override
  String comingSoon(Object action) {
    return '$action will be available soon.';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get spaces => 'Spaces';

  @override
  String get notes => 'Notes';

  @override
  String get tasks => 'Tasks';

  @override
  String get articles => 'Articles';

  @override
  String get files => 'Files';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get more => 'More';

  @override
  String get moreSubtitle =>
      'Access articles, files, settings, and profile sections from here.';

  @override
  String get favorites => 'Favorites';

  @override
  String get archive => 'Archive';

  @override
  String get trash => 'Trash';

  @override
  String get favoritesSubtitle =>
      'Notes, tasks, and articles you marked as important.';

  @override
  String get archiveSubtitle =>
      'Content you moved out of active work without deleting.';

  @override
  String get trashSubtitle =>
      'Deleted content stays here until you restore it.';

  @override
  String get contentLibraryFailed => 'Content could not be loaded.';

  @override
  String get restore => 'Restore';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove Favorite';

  @override
  String get note => 'Note';

  @override
  String get task => 'Task';

  @override
  String get article => 'Article';

  @override
  String get emptyFavoritesTitle => 'No favorite content yet.';

  @override
  String get emptyFavoritesSubtitle =>
      'Mark notes, tasks, or articles as favorite to find them here.';

  @override
  String get emptyArchiveTitle => 'Archive is empty.';

  @override
  String get emptyArchiveSubtitle => 'Archived content will appear here.';

  @override
  String get emptyTrashTitle => 'Trash is empty.';

  @override
  String get emptyTrashSubtitle =>
      'Deleted notes, tasks, and articles will appear here.';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get country => 'Country';

  @override
  String get biography => 'Biography';

  @override
  String get fullName => 'Full name';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get description => 'Description';

  @override
  String get title => 'Title';

  @override
  String get content => 'Content';

  @override
  String get color => 'Color';

  @override
  String get visibility => 'Visibility';

  @override
  String get priority => 'Priority';

  @override
  String get lowPriority => 'Low';

  @override
  String get mediumPriority => 'Medium';

  @override
  String get highPriority => 'High';

  @override
  String get urgentPriority => 'Urgent';

  @override
  String get privateVisibility => 'Private';

  @override
  String get friendsVisibility => 'Friends';

  @override
  String get publicVisibility => 'Public';

  @override
  String get skip => 'Skip';

  @override
  String get splashTagline => 'Your mind. Organized.';

  @override
  String get onboardingWriteTitle => 'Write. Organize. Achieve.';

  @override
  String get onboardingWriteSubtitle =>
      'Capture ideas, organize your knowledge, and focus on your goals.';

  @override
  String get onboardingAllInOneTitle => 'All in One Place';

  @override
  String get onboardingAllInOneSubtitle =>
      'Notes, tasks, articles, and spaces in one workspace.';

  @override
  String get onboardingSyncTitle => 'Sync Everywhere';

  @override
  String get onboardingSyncSubtitle =>
      'Access your mind from any device. Your data stays up to date.';

  @override
  String get authWelcomeSubtitle => 'Your mind. Organized.';

  @override
  String get authFeatureNotes => 'Organize your notes';

  @override
  String get authFeatureTasks => 'Track your tasks';

  @override
  String get authFeatureSync => 'Stay synced on every device';

  @override
  String get login => 'Log In';

  @override
  String get createAccount => 'Create Account';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Log in to your MindSpace account.';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start organizing your information securely.';

  @override
  String get emailRequired => 'Email is required.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters.';

  @override
  String get fullNameMinLength => 'Full name must be at least 2 characters.';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters.';

  @override
  String get loginFailed => 'Email address or password is incorrect.';

  @override
  String get registerFailed =>
      'Could not create the account. Check your information.';

  @override
  String get dashboardSubtitle =>
      'Manage your notes, spaces, tasks, and ideas in one organized system.';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get createSpace => 'Create Space';

  @override
  String get newNote => 'New Note';

  @override
  String get newTask => 'New Task';

  @override
  String get dashboardFocusReady => 'Your workspace is ready for today';

  @override
  String dashboardMostActiveSpace(Object space) {
    return 'Most active space: $space';
  }

  @override
  String dashboardWritingSummary(Object days, Object words) {
    return '$days-day writing streak, $words words written.';
  }

  @override
  String get openAll => 'Open All';

  @override
  String get emptySpacesPreview =>
      'No spaces yet. Create your first space and start your MindSpace map.';

  @override
  String get notesWorkspaceFallback => 'Workspace for notes';

  @override
  String get recentNotes => 'Recent Notes';

  @override
  String get recentTasks => 'Recent Tasks';

  @override
  String get statisticsSummary => 'Statistics Summary';

  @override
  String get writingStreak => 'Writing Streak';

  @override
  String get wordsWritten => 'Words Written';

  @override
  String get mostActiveSpace => 'Most Active Space';

  @override
  String get mostUsedTags => 'Most Used Tags';

  @override
  String get noTagsYet => 'None yet';

  @override
  String get dashboardLoadFailed => 'Dashboard could not be loaded';

  @override
  String get dashboardDataLoadFailed => 'Dashboard data could not be loaded.';

  @override
  String get totalSpaces => 'Spaces';

  @override
  String get totalNotes => 'Notes';

  @override
  String get totalTasks => 'Tasks';

  @override
  String get totalArticles => 'Articles';

  @override
  String get totalFiles => 'Files';

  @override
  String dayCount(num count) {
    return '$count days';
  }

  @override
  String get spacesSubtitle => 'Organize spaces for your notes only.';

  @override
  String get spacesLoadFailed => 'Spaces could not be loaded.';

  @override
  String get deleteSpaceQuestion => 'Delete this space?';

  @override
  String deleteSpaceContent(Object name) {
    return '\"$name\" will be moved to Trash. You can restore it later.';
  }

  @override
  String activeSpacesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active spaces',
      one: '1 active space',
      zero: 'No active spaces',
    );
    return '$_temp0';
  }

  @override
  String pinnedFavoriteSpaces(Object pinned, Object favorites) {
    return '$pinned pinned, $favorites favorite spaces';
  }

  @override
  String get operations => 'Actions';

  @override
  String get spaceNoDescription =>
      'No description has been added for this space.';

  @override
  String get openNotes => 'Open Notes';

  @override
  String get emptySpacesTitle => 'You have not created a space yet.';

  @override
  String get emptySpacesSubtitle =>
      'Create your first space and start organizing your notes.';

  @override
  String get createFirstSpace => 'Create First Space';

  @override
  String get editSpace => 'Edit Space';

  @override
  String get spaceName => 'Space name';

  @override
  String get spaceNameRequired => 'Space name is required.';

  @override
  String get notesSubtitle =>
      'Organize your ideas, links, and content in the selected space.';

  @override
  String get notesLoadFailed => 'Notes could not be loaded.';

  @override
  String get createNote => 'Create Note';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get notesNeedSpace => 'You need to create a space first.';

  @override
  String get notesNeedSpaceLong =>
      'You need to create a space before creating a note.';

  @override
  String get notesEmptyInSpace => 'There are no notes in this space yet.';

  @override
  String get contentMissing => 'No content added.';

  @override
  String get noteDetails => 'Note Details';

  @override
  String noteCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes',
    );
    return '$_temp0';
  }

  @override
  String get noSpaceSelected => 'No space selected';

  @override
  String inSpace(Object space) {
    return 'In $space';
  }

  @override
  String get space => 'Space';

  @override
  String get spaceRequired => 'Space selection is required.';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get friendVisibilityShort => 'Friend';

  @override
  String get publicVisibilityShort => 'Public';

  @override
  String get tasksSubtitle =>
      'Create task lists and track daily work in separate flows.';

  @override
  String get tasksLoadFailed => 'Tasks could not be loaded.';

  @override
  String get defaultTaskListName => 'Daily';

  @override
  String get defaultTaskListDescription => 'Your daily tasks';

  @override
  String get createTask => 'Create Task';

  @override
  String get createList => 'Create List';

  @override
  String get newList => 'New List';

  @override
  String get tasksNeedList => 'You need to create a task list first.';

  @override
  String taskProgress(Object completed, Object total) {
    return '$completed/$total tasks';
  }

  @override
  String get listFullyCompleted => 'List is 100% complete';

  @override
  String get completionStatus => 'Completion Status';

  @override
  String get noListSelected => 'No list selected';

  @override
  String taskListProgressSentence(Object list, Object completed, Object total) {
    return '$list has $completed / $total tasks';
  }

  @override
  String percentageValue(Object value) {
    return '$value%';
  }

  @override
  String get taskCompletedSentence => 'Task is 100% complete.';

  @override
  String get taskIncompleteSentence => 'Task is not completed.';

  @override
  String get emptyTasksTitle => 'There are no tasks in this list yet.';

  @override
  String get emptyTasksSubtitle =>
      'Create the first task and start tracking this list.';

  @override
  String get createTaskList => 'Create Task List';

  @override
  String get taskListName => 'List name';

  @override
  String get taskListNameRequired => 'List name is required.';

  @override
  String get taskList => 'Task list';

  @override
  String get taskListRequired => 'Task list selection is required.';

  @override
  String get taskTitle => 'Task title';

  @override
  String get taskTitleRequired => 'Task title is required.';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get markIncomplete => 'Mark Incomplete';

  @override
  String get profileLoadFailed => 'Profile information could not be loaded.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeCoverPhoto => 'Change cover photo';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get defaultBiography => 'I organize my mind every day.';

  @override
  String get settingsSubtitle =>
      'Manage language, theme, notifications, security, and backup preferences.';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get turkish => 'Turkish';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get backupRestore => 'Backup and restore';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'About';

  @override
  String get settingsAction => 'Edit Settings';

  @override
  String get articlesSubtitle =>
      'Organize long-form writing, cover images, and publishing flow.';

  @override
  String get createArticle => 'Create Article';

  @override
  String get drafts => 'Drafts';

  @override
  String get draft => 'Draft';

  @override
  String get published => 'Published';

  @override
  String get publishedArticles => 'Published articles';

  @override
  String get readingTime => 'Reading time';

  @override
  String get taggedArticles => 'Tagged articles';

  @override
  String get articlesLoadFailed => 'Articles could not be loaded.';

  @override
  String get articlesNeedSpace => 'Create a space first.';

  @override
  String get articlesNeedSpaceLong =>
      'Articles live inside note spaces. Create a space, then start writing.';

  @override
  String get articlesEmpty => 'No articles in this space yet.';

  @override
  String get articlesEmptySubtitle =>
      'Write a long-form article, add a cover image, and publish it when it is ready.';

  @override
  String articleCountSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'No articles',
    );
    return '$_temp0';
  }

  @override
  String get selectCoverImage => 'Select cover image';

  @override
  String get changeCoverImage => 'Change cover';

  @override
  String get articleContentRequired => 'Article content is required.';

  @override
  String get publishNow => 'Publish now';

  @override
  String get publishNowSubtitle =>
      'Turn this on to make the article visible with the selected privacy level.';

  @override
  String get publishArticle => 'Publish Article';

  @override
  String get profileArticles => 'Articles';

  @override
  String get noProfileArticles => 'No articles have been published yet.';

  @override
  String articleReadingMinutes(Object minutes) {
    return '$minutes min read';
  }

  @override
  String get filesSubtitle =>
      'Store images, PDFs, documents, audio, and video attachments neatly.';

  @override
  String get addFile => 'Add File';

  @override
  String get images => 'Images';

  @override
  String get pdfFiles => 'PDF files';

  @override
  String get documents => 'Documents';

  @override
  String get audioVideo => 'Audio and video';
}
