part of 'app_pages.dart';

abstract class Routes {
  static const splash = '/';
  static const signup = '/signup';
  static const profileEdit = '/ProfileEdit';
  static const settings = '/Settings';
  static const passwordChangeScreen = '/passwordChangeScreen';
  static const noConnection = '/noConnection_screen';
  static const dash = '/dash_screen';
  static const login = '/login';
  static const profile = '/profile';
  static const watchHistory = '/watchHistory';
  static const pairTv = '/pairTv';
  static const paymentMethod = '/paymentMethod';
  static const addNewCard = '/addNewCard';
  static const premium = '/premium';
}

abstract class AppRoutes {
  static const splash = Routes.splash;
  static const login = Routes.login;
  static const signup = Routes.signup;
  static const profileEdit = Routes.profileEdit;
  static const settings = Routes.settings;
  static const dash = Routes.dash;
  static const passwordchangescreen = Routes.passwordChangeScreen;
  static const noConnection = Routes.noConnection;
  static const profile = Routes.profile;
  static const watchHistory = Routes.watchHistory;
  static const pairTv = Routes.pairTv;
  static const paymentMethod = Routes.paymentMethod;
  static const addNewCard = Routes.addNewCard;
  static const premium = Routes.premium;
}
