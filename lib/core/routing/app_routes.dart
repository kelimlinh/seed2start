abstract final class AppRoutes {
  static const root = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const goals = '/goals';
  static const journey = '/journey';
  static const reflection = '/reflection';
  static const workbook = '/workbook';
  static const progress = '/progress';
  static const ai = '/ai';

  // Public workbook companion routes.
  static const access = '/access';
  static const resource = '/r';

  static String workbookLesson(String lessonId) => '/workbook/$lessonId';
  static String accessCode(String code) => '$access/$code';
  static String resourceById(String resourceId) => '$resource/$resourceId';
}
