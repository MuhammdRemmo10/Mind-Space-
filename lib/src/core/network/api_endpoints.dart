class ApiEndpoints {
  const ApiEndpoints._();

  static const String register = '/api/auth/register.php';
  static const String login = '/api/auth/login.php';
  static const String forgotPassword = '/api/auth/forgot-password.php';
  static const String resetPassword = '/api/auth/reset-password.php';
  static const String verifyEmail = '/api/auth/verify-email.php';
  static const String refreshToken = '/api/auth/refresh-token.php';
  static const String logout = '/api/auth/logout.php';

  static const String profile = '/api/user/profile.php';
  static const String dashboard = '/api/dashboard/index.php';
  static const String spaces = '/api/spaces/index.php';
  static const String notes = '/api/notes/index.php';
  static const String articles = '/api/articles/index.php';
  static const String taskLists = '/api/task-lists/index.php';
  static const String tasks = '/api/tasks/index.php';
  static const String tags = '/api/tags/index.php';
  static const String files = '/api/files/index.php';
  static const String search = '/api/search/index.php';
}
