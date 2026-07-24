import 'package:flutter/widgets.dart';
import 'lang_en.dart';
import 'lang_fr.dart';
import 'lang_nl.dart';
import 'lang_de.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('nl'),
    Locale('de'),
    Locale('en'),
  ];

  // Core string tables – each language lives in its own file for easy extension.
  static final Map<String, Map<String, String>> _values =
      <String, Map<String, String>>{
        'fr': kLangFr,
        'nl': kLangNl,
        'de': kLangDe,
        'en': kLangEn,
      };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String _t(String key) {
    final lang = locale.languageCode;
    return _values[lang]?[key] ?? _values['en']![key] ?? key;
  }

  // Strongly-typed getters for most-used strings
  String get login => _t('login');
  String get signup => _t('signup');
  String get email => _t('email');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get forgotPassword => _t('forgotPassword');
  String get resetPassword => _t('resetPassword');
  String get resetPasswordTitle => _t('resetPasswordTitle');
  String get resetPasswordSubtitle => _t('resetPasswordSubtitle');
  String get sendResetLink => _t('sendResetLink');
  String get backToLogin => _t('backToLogin');
  String get otpVerification => _t('otpVerification');
  String get otpVerificationTitle => _t('otpVerificationTitle');
  String get otpVerificationSubtitle => _t('otpVerificationSubtitle');
  String get verify => _t('verify');
  String get resendCode => _t('resendCode');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get createNewPasswordTitle => _t('createNewPasswordTitle');
  String get createNewPasswordSubtitle => _t('createNewPasswordSubtitle');
  String get newPassword => _t('newPassword');
  String get confirmNewPassword => _t('confirmNewPassword');
  String get updatePassword => _t('updatePassword');
  String get passwordResetSuccess => _t('passwordResetSuccess');
  String get passwordResetSuccessMessage => _t('passwordResetSuccessMessage');
  String get loginWith => _t('loginWith');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get firstName => _t('firstName');
  String get lastName => _t('lastName');

  String get onbSkip => _t('onbSkip');
  String get onb1Title => _t('onb1Title');
  String get onb1Subtitle => _t('onb1Subtitle');
  String get onb2Title => _t('onb2Title');
  String get onb2Subtitle => _t('onb2Subtitle');
  String get onb3Title => _t('onb3Title');
  String get onb3Subtitle => _t('onb3Subtitle');
  String get onb4Title => _t('onb4Title');
  String get onb4Subtitle => _t('onb4Subtitle');

  // Home Screen
  String get search => _t('search');
  String get hello => _t('hello');
  String get topCategories => _t('topCategories');
  String get seeAll => _t('seeAll');
  String get popularCourses => _t('popularCourses');
  String get aiSuggestions => _t('aiSuggestions');
  String get mostRecent => _t('mostRecent');
  String get lessons => _t('lessons');
  String get reviews => _t('reviews');
  String get courses => _t('courses');
  String get home => _t('home');
  String get message => _t('message');
  String get myCourse => _t('myCourse');
  String get wishlist => _t('wishlist');
  String get savedForLater => _t('savedForLater');
  String wishlistCoursesCount(int count) =>
      _t('wishlistCoursesCount').replaceAll('{count}', '$count');
  String get recentlyAdded => _t('recentlyAdded');
  String get priceLowToHigh => _t('priceLowToHigh');
  String get priceHighToLow => _t('priceHighToLow');
  String get highestRated => _t('highestRated');
  String get removeFromWishlist => _t('removeFromWishlist');
  String get removedFromWishlist => _t('removedFromWishlist');
  String get failedUpdateWishlist => _t('failedUpdateWishlist');
  String get emptyWishlistTitle => _t('emptyWishlistTitle');
  String get emptyWishlistSubtitle => _t('emptyWishlistSubtitle');
  String get browseCourses => _t('browseCourses');
  String get freeCourse => _t('freeCourse');
  String wishlistLessonsCount(int count) =>
      _t('wishlistLessonsCount').replaceAll('{count}', '$count');
  String get events => _t('events');
  String get profile => _t('profile');

  // Filter
  String get searchFilter => _t('searchFilter');
  String get categories => _t('categories');
  String get price => _t('price');
  String get duration => _t('duration');
  String get design => _t('design');
  String get painting => _t('painting');
  String get coding => _t('coding');
  String get music => _t('music');
  String get visualIdentity => _t('visualIdentity');
  String get mathematics => _t('mathematics');
  String get hours3to8 => _t('hours3to8');
  String get hours8to14 => _t('hours8to14');
  String get hours14to20 => _t('hours14to20');
  String get hours20to24 => _t('hours20to24');
  String get hours24to30 => _t('hours24to30');
  String get complexity => _t('complexity');
  String get beginner => _t('beginner');
  String get intermediate => _t('intermediate');
  String get advanced => _t('advanced');
  String get reviewRating => _t('reviewRating');
  String get stars4Plus => _t('stars4Plus');
  String get stars3Plus => _t('stars3Plus');
  String get stars2Plus => _t('stars2Plus');
  String get stars1Plus => _t('stars1Plus');
  String get clear => _t('clear');
  String get applyFilter => _t('applyFilter');

  // Course Details
  String get courseDetails => _t('courseDetails');
  String get aboutThisCourse => _t('aboutThisCourse');
  String get readMore => _t('readMore');
  String get playlist => _t('playlist');
  String get review => _t('review');
  String get students => _t('students');
  String get enrollCourse => _t('enrollCourse');
  String get whatIsUiDesign => _t('whatIsUiDesign');
  String get courseDescription => _t('courseDescription');
  String get readLess => _t('readLess');
  String get video => _t('video');
  String get quiz => _t('quiz');
  String get assignment => _t('assignment');
  String get curriculums => _t('curriculums');
  String get instructor => _t('instructor');
  String get instructorCard => _t('instructorCard');

  // Profile
  String get settings => _t('settings');
  String get settingsSubtitle => _t('settingsSubtitle');
  String get myCourses => _t('myCourses');
  String get myCoursesSubtitle => _t('myCoursesSubtitle');
  String get wishlistSubtitle => _t('wishlistSubtitle');
  String get aiPreferences => _t('aiPreferences');
  String get aiPreferencesSubtitle => _t('aiPreferencesSubtitle');
  String get notifications => _t('notifications');
  String get notificationsSubtitle => _t('notificationsSubtitle');
  String get notificationCenter => _t('notificationCenter');
  String unreadNotificationsCount(int count) =>
      _t('unreadNotificationsCount').replaceAll('{count}', '$count');
  String get allNotificationsRead => _t('allNotificationsRead');
  String get markAllAsRead => _t('markAllAsRead');
  String get allNotificationsMarkedRead => _t('allNotificationsMarkedRead');
  String get allNotifications => _t('allNotifications');
  String get unreadNotifications => _t('unreadNotifications');
  String get newNotification => _t('newNotification');
  String get noNotificationsTitle => _t('noNotificationsTitle');
  String get noNotificationsSubtitle => _t('noNotificationsSubtitle');
  String get noUnreadNotificationsTitle => _t('noUnreadNotificationsTitle');
  String get noUnreadNotificationsSubtitle =>
      _t('noUnreadNotificationsSubtitle');
  String get showAllNotifications => _t('showAllNotifications');
  String get failedLoadNotifications => _t('failedLoadNotifications');
  String get notificationsLoadErrorSubtitle =>
      _t('notificationsLoadErrorSubtitle');
  String get failedLoadMoreNotifications => _t('failedLoadMoreNotifications');
  String get notificationActionFailed => _t('notificationActionFailed');
  String get notificationDeleted => _t('notificationDeleted');
  String get deleteNotification => _t('deleteNotification');
  String get darkMode => _t('darkMode');
  String get darkModeSubtitle => _t('darkModeSubtitle');
  String get language => _t('language');
  String get helpSupport => _t('helpSupport');
  String get helpSupportSubtitle => _t('helpSupportSubtitle');
  String get about => _t('about');
  String get aboutSubtitle => _t('aboutSubtitle');
  String get logout => _t('logout');
  String get level => _t('level');
  String get levelValue => _t('levelValue');
  String get accountCourses => _t('accountCourses');
  String get preferences => _t('preferences');
  String get supportInfo => _t('supportInfo');
  String get guestUser => _t('guestUser');

  String get learningAndProgress => _t('learningAndProgress');
  String get learningOverviewSubtitle => _t('learningOverviewSubtitle');
  String get assignmentsSubtitle => _t('assignmentsSubtitle');

  String get productivityAndTracking => _t('productivityAndTracking');
  String get studyTimerSubtitle => _t('studyTimerSubtitle');
  String get focusProgressSubtitle => _t('focusProgressSubtitle');
  String get weeklyReviewSubtitle => _t('weeklyReviewSubtitle');
  String get hourShort => _t('hourShort');
  String get noFocusData => _t('noFocusData');
  String get failedLoadFocusProgress => _t('failedLoadFocusProgress');

  String get aiTools => _t('aiTools');
  String get novaAiAssistant => _t('novaAiAssistant');
  String get novaAiAssistantSubtitle => _t('novaAiAssistantSubtitle');
  String get aiLearningPathGenerator => _t('aiLearningPathGenerator');
  String get aiLearningPathSubtitle => _t('aiLearningPathSubtitle');
  String get aiPathPersonalizeTitle => _t('aiPathPersonalizeTitle');
  String get aiPathPersonalizeSubtitle => _t('aiPathPersonalizeSubtitle');
  String get aiPathCategories => _t('aiPathCategories');
  String get aiPathCategoriesHint => _t('aiPathCategoriesHint');
  String get aiPathSkillLevel => _t('aiPathSkillLevel');
  String get aiPathBeginner => _t('aiPathBeginner');
  String get aiPathIntermediate => _t('aiPathIntermediate');
  String get aiPathAdvanced => _t('aiPathAdvanced');
  String get aiPathGoal => _t('aiPathGoal');
  String get aiPathCareerChange => _t('aiPathCareerChange');
  String get aiPathSkillEnhancement => _t('aiPathSkillEnhancement');
  String get aiPathPersonalInterest => _t('aiPathPersonalInterest');
  String get aiPathCertification => _t('aiPathCertification');
  String get aiPathFreelancing => _t('aiPathFreelancing');
  String get aiPathCustom => _t('aiPathCustom');
  String get aiPathCustomGoal => _t('aiPathCustomGoal');
  String get aiPathWeeklyHours => _t('aiPathWeeklyHours');
  String get aiPathTargetDate => _t('aiPathTargetDate');
  String get aiPathChooseDate => _t('aiPathChooseDate');
  String get aiPathClearDate => _t('aiPathClearDate');
  String get aiPathLanguage => _t('aiPathLanguage');
  String get aiPathLearningStyle => _t('aiPathLearningStyle');
  String get aiPathFast => _t('aiPathFast');
  String get aiPathBalanced => _t('aiPathBalanced');
  String get aiPathInDepth => _t('aiPathInDepth');
  String get aiPathSaveAnalyze => _t('aiPathSaveAnalyze');
  String get aiPathReadyTitle => _t('aiPathReadyTitle');
  String get aiPathReadyBody => _t('aiPathReadyBody');
  String get aiPathNoMatching => _t('aiPathNoMatching');
  String get aiPathInsufficient => _t('aiPathInsufficient');
  String get aiPathAllCompleted => _t('aiPathAllCompleted');
  String get aiPathProfileRequired => _t('aiPathProfileRequired');
  String get aiPathGenerate => _t('aiPathGenerate');
  String get aiPathGenerating => _t('aiPathGenerating');
  String get aiPathCurrentTitle => _t('aiPathCurrentTitle');
  String get aiPathWeeks => _t('aiPathWeeks');
  String get aiPathHours => _t('aiPathHours');
  String get aiPathObjective => _t('aiPathObjective');
  String get aiPathWhy => _t('aiPathWhy');
  String get aiPathEditPreferences => _t('aiPathEditPreferences');
  String get aiPathArchive => _t('aiPathArchive');
  String get aiPathArchiveTitle => _t('aiPathArchiveTitle');
  String get aiPathArchiveBody => _t('aiPathArchiveBody');
  String get aiPathCancel => _t('aiPathCancel');
  String get aiPathConfirmArchive => _t('aiPathConfirmArchive');
  String get aiPathLoading => _t('aiPathLoading');
  String get aiPathRetry => _t('aiPathRetry');
  String get aiPathSelectCategoryError => _t('aiPathSelectCategoryError');
  String get aiPathCustomGoalError => _t('aiPathCustomGoalError');
  String get aiPathWeeklyHoursError => _t('aiPathWeeklyHoursError');
  String get aiPathConnectionError => _t('aiPathConnectionError');
  String get aiPathCheckAvailability => _t('aiPathCheckAvailability');
  String get novaIsThinking => _t('novaIsThinking');

  String get novaWelcomeTitle => _t('novaWelcomeTitle');

  String get novaWelcomeMessage => _t('novaWelcomeMessage');

  String get aiConfigurationMissing => _t('aiConfigurationMissing');

  String get aiAssistantUnavailable => _t('aiAssistantUnavailable');

  String get unavailable => _t('unavailable');

  String get community => _t('community');
  String get accountAndPayments => _t('accountAndPayments');
  String get settingsAndPreferences => _t('settingsAndPreferences');

  // Chat
  String get messages => _t('messages');
  String get privateConversations => _t('privateConversations');
  String unreadMessagesCount(int count) =>
      _t('unreadMessagesCount').replaceAll('{count}', '$count');
  String get allCaughtUp => _t('allCaughtUp');
  String get inbox => _t('inbox');
  String get sentRequests => _t('sentRequests');
  String get failedLoadConversations => _t('failedLoadConversations');
  String get checkConnectionAndRetry => _t('checkConnectionAndRetry');
  String get noConversationsTitle => _t('noConversationsTitle');
  String get noConversationsSubtitle => _t('noConversationsSubtitle');
  String get noPendingRequestsTitle => _t('noPendingRequestsTitle');
  String get noPendingRequestsSubtitle => _t('noPendingRequestsSubtitle');
  String get newMessage => _t('newMessage');
  String get startConversation => _t('startConversation');
  String get awaitingResponse => _t('awaitingResponse');
  String get chooseInstructorToStart => _t('chooseInstructorToStart');
  String get searchInstructors => _t('searchInstructors');
  String get searchingInstructors => _t('searchingInstructors');
  String get noInstructorsFound => _t('noInstructorsFound');
  String get searchInstructorTitle => _t('searchInstructorTitle');
  String get tryAnotherSearch => _t('tryAnotherSearch');
  String get typeToSearchInstructors => _t('typeToSearchInstructors');
  String get typeMessage => _t('typeMessage');
  String get secureChat => _t('secureChat');
  String get failedLoadMessages => _t('failedLoadMessages');
  String get noMessagesTitle => _t('noMessagesTitle');
  String get noMessagesSubtitle => _t('noMessagesSubtitle');
  String get chooseAttachment => _t('chooseAttachment');
  String get camera => _t('camera');
  String get gallery => _t('gallery');
  String get files => _t('files');
  String get takePhoto => _t('takePhoto');
  String get chooseFromGallery => _t('chooseFromGallery');
  String get chooseFiles => _t('chooseFiles');
  String selectedAttachmentsCount(int count) =>
      _t('selectedAttachmentsCount').replaceAll('{count}', '$count');
  String get removeAttachment => _t('removeAttachment');
  String get sendMessage => _t('sendMessage');
  String get messageSending => _t('messageSending');
  String get imageUnavailable => _t('imageUnavailable');
  String get online => _t('online');
  String get typing => _t('typing');
  String get sent => _t('sent');
  String get delivered => _t('delivered');
  String get read => _t('read');
  String get now => _t('now');
  String get minutesAgo => _t('minutesAgo');
  String get hoursAgo => _t('hoursAgo');
  String get yesterday => _t('yesterday');
  String get viewProfile => _t('viewProfile');
  String get muteNotifications => _t('muteNotifications');
  String get clearChat => _t('clearChat');
  String get blockUser => _t('blockUser');
  String get reportUser => _t('reportUser');
  String get chatHistory => _t('chatHistory');
  String get tellUsAboutYourself => _t('tellUsAboutYourself');
  String get whatAreYourInterests => _t('whatAreYourInterests');
  String get selectYourInterests => _t('selectYourInterests');
  String get whatIsYourSkillLevel => _t('whatIsYourSkillLevel');
  String get whatAreYourGoals => _t('whatAreYourGoals');
  String get getPersonalizedCourses => _t('getPersonalizedCourses');
  String get basedOnYourPreferences => _t('basedOnYourPreferences');
  String get recommendedForYou => _t('recommendedForYou');
  String get startLearning => _t('startLearning');
  String get updatePreferences => _t('updatePreferences');
  String get dashboard => _t('dashboard');
  String get payments => _t('payments');
  String get myAssignments => _t('myAssignments');
  String get myQuizAttempts => _t('myQuizAttempts');
  String get certificates => _t('certificates');
  String get continueLearning => _t('continueLearning');
  String get completed => _t('completed');
  String get confirmed => _t('confirmed');
  String get inProgress => _t('inProgress');
  String get notStarted => _t('notStarted');
  String get totalCourses => _t('totalCourses');
  String get completedCourses => _t('completedCourses');
  String get inProgressCourses => _t('inProgressCourses');
  String get totalSpent => _t('totalSpent');
  String get recentPayments => _t('recentPayments');
  String get paymentHistory => _t('paymentHistory');
  String get dueDate => _t('dueDate');
  String get submitted => _t('submitted');
  String get pending => _t('pending');
  String get graded => _t('graded');
  String get score => _t('score');
  String get attempts => _t('attempts');
  String get quizHistory => _t('quizHistory');
  String get earnedCertificates => _t('earnedCertificates');
  String get download => _t('download');
  String get view => _t('view');
  String get noCourses => _t('noCourses');
  String get noCoursesFound => _t('noCoursesFound');
  String get noOngoingCourses => _t('noOngoingCourses');
  String get noCompletedCourses => _t('noCompletedCourses');
  String get noPayments => _t('noPayments');
  String get noAssignments => _t('noAssignments');
  String get noQuizAttempts => _t('noQuizAttempts');
  String get noCertificates => _t('noCertificates');
  String get ongoing => _t('ongoing');
  String get myTicketBookings => _t('myTicketBookings');
  String get ticketBookings => _t('ticketBookings');
  String get totalTickets => _t('totalTickets');
  String get confirmedTickets => _t('confirmedTickets');
  String get noTicketBookings => _t('noTicketBookings');
  String get failedLoadBookings => _t('failedLoadBookings');
  String get standardTicket => _t('standardTicket');
  String get quantity => _t('quantity');
  String get seats => _t('seats');
  String get cancelled => _t('cancelled');
  String get learningActivity => _t('learningActivity');
  String get learningHours => _t('learningHours');
  String get totalHours => _t('totalHours');
  String get all => _t('all');
  String get assignmentDetails => _t('assignmentDetails');
  String get submittedDate => _t('submittedDate');
  String get assignmentDescription => _t('assignmentDescription');
  String get requirements => _t('requirements');
  String get submitAssignment => _t('submitAssignment');
  String get attachFiles => _t('attachFiles');
  String get addFile => _t('addFile');
  String get comments => _t('comments');
  String get addComments => _t('addComments');
  String get submit => _t('submit');
  String get assignmentSubmittedSuccessfully =>
      _t('assignmentSubmittedSuccessfully');
  String get pleaseAttachAtLeastOneFile => _t('pleaseAttachAtLeastOneFile');
  String get assignmentSubmittedSuccessMessage =>
      _t('assignmentSubmittedSuccessMessage');
  String get ok => _t('ok');
  String get invalidCouponCode => _t('invalidCouponCode');
  String get pleaseFillInAllFields => _t('pleaseFillInAllFields');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get verificationCodeResent => _t('verificationCodeResent');
  String get quickAccess => _t('quickAccess');
  String get joinLiveClass => _t('joinLiveClass');
  String get passed => _t('passed');
  String get failed => _t('failed');
  String get recent => _t('recent');
  String get thisYear => _t('thisYear');
  String get certificate => _t('certificate');
  String get certificateOfCompletion => _t('certificateOfCompletion');
  String get thisCertificateAwarded => _t('thisCertificateAwarded');
  String get issuedDate => _t('issuedDate');
  String get certificateId => _t('certificateId');
  String get verifiedCertificate => _t('verifiedCertificate');
  String get certificateVerificationDescription =>
      _t('certificateVerificationDescription');
  String get copiedToClipboard => _t('copiedToClipboard');
  String get share => _t('share');
  String get downloading => _t('downloading');
  String get ticketDetails => _t('ticketDetails');
  String get date => _t('date');
  String get time => _t('time');
  String get venue => _t('venue');
  String get bookingInformation => _t('bookingInformation');
  String get totalPrice => _t('totalPrice');
  String get bookingId => _t('bookingId');
  String get downloadTicket => _t('downloadTicket');
  String get eTicket => _t('eTicket');
  String get scanQRCodeInstruction => _t('scanQRCodeInstruction');
  String get ticketDuration => _t('ticketDuration');
  String get passenger => _t('passenger');
  String get idNumber => _t('idNumber');
  String get passengerType => _t('passengerType');
  String get adult => _t('adult');
  String get general => _t('general');
  String get carriage => _t('carriage');
  String get noSeatAssigned => _t('noSeatAssigned');
  String get transactionDetails => _t('transactionDetails');
  String get course => _t('course');
  String get paymentMethod => _t('paymentMethod');
  String get startQuiz => _t('startQuiz');
  String get aboutEvent => _t('aboutEvent');
  String get bookTicket => _t('bookTicket');
  String get registerNow => _t('registerNow');
  String get eventDetails => _t('eventDetails');
  String get attendees => _t('attendees');
  String get category => _t('category');
  String get free => _t('free');
  String get shareEvent => _t('shareEvent');
  String get location => _t('location');
  String get aboutThisEvent => _t('aboutThisEvent');
  String get alreadyBooked => _t('alreadyBooked');
  // Rewards & Points
  String get rewardsAndPoints => _t('rewardsAndPoints');
  String get yourPoints => _t('yourPoints');
  String get pointsToNextLevel => _t('pointsToNextLevel');
  String get badges => _t('badges');
  String get leaderboard => _t('leaderboard');
  String get earnedBadges => _t('earnedBadges');
  String get topLearners => _t('topLearners');
  String get points => _t('points');
  // Affiliate
  String get affiliateProgram => _t('affiliateProgram');
  String get totalEarnings => _t('totalEarnings');
  String get referrals => _t('referrals');
  String get thisMonth => _t('thisMonth');
  String get yourAffiliateLink => _t('yourAffiliateLink');
  String get yourAffiliateCode => _t('yourAffiliateCode');
  String get linkCopiedToClipboard => _t('linkCopiedToClipboard');
  String get codeCopiedToClipboard => _t('codeCopiedToClipboard');
  String get howItWorks => _t('howItWorks');
  String get shareYourLink => _t('shareYourLink');
  String get shareYourLinkDescription => _t('shareYourLinkDescription');
  String get theyEnroll => _t('theyEnroll');
  String get theyEnrollDescription => _t('theyEnrollDescription');
  String get youEarn => _t('youEarn');
  String get youEarnDescription => _t('youEarnDescription');
  String get commissionRates => _t('commissionRates');
  String get bronze => _t('bronze');
  String get silver => _t('silver');
  String get gold => _t('gold');
  String get shareAffiliateLink => _t('shareAffiliateLink');
  // Offline Courses
  String get offlineCourses => _t('offlineCourses');
  String get noOfflineCourses => _t('noOfflineCourses');
  String get noOfflineCoursesDescription => _t('noOfflineCoursesDescription');
  // Live Courses
  String get liveCourses => _t('liveCourses');
  String get join => _t('join');
  String get joinWhenLive => _t('joinWhenLive');
  String get live => _t('live');
  String get upcoming => _t('upcoming');
  String get ended => _t('ended');
  String get today => _t('today');
  String get tomorrow => _t('tomorrow');
  String get noLiveCourses => _t('noLiveCourses');
  String get noLiveCoursesDescription => _t('noLiveCoursesDescription');
  // Live Video
  String get typeAComment => _t('typeAComment');
  String get noCommentsYet => _t('noCommentsYet');
  String get joinLiveNow => _t('joinLiveNow');
  String get classEnded => _t('classEnded');
  String get participants => _t('participants');

  // AI Course Generator
  String get aiCourseGenerator => _t('aiCourseGenerator');
  String get poweredByAi => _t('poweredByAi');
  String get courseTitle => _t('courseTitle');
  String get numberOfModules => _t('numberOfModules');
  String get lessonsPerModule => _t('lessonsPerModule');
  String get numberOfQuizzes => _t('numberOfQuizzes');
  String get numberOfAssignments => _t('numberOfAssignments');
  String get generateCourse => _t('generateCourse');
  String get generating => _t('generating');
  String get courseOutline => _t('courseOutline');
  String get aiGenerated => _t('aiGenerated');
  String get courseModules => _t('courseModules');
  String get regenerate => _t('regenerate');
  String get startWriting => _t('startWriting');
  String get modules => _t('modules');
  String get quizzes => _t('quizzes');
  String get assignments => _t('assignments');

  // AI Lesson Writer
  String get aiLessonWriter => _t('aiLessonWriter');
  String get courseStructure => _t('courseStructure');
  String get aiAssistant => _t('aiAssistant');
  String get saveDraft => _t('saveDraft');
  String get saveLesson => _t('saveLesson');
  String get enterLessonTitle => _t('enterLessonTitle');
  String get startWritingLessonContent => _t('startWritingLessonContent');

  // Lesson Saved Success
  String get lessonSaved => _t('lessonSaved');
  String get lessonSavedMessage => _t('lessonSavedMessage');
  String get goToHomepage => _t('goToHomepage');

  // AI Video Notes Extractor
  String get aiVideoNotesExtractor => _t('aiVideoNotesExtractor');
  String get videoNotes => _t('videoNotes');
  String get uploadVideo => _t('uploadVideo');
  String get tapToSelectVideo => _t('tapToSelectVideo');
  String get supportedFormats => _t('supportedFormats');
  String get videoSelected => _t('videoSelected');
  String get extractNotes => _t('extractNotes');
  String get processing => _t('processing');
  String get videoNotesInfo => _t('videoNotesInfo');
  String get keyPoints => _t('keyPoints');
  String get videoSummary => _t('videoSummary');
  String get videoQuiz => _t('videoQuiz');

  // AI Voice Tutor
  String get aiVoiceTutor => _t('aiVoiceTutor');
  String get voiceTutorSubtitle => _t('voiceTutorSubtitle');
  String get voiceTutorDescription => _t('voiceTutorDescription');
  String get doubts => _t('doubts');
  String get summaries => _t('summaries');
  String get typeYourQuestion => _t('typeYourQuestion');
  String get listening => _t('listening');
  String get voiceTranscripts => _t('voiceTranscripts');
  String get transcriptsDescription => _t('transcriptsDescription');

  // Habit Tracker
  String get habitTracker => _t('habitTracker');
  String get createHabit => _t('createHabit');
  String get habitCreationInfo => _t('habitCreationInfo');
  String get habitName => _t('habitName');
  String get habitNameHint => _t('habitNameHint');
  String get frequency => _t('frequency');
  String get bestTime => _t('bestTime');
  String get morning => _t('morning');
  String get afternoon => _t('afternoon');
  String get evening => _t('evening');
  String get daysPerWeek => _t('daysPerWeek');
  String get days => _t('days');
  String get enableReminder => _t('enableReminder');
  String get reminderDescription => _t('reminderDescription');
  String get progress => _t('progress');
  String get streaks => _t('streaks');
  String get weeklyReview => _t('weeklyReview');
  String get streakDays => _t('streakDays');
  String get completionRate => _t('completionRate');
  String get activeHabits => _t('activeHabits');
  String get weeklyProgress => _t('weeklyProgress');
  String get daysThisWeek => _t('daysThisWeek');
  String get totalStreak => _t('totalStreak');
  String get longestStreak => _t('longestStreak');
  String get activeStreaks => _t('activeStreaks');
  String get yourStreaks => _t('yourStreaks');
  String get currentStreak => _t('currentStreak');
  String get thisWeek => _t('thisWeek');
  String get completedDays => _t('completedDays');
  String get missedDays => _t('missedDays');
  String get habitsThisWeek => _t('habitsThisWeek');
  String get noWeeklyReviewData => _t('noWeeklyReviewData');

  String get failedLoadWeeklyReview => _t('failedLoadWeeklyReview');

  // Study Timer
  String get studyTimer => _t('studyTimer');
  String get focusProgress => _t('focusProgress');
  String get taskBreakdown => _t('taskBreakdown');
  String get focus => _t('focus');
  String get shortBreak => _t('shortBreak');
  String get longBreak => _t('longBreak');
  String get minutes => _t('minutes');
  String get start => _t('start');
  String get pause => _t('pause');
  String get resume => _t('resume');
  String get reset => _t('reset');
  String get sessionsToday => _t('sessionsToday');
  String get totalFocusTime => _t('totalFocusTime');
  String get dailyAverage => _t('dailyAverage');
  String get dayStreak => _t('dayStreak');
  String get focusHours => _t('focusHours');
  String get dailyDetails => _t('dailyDetails');
  String get hours => _t('hours');
  String get focusTime => _t('focusTime');
  String get completedTasks => _t('completedTasks');
  String get remaining => _t('remaining');
  String get allTasks => _t('allTasks');
  String get custom => _t('custom');
  String get setCustomTime => _t('setCustomTime');
  String get customTimeDescription => _t('customTimeDescription');
  String get cancel => _t('cancel');
  String get set => _t('set');

  // Community Rooms
  String get groupChatRooms => _t('groupChatRooms');
  String get searchRooms => _t('searchRooms');
  String get activeRooms => _t('activeRooms');
  String get members => _t('members');
  String get topicCommunity => _t('topicCommunity');
  String get popular => _t('popular');
  String get trending => _t('trending');
  String get posts => _t('posts');
  String get qaRoom => _t('qaRoom');
  String get unanswered => _t('unanswered');
  String get myQuestions => _t('myQuestions');
  String get answered => _t('answered');
  String get joinCommunityDiscussion => _t('joinCommunityDiscussion');
  String get exploreTopicsAndDiscussions => _t('exploreTopicsAndDiscussions');
  String get askAndAnswerQuestions => _t('askAndAnswerQuestions');
  String get roomOptions => _t('roomOptions');
  String get viewRoomInfo => _t('viewRoomInfo');
  String get viewMembers => _t('viewMembers');
  String get leaveRoom => _t('leaveRoom');
  String get question => _t('question');
  String get questionOptions => _t('questionOptions');
  String get shareQuestion => _t('shareQuestion');
  String get saveQuestion => _t('saveQuestion');
  String get reportQuestion => _t('reportQuestion');
  String get answers => _t('answers');
  String get writeAnswer => _t('writeAnswer');
  String get postAnswer => _t('postAnswer');
  String get accept => _t('accept');
  String get accepted => _t('accepted');
  String get writeComment => _t('writeComment');
  String get postComment => _t('postComment');

  // Course access
  String get markComplete => _t('markComplete');
  String get curriculum => _t('curriculum');
  String get forums => _t('forums');
  String get previousLesson => _t('previousLesson');
  String get nextLesson => _t('nextLesson');
  String get lessonCompleted => _t('lessonCompleted');
  String get lessonLocked => _t('lessonLocked');
  String get unsupportedItemType => _t('unsupportedItemType');
  String get selectLessonToPlay => _t('selectLessonToPlay');
  String get videoUnavailable => _t('videoUnavailable');
  String get videoUnavailableMessage => _t('videoUnavailableMessage');
  String get retry => _t('retry');
  String get liveNow => _t('liveNow');
  String get sessionEnded => _t('sessionEnded');
  String get scheduled => _t('scheduled');
  String get startsAt => _t('startsAt');
  String get openJoiningLink => _t('openJoiningLink');
  String get liveClassSession => _t('liveClassSession');
  String get liveSessionEndedMessage => _t('liveSessionEndedMessage');
  String get accessDeniedCourse => _t('accessDeniedCourse');
  String get failedToLoadCourse => _t('failedToLoadCourse');
  String get failedToLoadLesson => _t('failedToLoadLesson');
  String get failedToLoadCourseData => _t('failedToLoadCourseData');
  String get notAvailable => _t('notAvailable');
  String get liveClassLabel => _t('liveClassLabel');
  String get lessonsCompleted => _t('lessonsCompleted');
  String get noActivity => _t('noActivity');
  String get complete => _t('complete');
  String get failedLoadCourses => _t('failedLoadCourses');
  String get total => _t('total');
  String get sessionSaved => _t('sessionSaved');
  String get congratulations => _t('congratulations');
  String get completedSessionMessage => _t('completedSessionMessage');

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AuthScreenLocalizations on AppLocalizations {
  String get authInvalidInputTitle => _t('authInvalidInputTitle');

  String get authEnterEmailAndPassword => _t('authEnterEmailAndPassword');

  String get authOtpSentTitle => _t('authOtpSentTitle');

  String get authVerifyEmailPrompt => _t('authVerifyEmailPrompt');

  String get authLoginSuccessfulTitle => _t('authLoginSuccessfulTitle');

  String get authWelcomeBack => _t('authWelcomeBack');

  String get authLoginFailedTitle => _t('authLoginFailedTitle');

  String get authCheckCredentials => _t('authCheckCredentials');

  String get authShowPassword => _t('authShowPassword');

  String get authHidePassword => _t('authHidePassword');

  String get authFillAllFields => _t('authFillAllFields');

  String get authPasswordMismatchTitle => _t('authPasswordMismatchTitle');

  String get authPasswordsDoNotMatch => _t('authPasswordsDoNotMatch');

  String get authRegistrationSuccessfulTitle =>
      _t('authRegistrationSuccessfulTitle');

  String get authAccountCreated => _t('authAccountCreated');

  String get authRegistrationFailedTitle => _t('authRegistrationFailedTitle');

  String get authRegistrationFailed => _t('authRegistrationFailed');

  String get authGoogleLoginSuccessfulTitle =>
      _t('authGoogleLoginSuccessfulTitle');

  String get authGoogleLoginSuccessful => _t('authGoogleLoginSuccessful');

  String get authGoogleLoginFailedTitle => _t('authGoogleLoginFailedTitle');

  String get authGoogleLoginFailed => _t('authGoogleLoginFailed');

  String get authGoogleConfigurationError => _t('authGoogleConfigurationError');

  String get authFirebaseUnavailable => _t('authFirebaseUnavailable');

  String get authGoogleSessionInvalid => _t('authGoogleSessionInvalid');

  String get authGoogleAccountConflict => _t('authGoogleAccountConflict');

  String get authNetworkError => _t('authNetworkError');

  String get authEmailVerificationRequiredTitle =>
      _t('authEmailVerificationRequiredTitle');

  String get authEmailVerificationRequired =>
      _t('authEmailVerificationRequired');

  String get authEmailExample => _t('authEmailExample');

  String get authFirstNameExample => _t('authFirstNameExample');

  String get authLastNameExample => _t('authLastNameExample');

  String get authVerificationSuccessfulTitle =>
      _t('authVerificationSuccessfulTitle');

  String get authVerificationFailedTitle => _t('authVerificationFailedTitle');

  String get authCodeResentTitle => _t('authCodeResentTitle');

  String get authCheckEmailForNewCode => _t('authCheckEmailForNewCode');

  String get authResendFailedTitle => _t('authResendFailedTitle');
}

