class AppConstants {
  AppConstants._();

  static const String appName = 'FitCoach';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String ptsCollection = 'pts';
  static const String membersSubCollection = 'members';
  static const String programsCollection = 'programs';
  static const String sessionsCollection = 'sessions';
  static const String paymentsCollection = 'payments';
  static const String progressCollection = 'progress';
  static const String chatsCollection = 'chats';
  static const String messagesSubCollection = 'messages';
  static const String packagesSubCollection = 'packages';
  static const String invitationsCollection = 'invitations';
  static const String personalEventsCollection = 'personal_events';

  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String progressPhotosPath = 'progress_photos';

  // Roles
  static const String roleTrainer = 'pt';
  static const String roleMember = 'member';

  // Session Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Pagination
  static const int pageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);

  // Stripe
  static const String stripeCurrency = 'try';
}
