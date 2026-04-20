class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String googleAuth = '/auth/google';
  static const String profile = '/users/profile';
  static const String refresh = '/auth/refresh';

  // Exams
  static const String exams = '/exams';
  static const String activeExams = '/exams/active';

  // Modules
  static const String modules = '/modules';
  static const String allModules = '/modules/all';
  static String modulesByExam(String examId) => '/modules/exam/$examId';

  // Contents
  static const String contents = '/contents';
  static const String allContents = '/contents/all';
  static String contentsByModule(String moduleId) =>
      '/contents/module/$moduleId';
  static String contentById(String contentId) => '/contents/$contentId';

  // Questions
  static String questionsByTest(String mockTestId) =>
      '/questions/test/$mockTestId';
  static const String questionsCreate = '/questions';
  static const String questionsBulk = '/questions/bulk';

  // Test Sessions
  static const String testSessionStart = '/test-sessions/start';
  static String testSessionSubmit(String sessionId) =>
      '/test-sessions/$sessionId/submit';
  static const String mySessions = '/test-sessions/my-sessions';

  // Payments
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify-payment';

  // Ads
  static String activeAds(String placement) => '/ads/active/$placement';

  // Videos
  static String videoStream(String contentId) => '/videos/stream/$contentId';

  // App Config
  static const String appConfig = '/app-config';

  // Analytics
  static const String dashboardStats = '/analytics/dashboard';
  static const String revenueStats = '/analytics/revenue';
}