extension CheckoutPaymentLocalizations on AppLocalizations {
  String get checkoutTitle => _t('checkoutTitle');
  String get checkoutCourseSummary => _t('checkoutCourseSummary');

  String checkoutStudentsCount(int count) {
    final String key = count == 1
        ? 'checkoutStudentsCountOne'
        : 'checkoutStudentsCountMany';
    return _t(key).replaceAll('{count}', '$count');
  }

  String get checkoutPriceBreakdown => _t('checkoutPriceBreakdown');
  String get checkoutCoursePrice => _t('checkoutCoursePrice');

  String checkoutDiscountPercent(String percent) =>
      _t('checkoutDiscountPercent').replaceAll('{percent}', percent);

  String get checkoutTotal => _t('checkoutTotal');
  String get checkoutPromoCode => _t('checkoutPromoCode');
  String get checkoutPromoCodeHint => _t('checkoutPromoCodeHint');
  String get checkoutRemove => _t('checkoutRemove');
  String get checkoutApply => _t('checkoutApply');

  String checkoutCouponCodeApplied(String code) =>
      _t('checkoutCouponCodeApplied').replaceAll('{code}', code);

  String get checkoutPaymentMethod => _t('checkoutPaymentMethod');

  String checkoutPayWith(String method) =>
      _t('checkoutPayWith').replaceAll('{method}', method);

