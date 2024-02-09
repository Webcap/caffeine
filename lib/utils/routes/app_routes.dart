part of 'app_pages.dart';

abstract class Routes {
  static const splash = '/';
  static const landingScreen = '/landing';
  static const signup = '/signup';
  static const welcome = '/UserState';
  static const profileEdit = '/ProfileEdit';
  static const settings = '/Settings';
  static const passwordChangeScreen = '/passwordChangeScreen';
  static const noConnection = '/noConnection_screen';
  static const dash = '/dash_screen';
  static const login = '/login';
  static const profile = '/profile';
}

abstract class AppRoutes {
  static const splash = Routes.splash;
  static const welcome = Routes.welcome;
  static const login = Routes.login;
  static const signup = Routes.signup;
  static const LandingScreen = Routes.landingScreen;
  static const profileEdit = Routes.profileEdit;
  static const settings = Routes.settings;
  static const dash = Routes.dash;
  static const passwordchangescreen = Routes.passwordChangeScreen;
  static const noConnection = Routes.noConnection;
  static const profile = Routes.profile;
}
