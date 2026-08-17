import '../manage_imports.dart';

class AppServerConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://admin.my-talia.com'; // Don't add slash at the end of the url
    } else if (kProfileMode) {
      return 'https://admin.my-talia.com'; // Don't add slash at the end of the url
    } else {
      return 'https://admin.my-talia.com'; // Don't add slash at the end of the url
    }
  }
}