  String get checkoutConfirmPayment => _t('checkoutConfirmPayment');
  String get checkoutPaymentVerificationFailed =>
      _t('checkoutPaymentVerificationFailed');

  String checkoutFailedToVerifyPayment(String detail) =>
      _t('checkoutFailedToVerifyPayment').replaceAll('{detail}', detail);

  String checkoutPaymentFailed(String? reason) {
    final String detail = reason?.trim() ?? '';
    if (detail.isEmpty) {
      return _t('checkoutPaymentFailed');
    }

    return _t('checkoutPaymentFailedWithReason').replaceAll('{reason}', detail);
  }

  String checkoutPaymentInitializationError(String detail) =>
      _t('checkoutPaymentInitializationError').replaceAll('{detail}', detail);

  String checkoutPaymentStatus(String? status) {
    final String normalized = status?.trim().toLowerCase() ?? '';
    String label;

    switch (normalized) {
      case 'success':
      case 'valid':
        label = _t('checkoutStatusSuccess');
        break;
      case 'pending':
        label = _t('checkoutStatusPending');
        break;
      case 'cancelled':
      case 'canceled':
        label = _t('checkoutStatusCancelled');
        break;
      default:
        label = _t('checkoutStatusFailed');
        break;
    }

    return _t('checkoutPaymentStatus').replaceAll('{status}', label);
  }

