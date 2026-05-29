// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BookMyPT';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get continueText => 'Continue';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get send => 'Send';

  @override
  String get seeAll => 'See All';

  @override
  String get all => 'All';

  @override
  String get active => 'Active';

  @override
  String get passive => 'Passive';

  @override
  String get requests => 'Requests';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get sessions => 'sessions';

  @override
  String get minuteShort => 'min';

  @override
  String helloName(String name) {
    return 'Hello, $name!';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get orDivider => 'or';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get errorGoogleSignIn => 'Google sign-in failed';

  @override
  String get errorUserNotFound => 'This email is not registered';

  @override
  String get errorWrongPassword => 'Incorrect password';

  @override
  String get errorInvalidCredential => 'Email or password is incorrect';

  @override
  String get errorTooManyRequests => 'Too many attempts. Please wait';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorNetworkFailed => 'Network connection error';

  @override
  String get errorUserDisabled => 'This account has been disabled';

  @override
  String get errorSignInFailed => 'Sign in failed. Please try again';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get enterInfoToContinue => 'Enter your details to continue';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'John Smith';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorRegisterFailed => 'Registration failed. Please try again';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get resetPassword => 'Password Reset';

  @override
  String get resetPasswordSubtitle => 'We will send a reset link to your email';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get emailSent => 'Email Sent';

  @override
  String emailSentMessage(String email) {
    return 'A password reset link was sent to $email';
  }

  @override
  String get backToLogin => 'Back to Sign In';

  @override
  String get selectRole => 'Select Your Role';

  @override
  String get howToUseApp => 'How will you use the app?';

  @override
  String get rolePtTitle => 'Personal Trainer';

  @override
  String get rolePtSubtitle =>
      'Manage your members, create programs, and keep a calendar';

  @override
  String get roleMemberTitle => 'Member';

  @override
  String get roleMemberSubtitle =>
      'View your PT\'s program, book appointments, and track your progress';

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navPrograms => 'Programs';

  @override
  String get navProgress => 'Progress';

  @override
  String get navPackages => 'Packages';

  @override
  String get navChat => 'Messages';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMembers => 'Members';

  @override
  String get navEarnings => 'Earnings';

  @override
  String get upcomingSessions => 'Upcoming Sessions';

  @override
  String get noUpcomingSessions => 'No upcoming sessions';

  @override
  String get recentMembers => 'Recent Members';

  @override
  String get noMembersYet => 'No members yet';

  @override
  String get addSession => 'Add Session';

  @override
  String get totalMembers => 'Total Members';

  @override
  String get thisWeek => 'This Week';

  @override
  String get goalNotSet => 'No goal set';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get latestProgress => 'Latest Progress';

  @override
  String get noProgressRecord => 'No progress record';

  @override
  String get recordProgress => 'Record';

  @override
  String get myTrainer => 'Your Trainer';

  @override
  String get trainerNotLoaded => 'Trainer could not be loaded';

  @override
  String get trainerInfoNotFound => 'Trainer info not found';

  @override
  String get leaveTrainer => 'Leave Trainer';

  @override
  String get leaveTrainerTitle => 'Leave Trainer';

  @override
  String leaveTrainerConfirm(String ptName) {
    return 'Do you want to end your membership with $ptName?';
  }

  @override
  String remainingSessionsWarning(int count) {
    return 'You have $count remaining sessions.';
  }

  @override
  String get yesLeave => 'Yes, Leave';

  @override
  String get noPtAssigned => 'No PT Assigned';

  @override
  String get findPtBannerSub => 'Find a PT to start your workouts';

  @override
  String get findPt => 'Find PT';

  @override
  String get myPrograms => 'My Programs';

  @override
  String get lastWeight => 'Last weight';

  @override
  String get myMembers => 'My Members';

  @override
  String get searchMember => 'Search member...';

  @override
  String get noMembersYetFull => 'You have no members yet';

  @override
  String get addMemberHint => 'Tap + to add a member';

  @override
  String get addMember => 'Add Member';

  @override
  String get searchNoResult => 'No search results found';

  @override
  String get memberNotFound => 'Member not found';

  @override
  String get sendMessage => 'Send Message';

  @override
  String chatOpenError(String error) {
    return 'Could not open chat: $error';
  }

  @override
  String get addMemberTitle => 'Add Member';

  @override
  String get memberEmail => 'Member Email';

  @override
  String get goal => 'Goal';

  @override
  String get goalHint => 'Lose weight, build muscle...';

  @override
  String get notes => 'Notes';

  @override
  String invitationSent(String name) {
    return 'Invitation sent to $name';
  }

  @override
  String get memberNotFoundByEmail =>
      'No registered member found with this email. The member must register first.';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get sessionDetailTitle => 'Session Details';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get deleteSessionConfirm => 'Do you want to delete this session?';

  @override
  String get deleteError => 'Delete Error';

  @override
  String get close => 'Close';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabHistory => 'History';

  @override
  String get requestAppointment => 'Request Appointment';

  @override
  String get noDayAppointment => 'No appointments today';

  @override
  String appointmentsCount(int count) {
    return '$count appointments';
  }

  @override
  String sessionDurationMin(int count) {
    return '$count min session';
  }

  @override
  String get ptBusy => 'PT busy';

  @override
  String get ptBusyPersonal => 'PT occupied';

  @override
  String get personalActivity => 'Personal activity';

  @override
  String get passiveMemberTitle => 'Inactive Member';

  @override
  String get passiveMemberContent =>
      'You need to be active to book an appointment. Would you like to send an activation request to your trainer?';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get activationRequestSent => 'Activation request sent';

  @override
  String get dateAndTime => 'Date and Time';

  @override
  String get timeConflict => 'You already have an appointment at this time';

  @override
  String get ptNotAvailable => 'PT is not available at this time';

  @override
  String sessionDurationLabel(int count) {
    return 'Session duration: $count min';
  }

  @override
  String get durationLabel => 'Duration (min):';

  @override
  String get findPtEnterEmail => 'Enter your PT\'s email to find them';

  @override
  String get ptEmail => 'PT Email';

  @override
  String get linkPt => 'Link PT';

  @override
  String get ptNotFoundByEmail => 'No PT found with this email';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get onlyPendingCanEdit => 'Only pending requests can be edited';

  @override
  String get completedCount => 'Completed';

  @override
  String get totalDuration => 'Total duration';

  @override
  String get upcomingMySessions => 'My Upcoming Sessions';

  @override
  String get completedSessions => 'Completed Sessions';

  @override
  String get noCompletedSessions => 'No completed sessions yet';

  @override
  String get noCompletedSessionsSub =>
      'Your approved sessions will appear here once completed';

  @override
  String get bookingConfirmTitle => 'Confirm Appointment';

  @override
  String get appointmentDetails => 'Appointment Details';

  @override
  String get waitingPtApproval =>
      'Your appointment will be waiting for approval by your PT.';

  @override
  String get goToMyAppointments => 'Go to My Appointments';

  @override
  String get addPersonalEvent => 'Add Personal Event';

  @override
  String get eventTitle => 'Title';

  @override
  String get eventTitleHint => 'Yoga, workout...';

  @override
  String get memberCalendarTitle => 'My Calendar';

  @override
  String get progressTitle => 'Progress Tracking';

  @override
  String get noProgressYet => 'No progress records yet';

  @override
  String get addMeasurements => 'Save your weight and measurements';

  @override
  String get addRecord => 'Add Record';

  @override
  String get weightChart => 'Weight Chart';

  @override
  String get addProgressTitle => 'Add Progress';

  @override
  String get progressSaved => 'Progress saved';

  @override
  String get saving => 'Saving...';

  @override
  String get addProgressPhoto => 'Add Progress Photo';

  @override
  String get enterAtLeastOneMeasurement => 'Enter at least one measurement';

  @override
  String get weight => 'Weight (kg)';

  @override
  String get chest => 'Chest (cm)';

  @override
  String get waist => 'Waist (cm)';

  @override
  String get hips => 'Hips (cm)';

  @override
  String get bicep => 'Bicep (cm)';

  @override
  String get thigh => 'Thigh (cm)';

  @override
  String get bodyFat => 'Body Fat (%)';

  @override
  String get date => 'Date';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startMessaging => 'Start messaging with your PT or members';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get packageManagement => 'Package Management';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get completedPayments => 'Completed Payments';

  @override
  String get noEarningsYet => 'No earnings yet';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentHistoryTitle => 'Payment History';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get programListTitle => 'Programs';

  @override
  String get noProgramsYet => 'No programs created yet';

  @override
  String get createProgram => 'Create Program';

  @override
  String get programDetailTitle => 'Program Details';

  @override
  String get assignToMember => 'Assign to Member';

  @override
  String get memberProgramsTitle => 'My Programs';

  @override
  String get noProgramAssigned => 'No program assigned yet';

  @override
  String get workoutDetailTitle => 'Workout Details';

  @override
  String get invitationListTitle => 'Invitations';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Decline';

  @override
  String get findPtTitle => 'Find PT';

  @override
  String get searchPt => 'Search PT...';

  @override
  String get noPtFound => 'No PT found';

  @override
  String get profileTitle => 'Profile';

  @override
  String get noName => 'No name';

  @override
  String get rolePt => 'Personal Trainer';

  @override
  String get roleMember => 'Member';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get helpGuide => 'User Guide';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get quickApply => 'Quick Apply';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End';

  @override
  String get breakLabel => 'Break';

  @override
  String get breakStart => 'Break start';

  @override
  String get breakEnd => 'Break end';

  @override
  String applyToNDays(int count) {
    return 'Apply to $count days';
  }

  @override
  String get dailySettings => 'Daily Settings';

  @override
  String get closed => 'Closed';

  @override
  String get breakTimeTitle => 'Break time';

  @override
  String get breakTimeSubtitle => 'No appointments during break';

  @override
  String get workScheduleSaved => 'Work schedule saved';

  @override
  String get done => 'Done';

  @override
  String get dayMon => 'Monday';

  @override
  String get dayTue => 'Tuesday';

  @override
  String get dayWed => 'Wednesday';

  @override
  String get dayThu => 'Thursday';

  @override
  String get dayFri => 'Friday';

  @override
  String get daySat => 'Saturday';

  @override
  String get daySun => 'Sunday';

  @override
  String get dayMonShort => 'Mon';

  @override
  String get dayTueShort => 'Tue';

  @override
  String get dayWedShort => 'Wed';

  @override
  String get dayThuShort => 'Thu';

  @override
  String get dayFriShort => 'Fri';

  @override
  String get daySatShort => 'Sat';

  @override
  String get daySunShort => 'Sun';

  @override
  String get settingsSection => 'Settings';

  @override
  String get supportSection => 'Support';

  @override
  String get signOut => 'Sign Out';

  @override
  String get notifSettings => 'Notification Settings';

  @override
  String get notifOn => 'Notifications On';

  @override
  String get notifOff => 'Notifications Off';

  @override
  String get notifOnSub => 'You receive appointment and session notifications';

  @override
  String get notifOffSub => 'Permission required for appointment notifications';

  @override
  String get openSystemSettings => 'Open System Settings';

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeSystemSub => 'Follows your device theme';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeLightSub => 'Always use light theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeDarkSub => 'Always use dark theme';

  @override
  String get themeLabelLight => '☀️  Light';

  @override
  String get themeLabelDark => '🌙  Dark';

  @override
  String get themeLabelSystem => '⚙️  System';

  @override
  String get languageTitle => 'Dil / Language';

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get editName => 'Edit Name';

  @override
  String get photoUpdated => 'Profile photo updated';

  @override
  String get photoFailed => 'Photo could not be uploaded';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get updateFailed => 'Could not update';

  @override
  String get messaging => 'Messaging';

  @override
  String get chatEmptyMessage => 'No messages yet.\nSay hello to get started!';

  @override
  String sendFailed(String error) {
    return 'Could not send: $error';
  }

  @override
  String get noEventToday => 'No events today';

  @override
  String get addSessionSubtitle => 'Plan a training session with a member';

  @override
  String get addPersonalEventSubtitle => 'Add workout, note or reminder';

  @override
  String get addPersonalEventSubtitleMember =>
      'Add a workout, note or reminder';

  @override
  String get createSession => 'Create Session';

  @override
  String get eventConflict => 'There is a conflicting event at this time';

  @override
  String get sessionConflict => 'There is a conflicting session at this time';

  @override
  String get selectMember => 'Select Member';

  @override
  String get member => 'Member';

  @override
  String get time => 'Time';

  @override
  String get appointmentRequest => 'Appointment Request';

  @override
  String get appointmentRequestSub =>
      'Request an appointment from your trainer';

  @override
  String get noEventForDay => 'No events for this day';

  @override
  String get ptAppointment => 'PT Appointment';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get addEvent => 'Add Event';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get duration => 'Duration';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get setPassive => 'Set Passive';

  @override
  String get setActive => 'Set Active';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get overview => 'Overview';

  @override
  String get programs => 'Programs';

  @override
  String get sessionsTab => 'Sessions';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get joinDate => 'Join Date';

  @override
  String get startingWeightLabel => 'Starting Weight';

  @override
  String get heightLabel => 'Height';

  @override
  String get phone => 'Phone';

  @override
  String get bodyMeasurements => 'Body Measurements (cm)';

  @override
  String get leg => 'Leg';

  @override
  String get armBicep => 'Arm (bicep)';

  @override
  String get myPackages => 'My Packages';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get remainingSessionRights => 'remaining sessions';

  @override
  String get noPtPackagesSub =>
      'Packages will appear here once your PT adds you to the system';

  @override
  String get buyPackage => 'Buy Package';

  @override
  String get purchase => 'Purchase';

  @override
  String get paymentRequestCreated =>
      'Your payment request has been created. Your sessions will be added after PT approval.';

  @override
  String get noPackagesYet => 'No packages created yet';

  @override
  String get noPackagesYetSub => 'Create session packages for your members';

  @override
  String get noPackagesAvailable => 'No packages available for purchase';

  @override
  String get addPackage => 'Add Package';

  @override
  String get editPackage => 'Edit Package';

  @override
  String get newPackage => 'New Package';

  @override
  String get packageName => 'Package Name';

  @override
  String get sessionCountLabel => 'Session Count';

  @override
  String get sessionDuration => 'Session Duration';

  @override
  String get priceTry => 'Price (TRY)';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get memberSpecificPackage => 'Member-specific package';

  @override
  String get createPackage => 'Create Package';

  @override
  String get deletePackageTitle => 'Delete Package';

  @override
  String get deletePackageConfirm => 'Do you want to delete this package?';

  @override
  String get packageDeleted => 'Package deleted';

  @override
  String deleteFailed(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get special => 'Special';

  @override
  String get edit => 'Edit';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get selectMemberHint => 'Select member';

  @override
  String get selectMemberRequired => 'Please select a member';

  @override
  String get deleteProgram => 'Delete Program';

  @override
  String get deleteProgramConfirm =>
      'Do you want to permanently delete this program?';

  @override
  String get ok => 'OK';

  @override
  String get restDay => 'Rest';

  @override
  String get restDayLabel => 'Rest Day';

  @override
  String get restDayFull => 'Rest Day 🛌';

  @override
  String get noExercisesYet => 'No exercises added yet';

  @override
  String get myWorkoutProgram => 'My Workout Program';

  @override
  String get programName => 'Program Name';

  @override
  String get programUpdated => 'Program updated';

  @override
  String get programCreated => 'Program created';

  @override
  String get weekCountLabel => 'Number of Weeks:';

  @override
  String get addWorkout => 'Add Workout';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get restSeconds => 'Rest (sec)';

  @override
  String get noteLabel => 'Note';

  @override
  String get selectMemberSnack => 'Please select a member';

  @override
  String get membersLoadFailed => 'Could not load members';

  @override
  String get editProgram => 'Edit Program';

  @override
  String get sendingInvitation => 'Sending invitation...';

  @override
  String get memberInfo => 'Member Information';

  @override
  String get memberEmailInstructions =>
      'Search by the member\'s email. The member must register in the app first.';

  @override
  String get goalOptional => 'Goal (Optional)';

  @override
  String get goalHintAlt => 'Weight loss, muscle gain...';

  @override
  String get notesHint => 'Special conditions, health notes...';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String memberMadeActive(String name) {
    return '$name set to active';
  }

  @override
  String memberMadePassive(String name) {
    return '$name set to passive';
  }

  @override
  String memberDeleteConfirm(String name) {
    return '$name will be permanently deleted. This cannot be undone.';
  }

  @override
  String get noAssignedPrograms =>
      'You\'ll see programs here when your PT assigns one';

  @override
  String get weekLabel => 'Week';

  @override
  String get programNotFound => 'Program not found';

  @override
  String get helpGuideTitle => 'User Guide';

  @override
  String get ptRequestTitle => 'Send Request to PT';

  @override
  String ptRequestContent(String ptName) {
    return 'Do you want to send a join request to trainer $ptName?\n\nYou will be connected after the trainer approves the request.';
  }

  @override
  String requestSentTo(String ptName) {
    return 'Request sent to trainer $ptName';
  }

  @override
  String get searchByNameOrEmail => 'Search by name or email';

  @override
  String get searchHintFull => 'Enter a name or email\nto search for a PT';

  @override
  String noResultFor(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String ptConnected(String ptName) {
    return 'Connected with $ptName';
  }

  @override
  String get invitationRejected => 'Invitation declined';

  @override
  String invitationDate(String date) {
    return 'Invited: $date';
  }

  @override
  String get noInvitationsYetSub =>
      'You\'ll see invitations here when your PT sends one';

  @override
  String memberDeleteError(String error) {
    return 'Delete error: $error';
  }

  @override
  String sessionsLeft(int count) {
    return '$count sessions left';
  }

  @override
  String get noMemberPrograms => 'No programs yet';

  @override
  String get noMemberSessions => 'No sessions yet';

  @override
  String get personalEvent => 'Personal Event';

  @override
  String get deleteEventTitle => 'Delete Event';

  @override
  String deleteEventConfirm(String title) {
    return 'Do you want to delete the \"$title\" event?';
  }

  @override
  String get anonymousMember => 'Unnamed Member';

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String eventsCount(int count) {
    return '$count events';
  }

  @override
  String get noProgramsYetSub => 'Create workout programs for your members';

  @override
  String weekProgramLabel(int count) {
    return '$count-Week Program';
  }

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String completedPaymentsCount(int count) {
    return '$count Payments';
  }

  @override
  String pendingPaymentsCount(int count) {
    return '$count Pending';
  }

  @override
  String pendingApprovalCount(int count) {
    return 'Pending Approval ($count)';
  }

  @override
  String get noPaymentsYetSub =>
      'Will appear here when your members buy a package';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String sessionsLoadedToMember(int count) {
    return '$count sessions loaded to member';
  }

  @override
  String get paymentRequestRejected => 'Payment request rejected';

  @override
  String get statusLabel => 'Status';

  @override
  String get cancelSession => 'Cancel';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String durationMinutesValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get requestRejected => 'Request rejected';

  @override
  String memberAddedSnack(String name) {
    return '$name added as a member';
  }

  @override
  String get restDayMessage => 'Today is a rest day 🛌 Enjoy your rest!';

  @override
  String memberActivatedSnack(String name) {
    return '$name has been activated';
  }

  @override
  String get appSubtitle => 'Personal Training App';

  @override
  String get weightShort => 'Weight';

  @override
  String get waistShort => 'Waist';

  @override
  String get chestShort => 'Chest';

  @override
  String get hipsShort => 'Hips';

  @override
  String purchaseDialogContent(String name, String price, int count) {
    return 'Do you want to purchase the $name package for $price?\n\n$count session credits will be added to your account after PT approval.';
  }

  @override
  String get helpWelcomeTitle => 'Welcome to BookMyPT!';

  @override
  String get helpMemberIntroBody =>
      'With this app, you can easily book appointments with your trainer, track your progress, and manage your session packages.';

  @override
  String get helpPtIntroBody =>
      'With this app, you can easily manage your members\' appointments, create session packages, and track your earnings.';

  @override
  String get helpHomeTitle => 'Home Screen';

  @override
  String get helpHomeItem1Title => 'Trainer Information';

  @override
  String get helpHomeItem1Body =>
      'Your assigned PT, remaining session credits, and upcoming appointments are visible at a glance on the home screen.';

  @override
  String get helpHomeItem2Title => 'If No PT Assigned';

  @override
  String get helpHomeItem2Body =>
      'You can add your trainer to the system using their email via the \"Find PT\" feature. Once the PT adds you, appointments and packages become active.';

  @override
  String get helpHomeItem3Title => 'Leave Membership';

  @override
  String get helpHomeItem3Body =>
      'You can disconnect from your trainer using the \"Leave Membership\" button on the PT card. Your remaining session credits are not affected.';

  @override
  String get helpCalendarTitle => 'My Appointments';

  @override
  String get helpCalendarItem1Title => 'Creating an Appointment Request';

  @override
  String get helpCalendarItem1Body =>
      'Press the + button at the top right, select date and time. If your package has a session duration, it is set automatically. Your request is sent for PT approval.';

  @override
  String get helpCalendarItem2Title => 'Calendar Tab';

  @override
  String get helpCalendarItem2Body =>
      'You can see all your appointments by day. Blue dots indicate your appointments, grey dots indicate times when the PT is busy. Tap pending requests to change the date or time.';

  @override
  String get helpCalendarItem3Title => 'History Tab';

  @override
  String get helpCalendarItem3Body =>
      'You can see the count and total duration of completed sessions. Upcoming confirmed appointments are also listed in this tab.';

  @override
  String get helpCalendarItem4Title => 'Appointment Statuses';

  @override
  String get helpCalendarItem4Body =>
      '• Pending: Request created, awaiting PT approval.\n• Confirmed: PT accepted, session will happen.\n• Completed: Session took place.\n• Cancelled: Session was cancelled.';

  @override
  String get helpMyCalendarTitle => 'My Calendar';

  @override
  String get helpMyCalendarItem1Title => 'Adding Personal Events';

  @override
  String get helpMyCalendarItem1Body =>
      'You can add personal events (workout, meeting, holiday, etc.) with the + button at the top right. These events only appear in your calendar.';

  @override
  String get helpMyCalendarItem2Title => 'PT Availability';

  @override
  String get helpMyCalendarItem2Body =>
      'Your PT\'s appointments with other members and personal events appear in grey. This lets you check availability before making an appointment request.';

  @override
  String get helpMyCalendarItem3Title => 'Editing Events';

  @override
  String get helpMyCalendarItem3Body =>
      'Tap your personal events to edit the date, time, duration, and notes, or delete them.';

  @override
  String get helpPackagesTitle => 'My Packages';

  @override
  String get helpPackagesItem1Title => 'Buying a Package';

  @override
  String get helpPackagesItem1Body =>
      'You can see session packages offered by your PT on this screen. Pressing \"Purchase\" creates a payment request; your session credits are added after PT approval.';

  @override
  String get helpPackagesItem2Title => 'Member-Specific Packages';

  @override
  String get helpPackagesItem2Body =>
      'Your PT may have created a specially priced or custom package for you. Only you can see these packages.';

  @override
  String get helpPackagesItem3Title => 'Payment History';

  @override
  String get helpPackagesItem3Body =>
      'All your payment requests and their statuses (Pending / Completed) are listed at the top of the screen.';

  @override
  String get helpProgressTitle => 'Progress';

  @override
  String get helpProgressItem1Title => 'Entering Measurements';

  @override
  String get helpProgressItem1Body =>
      'You can record your weight, height, and body measurements. You can also track visual progress by adding photos.';

  @override
  String get helpProgressItem2Title => 'Backdated Entry';

  @override
  String get helpProgressItem2Body =>
      'You can make backdated entries by selecting a date for days you forgot to log.';

  @override
  String get helpProgressItem3Title => 'Chart Tracking';

  @override
  String get helpProgressItem3Body =>
      'Your recorded measurements are shown as charts. You can easily track your changes over time.';

  @override
  String get helpMessagesTitle => 'Messages';

  @override
  String get helpMemberMessagesItem1Title => 'Communication with PT';

  @override
  String get helpMemberMessagesItem1Body =>
      'You can message your PT directly. Use this screen for session changes, questions, or workout notes.';

  @override
  String get helpPtHomeItem1Title => 'Daily Summary';

  @override
  String get helpPtHomeItem1Body =>
      'Today\'s appointments, pending requests, and recent member activity are listed on the home screen.';

  @override
  String get helpPtHomeItem2Title => 'Pending Requests';

  @override
  String get helpPtHomeItem2Body =>
      'You can quickly approve or reject your members\' appointment requests here. A notification is sent to the member when you approve.';

  @override
  String get helpPtHomeItem3Title => 'Activation Requests';

  @override
  String get helpPtHomeItem3Body =>
      'Passive members can send activation requests. You can manage these requests from the home screen.';

  @override
  String get helpPtCalendarTitle => 'Calendar';

  @override
  String get helpPtCalendarItem1Title => 'Appointment Management';

  @override
  String get helpPtCalendarItem1Body =>
      'All your members\' sessions appear on the calendar as colored dots. Click a day to see the detailed list for that day.';

  @override
  String get helpPtCalendarItem2Title => 'Personal Events';

  @override
  String get helpPtCalendarItem2Body =>
      'You can add personal events like holidays or meetings using the + button at the top right. These times appear as \"busy\" on members\' appointment calendars.';

  @override
  String get helpPtCalendarItem3Title => 'Session Detail';

  @override
  String get helpPtCalendarItem3Body =>
      'Click a session in the list to open the detail screen, update its status (confirm / cancel / complete), and add notes.';

  @override
  String get helpPtMembersTitle => 'Members';

  @override
  String get helpPtMembersItem1Title => 'Adding a Member';

  @override
  String get helpPtMembersItem1Body =>
      'Press the + button to add a new member and enter their information. The added member is linked to you and can book appointments.';

  @override
  String get helpPtMembersItem2Title => 'Member Management';

  @override
  String get helpPtMembersItem2Body =>
      'Click a member card to view their profile details, add personal goals and notes, and track remaining session credits.';

  @override
  String get helpPtMembersItem3Title => 'Active / Passive Status';

  @override
  String get helpPtMembersItem3Body =>
      'When you set a member to passive, they cannot create new appointment requests. If they send an activation request, you approve it.';

  @override
  String get helpPtPackagesTitle => 'Package Management';

  @override
  String get helpPtPackagesItem1Title => 'Creating a Package';

  @override
  String get helpPtPackagesItem1Body =>
      'You can create a package by specifying the number of sessions, duration, and price. Packages are visible to all active members.';

  @override
  String get helpPtPackagesItem2Title => 'Member-Specific Package';

  @override
  String get helpPtPackagesItem2Body =>
      'With the \"Member-specific\" option, you can define a specially priced package for a specific member. This package only appears on that member\'s Packages screen.';

  @override
  String get helpPtPackagesItem3Title => 'Session Duration';

  @override
  String get helpPtPackagesItem3Body =>
      'If you specify a session duration in a package, the duration is set automatically when that member books an appointment and the member cannot select manually.';

  @override
  String get helpPtEarningsTitle => 'Earnings & Payments';

  @override
  String get helpPtEarningsItem1Title => 'Approving Payments';

  @override
  String get helpPtEarningsItem1Body =>
      'When a member purchases a package, a payment request is created. When you approve, the member\'s session credits are automatically updated and a notification is sent.';

  @override
  String get helpPtEarningsItem2Title => 'Rejecting Payments';

  @override
  String get helpPtEarningsItem2Body =>
      'You can reject a request if the payment did not go through. No session credits are added.';

  @override
  String get helpPtEarningsItem3Title => 'Earnings Summary';

  @override
  String get helpPtEarningsItem3Body =>
      'Monthly and total earnings summary is displayed at the top of the screen.';

  @override
  String get helpPtMessagesItem1Title => 'Member Communication';

  @override
  String get helpPtMessagesItem1Body =>
      'You can message each of your members separately. Use it for workout notes, diet recommendations, or session changes.';

  @override
  String get helpTipBody =>
      'If you experience issues, try closing and reopening the app. To receive notifications, check notification permissions in Profile → Notifications.';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noPendingRequestsSub =>
      'Will appear here when members send a request to join you';

  @override
  String get activationRequest => 'Activation request';

  @override
  String get joinRequest => 'Join request';

  @override
  String get programNameHint => 'Beginner Program';

  @override
  String get programDescriptionHint => 'Brief info about the program';

  @override
  String get colorSchemeSection => 'Color Scheme';

  @override
  String get colorSchemeClassic => 'Classic';

  @override
  String get colorSchemeClassicSub => 'Default color theme';

  @override
  String get colorSchemeSport => 'Sport';

  @override
  String get colorSchemeSportSub => 'Vibrant and energetic colors';

  @override
  String get deleteForMe => 'Delete for Me';

  @override
  String get deleteForEveryone => 'Delete for Everyone';

  @override
  String get messageDeleted => 'This message was deleted';

  @override
  String get groups => 'Groups';

  @override
  String get group => 'Group';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get createGroupHint => 'Tap + to create a group';

  @override
  String get createGroup => 'Create Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String get deleteGroupConfirm =>
      'Are you sure you want to delete this group? Past session records will be kept.';

  @override
  String get groupName => 'Group Name';

  @override
  String get groupNameHint => 'Morning Group, Weight Loss Group...';

  @override
  String get groupDescription => 'Description';

  @override
  String get groupDescriptionHint => 'Brief description of the group';

  @override
  String get groupColor => 'Group Color';

  @override
  String get groupNeedMembers => 'Please select at least one member';

  @override
  String get selectMembers => 'Select Members';

  @override
  String get selected => 'selected';

  @override
  String get noActiveMembers => 'No active members found';

  @override
  String get members => 'Members';

  @override
  String get noMembersInGroup => 'No members in this group yet';

  @override
  String get packages => 'Packages';

  @override
  String get perMember => 'per member';

  @override
  String get inactive => 'Inactive';

  @override
  String get required => 'Required';

  @override
  String get price => 'Price';

  @override
  String get sessionCount => 'Session Count';

  @override
  String get newSession => 'New Session';

  @override
  String get sessionDetail => 'Session Detail';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get attendance => 'Attendance';

  @override
  String get attended => 'attended';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get sessionCompleted => 'Session Completed';

  @override
  String get cancelSessionConfirm =>
      'Are you sure you want to cancel this session?';

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String get optionalNotes => 'Notes (optional)';

  @override
  String get participants => 'participants';

  @override
  String get openChat => 'Open Chat';

  @override
  String get individual => 'Individual';

  @override
  String get groupPackages => 'Group Packages';

  @override
  String get notInAnyGroup => 'You are not a member of any group';

  @override
  String get noGroupPackagesYet => 'No group packages available';

  @override
  String get alreadyPurchased => 'Already Purchased';

  @override
  String groupPurchaseConfirm(
      String name, String groupName, String price, int count) {
    return 'Would you like to purchase the $name package for $groupName for $price?\n\n$count session credits will be added to your account after PT approval.';
  }

  @override
  String get sendCancellationRequest => 'Request Cancellation';

  @override
  String get cancellationRequestSent => 'Cancellation Request Sent';

  @override
  String get memberRequestedCancellation => 'Member Requested Cancellation';

  @override
  String get ptRequestedCancellation => 'Trainer Requested Cancellation';

  @override
  String get acceptCancellation => 'Accept Cancellation';

  @override
  String get rejectCancellation => 'Reject';

  @override
  String get cancellationRequestConfirm =>
      'Your cancellation request will be sent to the other party. Do you want to proceed?';

  @override
  String get sessionInFutureWarning => 'Cannot complete a future session';

  @override
  String get exerciseTypeStrength => 'Strength';

  @override
  String get exerciseTypeCardio => 'Cardio';

  @override
  String get exerciseTypeStretching => 'Stretch';

  @override
  String get durationMinLabel => 'Duration (min)';

  @override
  String get distanceKmLabel => 'Distance (km)';

  @override
  String get holdSecLabel => 'Hold Time (sec)';

  @override
  String get about => 'About';

  @override
  String get aboutTagline => 'Personal trainer & member management platform';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutReleaseDateLabel => 'Release Date';

  @override
  String get aboutReleaseDateValue => 'May 2026';

  @override
  String get aboutDeveloperLabel => 'Developer';

  @override
  String get aboutDeveloperName => 'BookMyPt Team';

  @override
  String get aboutCopyright => '© 2026 BookMyPt. All rights reserved.';

  @override
  String get deleteChatTitle => 'Delete Conversation';

  @override
  String get deleteChatBody =>
      'When this conversation is deleted, it disappears from the list for both parties. This action cannot be undone. Do you want to continue?';

  @override
  String get chatDeleted => 'Conversation deleted';

  @override
  String get helpCalendarItem5Title => 'Date Restriction';

  @override
  String get helpCalendarItem5Body =>
      'You cannot request an appointment for a past date or time. The selected time must be at least 5 minutes in the future.';

  @override
  String get helpPackagesItem4Title => 'Group Packages';

  @override
  String get helpPackagesItem4Body =>
      'If your trainer has added you to a group, you can purchase packages for that group in the Groups tab. Your session credits are added after the PT approves.';

  @override
  String get helpProgramsTitle => 'My Programs';

  @override
  String get helpProgramsItem1Title => 'Workout Program';

  @override
  String get helpProgramsItem1Body =>
      'Your PT can assign you a weekly workout program. You can review it week by week and day by day and see all exercise details.';

  @override
  String get helpProgramsItem2Title => 'Exercise Types';

  @override
  String get helpProgramsItem2Body =>
      'Programs can contain three exercise types: 💪 Strength (sets/reps/weight), 🏃 Cardio (duration/distance) and 🧘 Stretching (sets/hold duration).';

  @override
  String get helpMemberMessagesItem2Title => 'Group Chats';

  @override
  String get helpMemberMessagesItem2Body =>
      'If your trainer adds you to a group, a group chat room is automatically created. All group members and the PT join the group chat.';

  @override
  String get helpMemberMessagesItem3Title => 'Delete Conversation';

  @override
  String get helpMemberMessagesItem3Body =>
      'Long press any conversation in the chat list to access the delete option. When deleted, the conversation disappears for both parties.';

  @override
  String get helpPtProgramsTitle => 'Workout Programs';

  @override
  String get helpPtProgramsItem1Title => 'Creating a Program';

  @override
  String get helpPtProgramsItem1Body =>
      'Select a member and create a weekly workout program. Set the number of weeks (1–12) and add daily exercises. Saturday and Sunday are rest days by default.';

  @override
  String get helpPtProgramsItem2Title => 'Exercise Types';

  @override
  String get helpPtProgramsItem2Body =>
      'Add 3 types of exercises: Strength (sets/reps/weight/rest), Cardio (duration/distance) and Stretching (sets/hold duration). Select the type using the selector in the Add Exercise screen.';

  @override
  String get helpPtProgramsItem3Title => 'Active / Inactive';

  @override
  String get helpPtProgramsItem3Body =>
      'Only active programs are visible to the member. You can hide a program by deactivating it and reactivate it at any time.';

  @override
  String get helpPtPackagesItem4Title => 'Group Management';

  @override
  String get helpPtPackagesItem4Body =>
      'From the Groups tab, group multiple members together. Define packages and sessions per group; a chat room is created automatically. The chat room is removed when the group is deleted.';

  @override
  String get helpPtEarningsItem4Title => 'Instant Notification';

  @override
  String get helpPtEarningsItem4Body =>
      'You receive an instant push notification when a member purchases a package. Tap the notification to go directly to the Earnings screen.';

  @override
  String get helpPtMessagesItem2Title => 'Group Chats';

  @override
  String get helpPtMessagesItem2Body =>
      'A chat room is automatically created for every group you create. The chat room is removed when the group is deleted.';

  @override
  String get helpPtMessagesItem3Title => 'Delete Conversation';

  @override
  String get helpPtMessagesItem3Body =>
      'Long press any conversation in the chat list to delete it. When deleted, the conversation disappears for both parties.';
}
