part of 'app_pages.dart';


abstract class Routes {
  static const splash = '/';
  static const profileEdit = '/ProfileEdit';
  static const settings = '/Settings';
  static const passwordChangeScreen = '/passwordChangeScreen';
}

abstract class AppRoutes {
  static const splash = Routes.splash;
  static const profileEdit = Routes.profileEdit;
  static const settings = Routes.settings;
  static const passwordchangescreen = Routes.passwordChangeScreen;
}