  String checkoutError(String detail) =>
      _t('checkoutError').replaceAll('{detail}', detail);

  String checkoutStripeError(String? message) {
    final String detail = message?.trim() ?? '';
    if (detail.isEmpty) {
      return _t('checkoutPaymentFailed');
    }

    return _t('checkoutStripeError').replaceAll('{detail}', detail);
  }

  String checkoutProviderPayment(String provider) =>
      _t('checkoutProviderPayment').replaceAll('{provider}', provider);

  String get checkoutInvalidPaypalData => _t('checkoutInvalidPaypalData');
  String get checkoutPaymentCancelled => _t('checkoutPaymentCancelled');
  String get checkoutCouponApplied => _t('checkoutCouponApplied');
  String get checkoutInvalidCoupon => _t('checkoutInvalidCoupon');

  String checkoutCouponValidationFailed(String detail) =>
      _t('checkoutCouponValidationFailed').replaceAll('{detail}', detail);

  String get checkoutSelectPaymentMethod => _t('checkoutSelectPaymentMethod');
  String get checkoutLoginRequired => _t('checkoutLoginRequired');
  String get checkoutEnrollmentFailed => _t('checkoutEnrollmentFailed');

  String get checkoutDuplicateCoursesTitle =>
      _t('checkoutDuplicateCoursesTitle');
  String get checkoutCancel => _t('checkoutCancel');
  String get checkoutProceedAnyway => _t('checkoutProceedAnyway');
  String get checkoutEnrolled => _t('checkoutEnrolled');
  String get checkoutFailed => _t('checkoutFailed');
  String get checkoutEnrollmentRequested => _t('checkoutEnrollmentRequested');
  String get checkoutBundleTitle => _t('checkoutBundleTitle');

  String checkoutForBundle(String title) =>
      _t('checkoutForBundle').replaceAll('{title}', title);

  String checkoutTotalAmount(String amount) =>
      _t('checkoutTotalAmount').replaceAll('{amount}', amount);

  String get checkoutPayOffline => _t('checkoutPayOffline');

  String get enrollmentSuccessTitle => _t('enrollmentSuccessTitle');
  String get enrollmentSuccessfulTitle => _t('enrollmentSuccessfulTitle');
  String get enrollmentBundleFallback => _t('enrollmentBundleFallback');

  String enrollmentBundleSuccess(String bundle) =>
      _t('enrollmentBundleSuccess').replaceAll('{bundle}', bundle);

  String get enrollmentCourseSuccess => _t('enrollmentCourseSuccess');
  String get enrollmentBundleCoursesTitle => _t('enrollmentBundleCoursesTitle');
  String get enrollmentCourseDetails => _t('enrollmentCourseDetails');
  String get enrollmentCourseFallback => _t('enrollmentCourseFallback');

  String enrollmentRatingReviews(String rating, int count) {
    final String key = count == 1
        ? 'enrollmentRatingReviewsOne'
        : 'enrollmentRatingReviewsMany';

    return _t(
      key,
    ).replaceAll('{rating}', rating).replaceAll('{count}', '$count');
  }

  String get enrollmentWhatsIncluded => _t('enrollmentWhatsIncluded');

  String enrollmentVideoLessons(int count) {
    final String key = count == 1
        ? 'enrollmentVideoLessonsOne'
        : 'enrollmentVideoLessonsMany';
    return _t(key).replaceAll('{count}', '$count');
  }

  String get enrollmentLifetimeAccess => _t('enrollmentLifetimeAccess');
  String get enrollmentAssignmentsQuizzes => _t('enrollmentAssignmentsQuizzes');
  String get enrollmentCertificate => _t('enrollmentCertificate');
  String get enrollmentStartLearning => _t('enrollmentStartLearning');
  String get enrollmentEnrolledBadge => _t('enrollmentEnrolledBadge');

  String get offlineUploadReceiptRequired => _t('offlineUploadReceiptRequired');
  String get offlineEnrollmentRequestFailed =>
      _t('offlineEnrollmentRequestFailed');
  String get offlineTransactionDetails => _t('offlineTransactionDetails');
  String get offlinePaymentTitle => _t('offlinePaymentTitle');
  String get offlinePaymentDetails => _t('offlinePaymentDetails');
  String get offlineTransactionReference => _t('offlineTransactionReference');
  String get offlineTransactionReferenceHint =>
      _t('offlineTransactionReferenceHint');
  String get offlineTransactionReferenceRequired =>
      _t('offlineTransactionReferenceRequired');
  String get offlinePaymentReceipt => _t('offlinePaymentReceipt');
  String get offlineUploadReceiptImage => _t('offlineUploadReceiptImage');
  String get offlineSubmitEnrollmentRequest =>
      _t('offlineSubmitEnrollmentRequest');

  String get eventPaymentBookingFailed => _t('eventPaymentBookingFailed');
  String get eventPaymentOrderSummary => _t('eventPaymentOrderSummary');
  String get eventPaymentEvent => _t('eventPaymentEvent');
  String get eventPaymentTicketType => _t('eventPaymentTicketType');
  String get eventPaymentQuantity => _t('eventPaymentQuantity');
  String get eventPaymentSubtotal => _t('eventPaymentSubtotal');
  String get eventPaymentServiceFee => _t('eventPaymentServiceFee');
  String get eventPaymentMethodsTitle => _t('eventPaymentMethodsTitle');
  String get eventPaymentCardDetails => _t('eventPaymentCardDetails');
  String get eventPaymentCardHolderName => _t('eventPaymentCardHolderName');
  String get eventPaymentCardHolderExample =>
      _t('eventPaymentCardHolderExample');
  String get eventPaymentCardNumber => _t('eventPaymentCardNumber');
  String get eventPaymentExpiry => _t('eventPaymentExpiry');
  String get eventPaymentExpiryHint => _t('eventPaymentExpiryHint');
  String get eventPaymentCvv => _t('eventPaymentCvv');
  String get eventPaymentCompleteRegistration =>
      _t('eventPaymentCompleteRegistration');
  String get eventPaymentPayNow => _t('eventPaymentPayNow');

  String eventPaymentMethodName(String identifier) {
    switch (identifier) {
      case 'card':
        return _t('eventPaymentMethodCard');
      case 'paypal':
        return 'PayPal';
      case 'apple':
        return 'Apple Pay';
      case 'google':
        return 'Google Pay';
      default:
        return identifier;
    }
  }
}

extension CommunityCourseLocalizations on AppLocalizations {
  String communityErrorLoadingQuestions(Object error) =>
      _t('communityErrorLoadingQuestions').replaceAll('{error}', '$error');

  String get communityQuestionTitleHint => _t('communityQuestionTitleHint');

  String get communityTagsHint => _t('communityTagsHint');

  String get communityQuestionDescriptionHint =>
      _t('communityQuestionDescriptionHint');

  String communityErrorLoadingQuestion(Object error) =>
      _t('communityErrorLoadingQuestion').replaceAll('{error}', '$error');

  String communityFailedPostAnswer(Object error) =>
      _t('communityFailedPostAnswer').replaceAll('{error}', '$error');

  String get communityAnswerAcceptedMessage =>
      _t('communityAnswerAcceptedMessage');

  String communityGenericError(Object error) =>
      _t('communityGenericError').replaceAll('{error}', '$error');

  String get assignmentAttachFileOrComment =>
      _t('assignmentAttachFileOrComment');

  String get courseSubmissionFailed => _t('courseSubmissionFailed');

  String get quizNoQuestionsFound => _t('quizNoQuestionsFound');

  String communityFailedToVote(Object error) =>
      _t('communityFailedToVote').replaceAll('{error}', '$error');

  String communityFailedSubmitReply(Object error) =>
      _t('communityFailedSubmitReply').replaceAll('{error}', '$error');

  String get communityDeleteReplyTitle => _t('communityDeleteReplyTitle');

  String get communityDeleteReplyConfirmation =>
      _t('communityDeleteReplyConfirmation');

  String get communityCancel => _t('communityCancel');

  String get communityDelete => _t('communityDelete');

  String get communityReplyDeletedSuccessfully =>
      _t('communityReplyDeletedSuccessfully');

  String communityFailedDeleteReply(Object error) =>
      _t('communityFailedDeleteReply').replaceAll('{error}', '$error');

  String get communityDiscussionDetailsTitle =>
      _t('communityDiscussionDetailsTitle');

  String get communityThreadNotFound => _t('communityThreadNotFound');

  String get communityPinned => _t('communityPinned');

  String get communityAnnouncement => _t('communityAnnouncement');

  String get communityDeleteThreadTitle => _t('communityDeleteThreadTitle');

  String get communityDeleteThreadConfirmation =>
      _t('communityDeleteThreadConfirmation');

  String communityFailedDeleteThread(Object error) =>
      _t('communityFailedDeleteThread').replaceAll('{error}', '$error');

  String get communityInstructor => _t('communityInstructor');

  String get communityTypeReplyHint => _t('communityTypeReplyHint');

  String get communityAskQuestionOrPostTopic =>
      _t('communityAskQuestionOrPostTopic');

  String get communityTitleLabel => _t('communityTitleLabel');

  String get communityQuestionAboutHint => _t('communityQuestionAboutHint');

  String get communityTitleRequired => _t('communityTitleRequired');

  String get communityContentDetailsLabel => _t('communityContentDetailsLabel');

  String get communityContentDetailsHint => _t('communityContentDetailsHint');

  String get communityContentDetailsRequired =>
      _t('communityContentDetailsRequired');

  String communityFailedPostThread(Object error) =>
      _t('communityFailedPostThread').replaceAll('{error}', '$error');

  String get communityPostThread => _t('communityPostThread');

  String get communitySearchDiscussionsHint =>
      _t('communitySearchDiscussionsHint');
}

extension ProfileSettingsLocalizations on AppLocalizations {
  String get profileDeleteAccountTitle => _t('profileDeleteAccountTitle');

  String get profileDeleteAccountConfirmation =>
      _t('profileDeleteAccountConfirmation');

  String get profileCancel => _t('profileCancel');

  String get profileDelete => _t('profileDelete');

  String get profileDeletionRequestSubmitted =>
      _t('profileDeletionRequestSubmitted');

  String profileErrorWithDetails(Object error) =>
      _t('profileErrorWithDetails').replaceAll('{error}', '$error');

  String get profileAccountSection => _t('profileAccountSection');

  String get profileEditTitle => _t('profileEditTitle');

  String get profileEditSubtitle => _t('profileEditSubtitle');

  String get profileChangePasswordTitle => _t('profileChangePasswordTitle');

  String get profileChangePasswordSubtitle =>
      _t('profileChangePasswordSubtitle');

  String get profileDeletionPendingTitle => _t('profileDeletionPendingTitle');

  String get profileAwaitingAdminApproval => _t('profileAwaitingAdminApproval');

  String get profileDeleteAccountSubtitle => _t('profileDeleteAccountSubtitle');

  String get profileDeletionPendingMessage =>
      _t('profileDeletionPendingMessage');

  String get profilePrivacySecuritySection =>
      _t('profilePrivacySecuritySection');

  String get profileNoPagesAvailable => _t('profileNoPagesAvailable');

  String profileViewPage(String title) =>
      _t('profileViewPage').replaceAll('{title}', title);

  String get profileRateAppTitle => _t('profileRateAppTitle');

  String get profileRateAppSubtitle => _t('profileRateAppSubtitle');

  String get profileShareAppTitle => _t('profileShareAppTitle');

  String get profileShareAppSubtitle => _t('profileShareAppSubtitle');

  String profileFailedToLoadSettings(Object error) =>
      _t('profileFailedToLoadSettings').replaceAll('{error}', '$error');

  String profileFailedToUpdateSettings(Object error) =>
      _t('profileFailedToUpdateSettings').replaceAll('{error}', '$error');

  String get profileNotificationSettingsSection =>
      _t('profileNotificationSettingsSection');

  String get profileEmailNotificationsTitle =>
      _t('profileEmailNotificationsTitle');

  String get profileEmailNotificationsSubtitle =>
      _t('profileEmailNotificationsSubtitle');

  String get profileCourseRemindersTitle => _t('profileCourseRemindersTitle');

  String get profileCourseRemindersSubtitle =>
      _t('profileCourseRemindersSubtitle');

  String get profileProgressReportsTitle => _t('profileProgressReportsTitle');

  String get profileProgressReportsSubtitle =>
      _t('profileProgressReportsSubtitle');

  String get profileMarketingEmailsTitle => _t('profileMarketingEmailsTitle');

  String get profileMarketingEmailsSubtitle =>
      _t('profileMarketingEmailsSubtitle');

  String get profileDownloadingReceipt => _t('profileDownloadingReceipt');

  String get profileReceiptDownloaded => _t('profileReceiptDownloaded');

  String get profileReceiptDownloadFailed => _t('profileReceiptDownloadFailed');

  String get profileOpen => _t('profileOpen');

  String get profileDownloadReceipt => _t('profileDownloadReceipt');

  String get profilePaymentDetailsTitle => _t('profilePaymentDetailsTitle');

  String get profileTransactionDetailsTitle =>
      _t('profileTransactionDetailsTitle');

  String get profileCourseLabel => _t('profileCourseLabel');

  String get profileDateLabel => _t('profileDateLabel');

  String get profilePaymentMethodLabel => _t('profilePaymentMethodLabel');

  String get profileTransactionIdLabel => _t('profileTransactionIdLabel');

  String get profileDiscountLabel => _t('profileDiscountLabel');

  String get profilePromoCodeLabel => _t('profilePromoCodeLabel');

  String get profileAllPayments => _t('profileAllPayments');

  String profileNoPaymentsFor(String paymentMethod) =>
      _t('profileNoPaymentsFor').replaceAll('{paymentMethod}', paymentMethod);

  String profilePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _t('profileStatusCompleted');
      case 'pending':
        return _t('profileStatusPending');
      case 'failed':
        return _t('profileStatusFailed');
      case 'refunded':
        return _t('profileStatusRefunded');
      case 'cancelled':
      case 'canceled':
        return _t('profileStatusCancelled');
      default:
        return status.trim().isEmpty ? _t('profileStatusUnknown') : status;
    }
  }

  String get profilePhotoUpdated => _t('profilePhotoUpdated');

  String profilePhotoUploadFailed(Object error) =>
      _t('profilePhotoUploadFailed').replaceAll('{error}', '$error');

  String get profileUpdated => _t('profileUpdated');

  String get profileFirstNameHint => _t('profileFirstNameHint');

  String get profileFirstNameRequired => _t('profileFirstNameRequired');

  String get profileLastNameHint => _t('profileLastNameHint');

  String get profileLastNameRequired => _t('profileLastNameRequired');

  String get profileEmailHint => _t('profileEmailHint');

  String get profileEmailRequired => _t('profileEmailRequired');

  String get profileEmailInvalid => _t('profileEmailInvalid');

  String get profilePhoneNumberLabel => _t('profilePhoneNumberLabel');

  String get profilePhoneNumberHint => _t('profilePhoneNumberHint');

  String get profileBioLabel => _t('profileBioLabel');

  String get profileBioHint => _t('profileBioHint');

  String get profileSaveChanges => _t('profileSaveChanges');

  String get profilePasswordUpdated => _t('profilePasswordUpdated');

  String get profileChangePasswordDescription =>
      _t('profileChangePasswordDescription');

  String get profileCurrentPasswordLabel => _t('profileCurrentPasswordLabel');

  String get profileCurrentPasswordHint => _t('profileCurrentPasswordHint');

  String get profileCurrentPasswordRequired =>
      _t('profileCurrentPasswordRequired');

  String get profileNewPasswordHint => _t('profileNewPasswordHint');

  String get profileNewPasswordRequired => _t('profileNewPasswordRequired');

  String get profilePasswordMinLength => _t('profilePasswordMinLength');

  String get profileConfirmPasswordHint => _t('profileConfirmPasswordHint');

  String get profileConfirmPasswordRequired =>
      _t('profileConfirmPasswordRequired');

  String get profilePasswordsDoNotMatch => _t('profilePasswordsDoNotMatch');

  String get profileRatingThanks => _t('profileRatingThanks');

  String get profileRateOurAppTitle => _t('profileRateOurAppTitle');

  String get profileRateExperienceQuestion =>
      _t('profileRateExperienceQuestion');

  String get profileFeedbackHint => _t('profileFeedbackHint');

  String get profileRateOnStore => _t('profileRateOnStore');

  String get profileSubmitRating => _t('profileSubmitRating');

  String get profileMaybeLater => _t('profileMaybeLater');
}

extension FinalResidualLocalizations on AppLocalizations {
  String get residualAbout => _t('residualAbout');

  String get residualAiSuggestions => _t('residualAiSuggestions');

  String get residualAnonymous => _t('residualAnonymous');

  String get residualApplyFilter => _t('residualApplyFilter');

  String get residualAverageRating => _t('residualAverageRating');

  String get residualBookings => _t('residualBookings');

  String residualCertificateDownloadedTo(String path) {
    return _t('residualCertificateDownloadedTo').replaceAll('{path}', '$path');
  }

  String get residualClear => _t('residualClear');

  String get residualConnectionError => _t('residualConnectionError');

  String get residualCouldNotLaunchDownloadUrl =>
      _t('residualCouldNotLaunchDownloadUrl');

  String get residualCouldNotOpenMaps => _t('residualCouldNotOpenMaps');

  String get residualCourseBundles => _t('residualCourseBundles');

  String residualCourseCount(int count) {
    return _t('residualCourseCount').replaceAll('{count}', '$count');
  }

  String get residualCourses => _t('residualCourses');

  String get residualDays => _t('residualDays');

  String residualDownloadFailed(String error) {
    return _t('residualDownloadFailed').replaceAll('{error}', '$error');
  }

  String get residualDownloading => _t('residualDownloading');

  String get residualEndDate => _t('residualEndDate');

  String get residualEndTime => _t('residualEndTime');

  String residualErrorWithMessage(String message) {
    return _t('residualErrorWithMessage').replaceAll('{message}', '$message');
  }

  String get residualEvent => _t('residualEvent');

  String get residualEventInformation => _t('residualEventInformation');

  String get residualEventSpeakers => _t('residualEventSpeakers');

  String get residualFailedToDownloadCertificate =>
      _t('residualFailedToDownloadCertificate');

  String get residualFailedToLoadBundles => _t('residualFailedToLoadBundles');

  String get residualFailedToLoadData => _t('residualFailedToLoadData');

  String get residualFailedToLoadInstructor =>
      _t('residualFailedToLoadInstructor');

  String get residualFailedToLoadInstructors =>
      _t('residualFailedToLoadInstructors');

  String get residualFailedToOpenMeetingLink =>
      _t('residualFailedToOpenMeetingLink');

  String get residualFree => _t('residualFree');

  String residualGoingCount(int count) {
    return _t('residualGoingCount').replaceAll('{count}', '$count');
  }

  String get residualGuest => _t('residualGuest');

  String get residualHours => _t('residualHours');

  String residualHoursRange(String range) {
    return _t('residualHoursRange').replaceAll('{range}', '$range');
  }

  String get residualInstructor => _t('residualInstructor');

  String get residualInstructors => _t('residualInstructors');

  String get residualJoinLiveClass => _t('residualJoinLiveClass');

  String get residualLiveNow => _t('residualLiveNow');

  String get residualMeetingDetailsJoin => _t('residualMeetingDetailsJoin');

  String get residualMinutes => _t('residualMinutes');

  String residualMinutesShort(int count) {
    return _t('residualMinutesShort').replaceAll('{count}', '$count');
  }

  String get residualMostRecent => _t('residualMostRecent');

  String get residualNoBioAvailable => _t('residualNoBioAvailable');

  String get residualNoBundlesAvailable => _t('residualNoBundlesAvailable');

  String residualNoBundlesFor(String query) {
    return _t('residualNoBundlesFor').replaceAll('{query}', '$query');
  }

  String get residualNoCategoriesAvailable =>
      _t('residualNoCategoriesAvailable');

  String get residualNoDataFound => _t('residualNoDataFound');

  String get residualNoInstructorsFound => _t('residualNoInstructorsFound');

  String get residualOnline => _t('residualOnline');

  String get residualOops => _t('residualOops');

  String get residualOpen => _t('residualOpen');

  String get residualOrganizer => _t('residualOrganizer');

  String get residualRating => _t('residualRating');

  String get residualReadLess => _t('residualReadLess');

  String get residualReadMore => _t('residualReadMore');

  String get residualRemainingSeats => _t('residualRemainingSeats');

  String get residualRetry => _t('residualRetry');

  String get residualReviews => _t('residualReviews');

  String residualReviewsCount(int count) {
    return _t('residualReviewsCount').replaceAll('{count}', '$count');
  }

  String residualScheduledFor(String date) {
    return _t('residualScheduledFor').replaceAll('{date}', '$date');
  }

  String get residualSearchBundles => _t('residualSearchBundles');

  String get residualSeconds => _t('residualSeconds');

  String get residualSeeAllInfo => _t('residualSeeAllInfo');

  String get residualSeeLocationOnMaps => _t('residualSeeLocationOnMaps');

  String get residualSendMessage => _t('residualSendMessage');

  String residualServerError(int code) {
    return _t('residualServerError').replaceAll('{code}', '$code');
  }

  String residualShareEvent(String title, String url) {
    return _t(
      'residualShareEvent',
    ).replaceAll('{title}', '$title').replaceAll('{url}', '$url');
  }

  String get residualShowLess => _t('residualShowLess');

  String get residualSomethingWentWrong => _t('residualSomethingWentWrong');

  String get residualSpeaker => _t('residualSpeaker');

  String get residualStartDate => _t('residualStartDate');

  String get residualStartTime => _t('residualStartTime');

  String get residualStoragePermissionRequired =>
      _t('residualStoragePermissionRequired');

  String get residualStudent => _t('residualStudent');

  String get residualStudents => _t('residualStudents');

  String get residualTapToJoinLive => _t('residualTapToJoinLive');

  String get residualTaskChemistryLabReport =>
      _t('residualTaskChemistryLabReport');

  String get residualTaskCompleteChapterExercises =>
      _t('residualTaskCompleteChapterExercises');

  String get residualTaskCompleted => _t('residualTaskCompleted');

  String get residualTaskDraftEssay => _t('residualTaskDraftEssay');

  String get residualTaskEnglishEssay => _t('residualTaskEnglishEssay');

  String get residualTaskHistoryReading => _t('residualTaskHistoryReading');

  String get residualTaskInProgress => _t('residualTaskInProgress');

  String get residualTaskMathematicsAssignment =>
      _t('residualTaskMathematicsAssignment');

  String get residualTaskPending => _t('residualTaskPending');

  String get residualTaskPhysicsProblemSet =>
      _t('residualTaskPhysicsProblemSet');

  String get residualTaskReadChapterNotes => _t('residualTaskReadChapterNotes');

  String get residualTaskSolveProblems => _t('residualTaskSolveProblems');

  String get residualTaskWriteExperimentResults =>
      _t('residualTaskWriteExperimentResults');

  String get residualTbd => _t('residualTbd');

  String get residualTicketPrice => _t('residualTicketPrice');

  String residualTotalCount(int count) {
    return _t('residualTotalCount').replaceAll('{count}', '$count');
  }

  String get residualTotalSeats => _t('residualTotalSeats');

  String get residualTryAgain => _t('residualTryAgain');

  String get residualUnlimited => _t('residualUnlimited');

  String get residualUpcomingLive => _t('residualUpcomingLive');

  String get residualUser => _t('residualUser');

  String get residualView => _t('residualView');

  String get residualWhatYouWillExperience =>
      _t('residualWhatYouWillExperience');
}

extension DynamicLegalPageLocalizations on AppLocalizations {
  String get profilePrivacyPolicyTitle => _t('profilePrivacyPolicyTitle');

  String get profileTermsConditionsTitle => _t('profileTermsConditionsTitle');

  String get profileGdprComplianceTitle => _t('profileGdprComplianceTitle');

  String get profileFailedLoadLegalContent =>
      _t('profileFailedLoadLegalContent');
}

extension FinalMultilingualClosureLocalizations on AppLocalizations {
  String get aiChatHistoryLoadFailed => _t('aiChatHistoryLoadFailed');
  String get aiChatServerError => _t('aiChatServerError');
  String get aiChatConnectionError => _t('aiChatConnectionError');
  String get aiChatSendFailed => _t('aiChatSendFailed');
  String get unknownErrorOccurred => _t('unknownErrorOccurred');
  String get noUpcomingEvents => _t('noUpcomingEvents');
  String get checkBackLaterForNewEvents => _t('checkBackLaterForNewEvents');
  String get noPastEvents => _t('noPastEvents');
  String get noAttendedEventsYet => _t('noAttendedEventsYet');
  String get noEventsAvailable => _t('noEventsAvailable');
  String get noEventsAvailableNow => _t('noEventsAvailableNow');
}

extension DynamicApiContentLocalizations on AppLocalizations {
  String get communityAskQuestion => _t('communityAskQuestion');

  String get communityQuestionPostedSuccessfully =>
      _t('communityQuestionPostedSuccessfully');

  String get communityFailedPostQuestion => _t('communityFailedPostQuestion');

  String get communityJustNow => _t('communityJustNow');

  String communityDaysAgo(int count) =>
      _t('communityDaysAgo').replaceAll('{count}', '$count');

  String communityHoursAgo(int count) =>
      _t('communityHoursAgo').replaceAll('{count}', '$count');

  String communityMinutesAgo(int count) =>
      _t('communityMinutesAgo').replaceAll('{count}', '$count');

  String communityViewsCount(int count) =>
      _t('communityViewsCount').replaceAll('{count}', '$count');
}

extension EventFilterLocalizations on AppLocalizations {
  String get eventFilterTitle => _t('eventFilterTitle');

  String get eventFilterPast => _t('eventFilterPast');

  String get eventFilterPaid => _t('eventFilterPaid');

  String eventFilterUnderPrice(String price) =>
      _t('eventFilterUnderPrice').replaceAll('{price}', price);

  String eventFilterPriceRange(String min, String max) => _t(
    'eventFilterPriceRange',
  ).replaceAll('{min}', min).replaceAll('{max}', max);

  String eventFilterOverPrice(String price) =>
      _t('eventFilterOverPrice').replaceAll('{price}', price);

  String get eventApplyFilters => _t('eventApplyFilters');

  String get eventFailedLoad => _t('eventFailedLoad');

  String get eventFetchError => _t('eventFetchError');

  String eventAttendeesCount(int count) =>
      _t('eventAttendeesCount').replaceAll('{count}', '$count');

  String get eventSearchHint => _t('eventSearchHint');
}
